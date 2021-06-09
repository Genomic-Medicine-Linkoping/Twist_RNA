

rule Collect_fusions:
    input:
        bed = config["bed"]["bedfile"],
        arriba = "Arriba_results/{sample}.fusions.tsv",
        starfusion = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.abridged.coding_effect.tsv",
        fusioncatcher = "Results/RNA/{sample}/Fusions/FusionCatcher_final-list_candidate-fusion-genes.hg19.txt",
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        fusions = "Results/RNA/{sample}/Fusions/Fusions_{sample}.tsv",
    params:
        coverage = "exon_coverage/{sample}_coverage_breakpoint.txt",
    log:
        "logs/Collect_fusions/{sample}.log",
    container:
        config["singularity"].get("Python_samtools", config["singularity"].get("default", ""))
    shell:
        "(python src/Fusion_genes.py {input.bed} {input.arriba} {input.starfusion} {input.fusioncatcher} {input.bam} {output.fusions} {params.coverage})  &> {log}"
