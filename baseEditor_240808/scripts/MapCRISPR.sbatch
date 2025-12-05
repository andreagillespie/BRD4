#!/bin/bash
 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --partition=prod_med
#SBATCH --time=0-01:00:00
#SBATCH --output=logs/baseEditorMap%j.stdout
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END
#SBATCH --job-name="baseEditorMap"

module load cutadapt/2.1
module load bowtie2/2.3.4.1
module load fastqc/0.11.6
module load samtools/1.17

bname=`basename $1 _R1_001.fastq.gz`
ref=/dawson_genomics/Projects/CCS1477/baseEditor_240529/reference_files/Guides_BRD4_VHL

fastqc -t 4 -o fastqc/ $1

cutadapt -g "CCTTGTGGAAAGGACGAAACACCG...GTTTAAGAGCTATGCTGGAAACAGCATAGCAAGTTTAAA;max_error_rate=0.1" \
  -o trimmed_fastqs/${bname}.trim.fq $1

fastqc -t 4 -o trimmed_fastqs/ trimmed_fastqs/${bname}.trim.fq

bowtie2 --no-head -p 4 -t -x $ref --very-sensitive \
  -U trimmed_fastqs/${bname}.trim.fq -S alignment/${bname}.mapped.sam

# Filtering out mutli-aligning reads  
sed '/XS:/d' alignment/${bname}.mapped.sam > alignment/${bname}.unique.sam

rm alignment/${bname}.mapped.sam

# Extracting column 2 of the file (sgRNA names) 
cut -f3 alignment/${bname}.unique.sam > mapped_guides/${bname}.mappedGuides.txt

# Counting occurences of each sgRNA 
sort mapped_guides/${bname}.mappedGuides.txt | uniq -c > guide_counts/${bname}.guideCounts.txt

# get headed sam for stats
bowtie2 -t -x $ref --very-sensitive \
  -U trimmed_fastqs/${bname}.trim.fq -S alignment/${bname}.headed.sam
