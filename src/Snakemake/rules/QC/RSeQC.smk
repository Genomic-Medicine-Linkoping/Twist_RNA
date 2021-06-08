rule bam_stat:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        stats = "Results/RNA/{sample}/QC/RSeQC_bam_stat.txt",
    log:
        "logs/QC/bam_stat/{sample}.log",
    container:
        config["singularity"].get("rseqc", config["singularity"].get("default", ""))
    shell:
        "(bam_stat.py -i {input.bam} > {output.stats}) &> {log}"


rule collect_bam_stat:
    input:
        stat_files = ["Results/RNA/" + s + "/QC/RSeQC_bam_stat.txt" for s in config["RNA_Samples"]],
    output:
        stat_file = "Results/RNA/Bam_stats.txt",
    log:
        "logs/QC/bam_stat_collect.log",
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/collect_bam_stat.py {output.stat_file} {input.stat_files}) &> {log}"


rule FPKM_count:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
        bed = config["bed"]["fpkm"],
    output:
        xls = "Results/RNA/{sample}/QC/RSeQC.FPKM.xls",
    params:
        outprefix = "Results/RNA/{sample}/QC/RSeQC",
    log:
        "logs/QC/FPKM/{sample}.log",
    container:
        config["singularity"].get("rseqc", config["singularity"].get("default", ""))
    shell:
        "(FPKM_count.py -i {input.bam} -o {params.outprefix} -r {input.bed}) &> {log}"
