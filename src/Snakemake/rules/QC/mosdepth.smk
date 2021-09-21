
rule mosdepth:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bed = config["bed"]["bedfile"],
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        region_coverage = "qc/{sample}/{sample}.regions.bed.gz",
    params:
        extra = "-n -x ",
        out_prefix = "qc/{sample}/{sample}",
    log:
        "logs/qc/mosdepth/{sample}.mosdepth.log"
    singularity:
        config["singularity"].get("mosdepth", config["singularity"].get("default", ""))
    shell:
        "(mosdepth {params.extra} -b {input.bed} {params.out_prefix} {input.bam}) &> {log}"
