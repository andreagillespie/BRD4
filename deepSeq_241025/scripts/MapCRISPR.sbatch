#!/bin/bash
 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --partition=prod_med
#SBATCH --time=0-12:00:00
#SBATCH --output=logs/baseEditorMap%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END
#SBATCH --job-name="baseEditorMap"

module load trimgalore/0.4.4
module load bowtie2/2.3.4.1
module load fastqc/0.11.6
module load samtools/1.17

bname=`basename $1 _R1_001.fastq.gz`
ref=/data/reference/dawson_labs/genomes/Hg38/Homo_sapiens.GRCh38.dna.toplevel.fa

fastqc -t 4 -o fastqc/ $1 $2

trim_galore --fastqc --paired -o trimmed_fastqs $1 $2

bowtie2 -p 4 -t -x $ref --sensitive \
  -1 trimmed_fastqs/${bname}_R1_001_val_1.fq.gz \
  -2 trimmed_fastqs/${bname}_R2_001_val_2.fq.gz \
  -S alignment/${bname}.mapped.sam
  
# convert to bam
samtools view -b -@ 3 -o alignment/${bname}.bam alignment/${bname}.mapped.sam

# sort 
samtools sort -@ 3 -o alignment/${bname}.sort.bam alignment/${bname}.bam

# index bam file
samtools index -@ 3 alignment/${bname}.sort.bam

# get the pileup over exons 6 & 7 of BRD4
samtools mpileup --positions reference_files/BRD4_exon6_7.bed -d 0 \
  -o alignment/${bname}.pileup.txt alignment/${bname}.sort.bam

# make pileup with only position & nucleotides 
gawk -F'\t' '{ print $2 "\t" $5 }' alignment/${bname}.pileup.txt > \
  alignment/${bname}.pileup.simp.txt
