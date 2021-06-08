
rule copy_fastq_RNA:
    input:
        sample_file = "samples.tsv",
    output:
        fastq1 = ["fastq/RNA/" + s + "_R1.fastq.gz" for s in config["RNA_Samples"]],
        fastq2 = ["fastq/RNA/" + s + "_R2.fastq.gz" for s in config["RNA_Samples"]],
    shell:
        "python src/copy_fastq.py {input.sample_file}"
