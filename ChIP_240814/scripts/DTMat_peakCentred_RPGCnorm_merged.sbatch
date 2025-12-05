#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=0-16:00:00
#SBATCH --output=logs/deeptoolsMatrix%j.stdout
#SBATCH --mail-type=END,TIME_LIMIT_80
#SBATCH --mail-user=andrea.gillespie@petermac.org
#SBATCH --job-name="Heatmap_GeneRegion"
#SBATCH --partition=prod_med

module purge
module load deeptools/3.5.0

# run from project dir /scratch/teams/dawson_genomics/Projects/BRD4/ChIP_240814
computeMatrix reference-point --referencePoint center -p 4 -S \
bigwigs/DMSO.merged.RPGC.bw bigwigs/965a.merged.RPGC.bw bigwigs/dBET.merged.RPGC.bw \
-R macs/broadpeaks/2-ChIP-DMSO-Prep-2-R2_S86_peaks.broadPeak \
-a 3000 -b 3000 -out results/DTmat_peakCentred_RPGCnorm_merged.gz

# unclustered heatmap sorted by DMSO
plotHeatmap -m results/DTmat_peakCentred_RPGCnorm_merged.gz \
-out plots/Heatmap_peakCentered_RPGCnorm_merged.pdf --colorMap gist_heat \
--samplesLabel "DMSO" "965a" "dBET" \
--legendLocation none --sortUsingSamples 1 --sortUsing sum \
--heatmapHeight 15 --plotTitle "DMSO peaks, DMSO sorted" \
--outFileSortedRegions bed_files/RP_dTAG_ATACup_dDsorted_merged.bed

plotProfile -m results/DTmat_peakCentred_RPGCnorm_merged.gz \
-out plots/Profile_peakCentered_RPGCnorm_merged.pdf \
--samplesLabel "DMSO" "965a" "dBET" \
--plotTitle "DMSO peaks" --perGroup
