

rule Exon_coverage:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
        bed = config["bed"]["bedfile"],
    output:
        coverage_all = "Results/RNA/{sample}/QC/Exon_gene_coverage_all.txt",
        coverage_low = "Results/RNA/{sample}/QC/Exon_gene_coverage_low.txt",
    log:
        "logs/Exon_coverage/{sample}.log",
    container:
        config["singularity"].get("Python_samtools", config["singularity"].get("default", ""))
    shell:
        "python src/Exon_coverage.py {input.bam} {input.bed} {output.coverage_all} {output.coverage_low}"
