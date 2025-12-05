#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=prod_short
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --mail-type=END
#SBATCH --output=logs/vep-%j.out
#SBATCH --job-name="vep"

input=$1
outputdir=$2
output=`basename $input`
output=${output/\/vcf//annotation_vep}
output=${output/\.vcf/.vep.vcf}
output=${outputdir}/${output}

echo ${input}
echo ${output}

vep_container="/config/binaries/singularity/containers/vep/98/vep.sif"
ref="/data/seqliner/seqliner-resources/reference_genomes/hg38/Homo_sapiens.GRCh38.dna.toplevel.fa"
# vep cache dir, cache subfolders with names matching species + assembly
vep_cache_dir="/data/databases/ensembl"
vep_plugin_dir="/data/databases/ensembl/Plugins_98"

# Plugins 
# working for hg38: CADD and Condel, gnomad protentially if we concat the files into one
CADD="/data/databases/CADD/1.4/whole_genome_SNVs.tsv.gz,/data/databases/CADD/1.4/InDels.tsv.gz"
Condel_config="/data/databases/Condel/config"
dbNSFP="/data/databases/dbNSFP/4.0a/dbNSFP4.0a.txt.gz"
GNOMAD_GENOMES_hg38="/data/databases/gnomAD/3/gnomad.genomes.r3.0.sites.vcf.bgz"

# The columns only serve testing purposes (to see whether the plugin works or not)
dbNSFP_cols="SIFT_score,SIFT_converted_rankscore,SIFT_pred,SIFT4G_score,SIFT4G_converted_rankscore,SIFT4G_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_rankscore,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,LRT_Omega,MutationTaster_score,MutationTaster_converted_rankscore,MutationTaster_pred,MutationTaster_model,MutationTaster_AAE,MutationAssessor_score,MutationAssessor_rankscore,MutationAssessor_pred,FATHMM_score,FATHMM_converted_rankscore,FATHMM_pred,PROVEAN_score,PROVEAN_converted_rankscore,PROVEAN_pred,clinvar_id,clinvar_clnsig,clinvar_trait,clinvar_review,clinvar_hgvs,clinvar_var_source,clinvar_MedGen_id,clinvar_OMIM_id,clinvar_Orphanet_id,Interpro_domain"
#GNOMAD_GENOMES_cols="AF,AF_nfe_seu,controls_AF_afr_male,non_topmed_AF_amr,AF_raw,AF_fin_female,non_neuro_AF_asj_female,non_neuro_AF_afr_male,AF_afr_male,AF_afr,non_neuro_AF_afr_female,non_topmed_AF_amr_female,non_topmed_AF_oth_female,AF_eas_female,AF_afr_female,non_neuro_AF_female,controls_AF_afr,AF_nfe_onf,controls_AF_fin_male,non_neuro_AF_nfe_nwe,AF_fin_male,AF_nfe_female,AF_amr,non_topmed_AF_nfe_male,AF_eas,non_neuro_AF_nfe_female,non_neuro_AF_afr,controls_AF_raw,controls_AF_male,non_topmed_AF_male,controls_AF_nfe_female,non_neuro_AF_amr,non_neuro_AF_eas_female,AF_asj_male,controls_AF_nfe_male,non_neuro_AF_fin,AF_oth_female,controls_AF_nfe,controls_AF_oth_female,controls_AF_asj,non_neuro_AF_amr_male,controls_AF_nfe_nwe,AF_nfe_nwe,controls_AF_nfe_seu,non_neuro_AF_amr_female,non_neuro_AF_nfe_onf,non_topmed_AF_eas_male,controls_AF_amr_female,non_neuro_AF_fin_male,AF_female,non_neuro_AF_oth_male,non_topmed_AF_nfe_est,non_topmed_AF_nfe_nwe,non_topmed_AF_amr_male,non_topmed_AF_nfe_onf,controls_AF_eas_male,controls_AF_oth_male,non_topmed_AF,controls_AF_fin,non_neuro_AF_nfe,non_neuro_AF_fin_female,non_topmed_AF_nfe_seu,controls_AF_eas_female,non_topmed_AF_asj,controls_AF_nfe_onf,non_neuro_AF,non_topmed_AF_nfe,non_topmed_AF_raw,non_neuro_AF_nfe_est,non_topmed_AF_oth_male,AF_nfe_est,non_topmed_AF_afr_male,AF_eas_male,controls_AF_eas,non_neuro_AF_eas_male,non_neuro_AF_asj_male,controls_AF_oth,AF_nfe,non_topmed_AF_female,non_neuro_AF_asj,non_topmed_AF_eas_female,non_neuro_AF_raw,non_topmed_AF_eas,non_topmed_AF_fin_male,AF_fin,AF_nfe_male,controls_AF_amr_male,controls_AF_afr_female,controls_AF_amr,AF_asj_female,non_neuro_AF_eas,non_neuro_AF_male,AF_asj,controls_AF_nfe_est,non_topmed_AF_asj_female,non_topmed_AF_oth,non_topmed_AF_fin_female,AF_oth,non_neuro_AF_nfe_male,controls_AF_female,non_topmed_AF_fin,non_topmed_AF_nfe_female,controls_AF_asj_male,non_topmed_AF_asj_male,non_neuro_AF_oth,AF_male,controls_AF_fin_female,controls_AF_asj_female,AF_amr_male,AF_amr_female,AF_oth_male,non_neuro_AF_nfe_seu,non_topmed_AF_afr_female,non_topmed_AF_afr,controls_AF,non_neuro_AF_oth_female,controls_popmax,controls_AC_popmax,controls_AN_popmax,controls_AF_popmax,popmax,AC_popmax,AN_popmax,AF_popmax,non_neuro_popmax,non_neuro_AC_popmax,non_neuro_AN_popmax,non_neuro_AF_popmax,non_topmed_popmax,non_topmed_AC_popmax,non_topmed_AN_popmax,non_topmed_AF_popmax"
GNOMAD_GENOMES_cols="AF,AF_nfe_seu,AF_raw,AF_fin_female,AF_afr_male,AF_afr,AF_eas_female,AF_afr_female,AF_nfe_onf,AF_fin_male,AF_nfe_female,AF_amr,AF_eas,AF_asj_male,AF_oth_female,AF_nfe_nwe,AF_female,AF_nfe_est,AF_eas_male,AF_nfe,AF_fin,AF_nfe_male,AF_asj_female,AF_asj,AF_oth,AF_male,AF_amr_male,AF_amr_female,AF_oth_male,popmax,AC_popmax,AN_popmax,AF_popmax"

 # In this case, vep will look for data in $vep_cache_dir/$species/{version}_$assembly

module load singularity/3.4.0
singularity run --bind /data:/data --bind /researchers:/researchers --bind /scratch:/scratch \
 $vep_container \
 vep \
 --species homo_sapiens \
 --fasta $ref \
 --assembly GRCh38 \
 --dir $vep_cache_dir \
 --fork 8 \
 --cache --offline \
 --everything \
 --check_existing \
 --check_ref \
 --force_overwrite \
 --tab \
 -i $input \
 -o $output \
 --dir_plugins $vep_plugin_dir \
 --plugin CADD,$CADD \
 --plugin Condel,$Condel_config,b \
 --plugin dbNSFP,$dbNSFP,$dbNSFP_cols \
 --custom $GNOMAD_GENOMES_hg38,gnomADg,vcf,exact,0,$GNOMAD_GENOMES_cols

