
rule cartool:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bed = config["bed"]["bedfile"],
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        statstable = "qc/{sample}/{sample}_Stat_table.csv",
        cartoollog =  "qc/{sample}/{sample}_Log.csv",
        coverage = "qc/{sample}/{sample}_coverage.tsv",
        full = "qc/{sample}/{sample}_MeanCoverageFullList.csv",
        short = "qc/{sample}/{sample}_MeanCoverageShortList.csv",
    params:
        user = "Jonas",
        coverage = config["cartool"]["cov"],
        extra = "-k",
    log:
        "logs/qc/CARTool/{sample}.cartool.log"
    singularity:
        config["singularity"].get("cartool", config["singularity"].get("default", ""))
    shell:
        "(python /opt/CARtool/ProgramLancher.py -a {input.bed} -b {input.bam} -c {params.coverage} -e {params.user} -o qc/{wildcards.sample}/ {wildcards.sample} {params.extra} )&> {log}"
