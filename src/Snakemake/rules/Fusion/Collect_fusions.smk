

rule Collect_fusions:
    input:
        bed = config["bed"]["bedfile"],
        arriba = "Arriba_results/{sample}.fusions.tsv",
        #starfusion = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.abridged.tsv",
        starfusion = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.abridged.coding_effect.tsv",
        fusioncatcher = "Results/RNA/{sample}/Fusions/FusionCatcher_final-list_candidate-fusion-genes.hg19.txt",
        bam = "STAR2/{sample}Aligned.sortedByCoord.out.bam"
    output:
        fusions = "Results/RNA/{sample}/Fusions/Fusions_{sample}.tsv"
    params:
        coverage = "exon_coverage/{sample}_coverage_breakpoint.txt"
    #singularity:
        #config["singularity"]["python"]
    shell:
        "module load samtools && "
        "python3.6 src/Fusion_genes.py {input.bed} {input.arriba} {input.starfusion} {input.fusioncatcher} {input.bam} {output.fusions} {params.coverage}"
