
if config["Demultiplex"] :
    include: "../rules/Fastq/demultiplex.smk"
    include: "../rules/Fastq/fix_fastq_RNA.smk"
else :
    include: "../rules/Fastq/copy_fastq_RNA.smk"
include: "../rules/Fusion/Arriba.smk"
include: "../rules/Fusion/Imbalance.smk"
#include: "../rules/Fusion/exon_splicing.smk"
include: "../rules/Fusion/Star-Fusion.smk"
include: "../rules/Fusion/FusionCatcher.smk"
include: "../rules/Fusion/Collect_fusions.smk"
include: "../rules/Fusion/Exon_skipping.smk"
#include: "../rules/QC/RSeQC.smk"
include: "../rules/QC/samtools-picard-stats.smk"
include: "../rules/QC/multiqc.smk"
#include: "../rules/QC/cartool.smk"
include: "../rules/QC/mosdepth.smk"
include: "../rules/QC/fastqc.smk"
include: "../rules/QC/Exon_coverage.smk"
include: "../rules/QC/Housekeeping.smk"
include: "../rules/ID_SNPs/ID_SNPs_calling.smk"
