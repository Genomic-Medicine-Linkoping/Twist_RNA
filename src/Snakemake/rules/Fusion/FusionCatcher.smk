

rule FusionCatcher:
    input:
        fastq1 = "fastq/RNA/{sample}_R1.fastq.gz",
        fastq2 = "fastq/RNA/{sample}_R2.fastq.gz",
    output:
        fusions1 = "Results/RNA/{sample}/Fusions/FusionCatcher_final-list_candidate-fusion-genes.hg19.txt",
        fusions2 = "Results/RNA/{sample}/Fusions/FusionCatcher_summary_candidate_fusions.txt",
    params:
        output_dir = "fusioncatcher/{sample}/",
        ref = config["reference"]["Fusion_catcher"],
        params = "--visualization-sam",
    log:
        "logs/FusionCatcher/{sample}.log",
    threads:
        10
    container:
        config["singularity"]["Fusion_catcher"]
    shell:
        "(/opt/fusioncatcher/v1.20/bin/fusioncatcher.py -d {params.ref} -i {input.fastq1},{input.fastq2} -o {params.output_dir} -p {threads} {params.params} && "
        "cp fusioncatcher/{wildcards.sample}/final-list_candidate-fusion-genes.hg19.txt Results/RNA/{wildcards.sample}/Fusions/FusionCatcher_final-list_candidate-fusion-genes.hg19.txt && "
        "cp fusioncatcher/{wildcards.sample}/summary_candidate_fusions.txt Results/RNA/{wildcards.sample}/Fusions/FusionCatcher_summary_candidate_fusions.txt) &> {log}"
