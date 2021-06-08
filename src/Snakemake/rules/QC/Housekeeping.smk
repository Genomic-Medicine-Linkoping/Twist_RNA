

rule Housekeeping_coverage:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
        bed = config["bed"]["bedfile"],
    output:
        coverage = "Results/RNA/{sample}/QC/Housekeeping_gene_coverage.txt",
    log:
        "logs/Housekeeping_coverage/{sample}.log",
    container:
        config["singularity"].get("Python_samtools", config["singularity"].get("default", ""))
    shell:
        "(python src/HK_gene_coverage.py {input.bam} {input.bed} {output.coverage}) &> {log}"
