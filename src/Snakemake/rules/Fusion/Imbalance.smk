
rule imbalance :
    input:
        bams = ["STAR2/" + s + "Aligned.sortedByCoord.out.bam" for s in config["RNA_Samples"]]
    output:
        imbalance_all = "Results/RNA/Imbalance/imbalance_all_gene.txt",
        imbalance = "Results/RNA/Imbalance/imbalance_called_gene.txt"
    run:
        import subprocess
        subprocess.call("python src/Imbalance.py " + " ".join(input.bams), shell=True)
