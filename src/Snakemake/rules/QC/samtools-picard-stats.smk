localrules: touchBatch

rule samtools_stats:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam"
    output:
        "qc/{sample}/{sample}.samtools-stats.txt"
    params:
        extra = "-t "+ config["bed"]["bedfile"],
    log:
        "logs/qc/samtools_stats/{sample}.log"
    container:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools stats {params.extra} {input} > {output} ) &> {log}"
    # wrapper:
    #     "0.38.0/bio/samtools/stats"

rule picardHsMetrics:
    input:
        #bam = "DNA_bam/{sample}-ready.bam",
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        intervals = config["bed"]["intervals"]
    output:
        "qc/{sample}/{sample}.HsMetrics.txt"
    log:
        "logs/qc/picard/HsMetrics/{sample}.log"
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard CollectHsMetrics BAIT_INTERVALS={input.intervals} TARGET_INTERVALS={input.intervals} INPUT={input.bam} OUTPUT={output}) &> {log}"


rule picardInsertSize:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam"
    output:
        txt = "qc/{sample}/{sample}.insert_size_metrics.txt",
        pdf = "qc/{sample}/{sample}.insert_size_histogram.pdf"
    log:
        "logs/qc/picard/InsertSize/{sample}.log"
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard CollectInsertSizeMetrics INPUT={input.bam} O={output.txt} H={output.pdf}) &> {log}"


rule PicardAlignmentSummaryMetrics:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
	    ref = config["reference"]["picard_ref"]
    output:
        "qc/{sample}/{sample}.alignment_summary_metrics.txt",
    log:
        "logs/qc/picard/AlignmentSummaryMetrics/{sample}.log"
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard CollectAlignmentSummaryMetrics INPUT={input.bam} R={input.ref} OUTPUT={output}) &> {log}"

rule Coverage_CV :
    input:
        bed = config["bed"]["exonbed"],
        coverage = "qc/{sample}/{sample}_coverage.tsv",
    output:
        CV = "qc/{sample}/{sample}_avg_CV_genes_over_500X.txt",
    log:
        "logs/qc/picard/AlignmentSummaryMetrics/{sample}.log"
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/Coverage_CV.py {input.bed} {input.coverage} {output.CV}) &> {log}"


rule touchBatch:
    input:
        expand("STAR2/{sample}_Aligned.sortedByCoord.out.bam", sample = config["RNA_Samples"]),
    output:
         temp("qc/batchQC_stats_unsorted.csv"),
    log:
        "logs/touch.log"
    shell:
        "(touch {output}) &> {log}"


rule getStatsforMqc:
    input:
        picardMet1 = "qc/{sample}/{sample}.HsMetrics.txt",
        picardMet2 = "qc/{sample}/{sample}.insert_size_metrics.txt",
        picardMet3 = "qc/{sample}/{sample}.alignment_summary_metrics.txt",
        samtools = "qc/{sample}/{sample}.samtools-stats.txt",
        CV = "qc/{sample}/{sample}_avg_CV_genes_over_500X.txt",
        multiQCheader = "DATA/multiqc-header.txt",
        cartool = "qc/{sample}/{sample}_Log.csv",
        batch =  "qc/batchQC_stats_unsorted.csv",
    output:
        batchTmp = temp("qc/{sample}/{sample}_batchStats.done"),
        sample = "qc/{sample}/{sample}_stats_mqc.csv",
    log:
        "logs/qc/{sample}_stats.log"
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/get_stats.py {input.picardMet1} {input.picardMet2} {input.picardMet3} {input.samtools} {input.CV} {input.multiQCheader} {input.cartool} {wildcards.sample} {output.sample} {input.batch} && touch {output.batchTmp}) &> {log}"


rule sortBatchStats:
    input:
        SampleSheetUsed = "Twist_RNA.yaml",
        batchUnsorted = "qc/batchQC_stats_unsorted.csv",
        batchDone = expand("qc/{sample}/{sample}_batchStats.done", sample = config["RNA_Samples"]),
    output:
        batch = "qc/batchQC_stats_mqc.json",
    log:
        "logs/qc/sortBatch_Stats.log"
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(python src/sortBatchStats.py {input.batchUnsorted} {input.SampleSheetUsed} {output.batch}) &> {log}"
