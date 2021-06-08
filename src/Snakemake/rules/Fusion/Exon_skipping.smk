
rule Exon_skipping:
    input:
        bed=config["bed"]["bedfile"],
        junction="STAR/{sample}_SJ.out.tab",
    output:
        results="Results/RNA/{sample}/Fusions/{sample}_exon_skipping.txt",
    log:
        "logs/Fusion/{sample}_exon_skipping.log"
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/Exon_skipping.py {input.bed} {input.junction} {output.results}) &> {log}"
