
rule imbalance :
    input:
        bams = ["STAR2/" + s + "_Aligned.sortedByCoord.out.bam" for s in config["RNA_Samples"]],
        bais = ["STAR2/" + s + "_Aligned.sortedByCoord.out.bam.bai" for s in config["RNA_Samples"]],
    output:
        imbalance_all = "Results/RNA/Imbalance/imbalance_all_gene.txt",
        imbalance = "Results/RNA/Imbalance/imbalance_called_gene.txt",
    log:
        "logs/Fusions/imbalance.log"
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/Imbalance.py {input.bams}) &> {log}"
