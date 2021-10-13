
rule MarkDuplicates:
    input:
        bam="STAR2/{sample}_Aligned.sortedByCoord.out.bam",
        bai="STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        bam=temp("ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.bam"),
    params:
        metric=temp("ID_SNPs/{sample}_DuplicationMetrics.txt"),
    log:
        "logs/ID_SNPs/MarkDup/{sample}.dedup.log",
    threads: 2
    container:
        config["singularity"].get("picard", config["singularity"].get("default", ""))
    shell:
        "(picard MarkDuplicates INPUT={input.bam} OUTPUT={output.bam} METRICS_FILE={params.metric}) &> {log}"


rule Index_dedup:
    input:
        bam="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.bam",
    output:
        bai=temp("ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.bam.bai"),
    log:
        "logs/ID_SNPs/Index_dedup/{sample}.log",
    container:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools index {input.bam}) &> {log}"


rule SplitNCigarReads:
    input:
        bam="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.bam",
        bai="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.bam.bai",
        ref=config["reference"]["ref"],
    output:
        bam=temp("ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.splitN.bam"),
    log:
        "logs/ID_SNPs/SplitNCigarReads/{sample}.log",
    container:
        config["singularity"].get("gatk4", config["singularity"].get("default", ""))
    shell:
        "(gatk  --java-options '-Xmx6g' SplitNCigarReads -R {input.ref} -I {input.bam} -O {output.bam}) &> {log}"


rule Index_splitN:
    input:
        bam="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.splitN.bam",
    output:
        bai=temp("ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.splitN.bam.bai"),
    log:
        "logs/ID_SNPs/Index_splitN/{sample}.log",
    container:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools index {input.bam}) &> {log}"


rule Haplotypecaller:
    input:
        bam="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.splitN.bam",
        bai="ID_SNPs/{sample}_Aligned.sortedByCoord.dedup.splitN.bam.bai",
        bed=config["bed"]["ID_SNPs"],
        reference=config["reference"]["picard_ref"],
    output:
        vcf="ID_SNPs/{sample}.vcf.gz",
        vcf_tbi="ID_SNPs/{sample}.vcf.gz.tbi",
    log:
        "logs/ID_SNPs/Haplotypecaller/{sample}.log",
    container:
        config["singularity"].get("gatk4", config["singularity"].get("default", ""))
    shell:
        "(gatk --java-options '-Xmx6g' HaplotypeCaller -R {input.reference} -I {input.bam} "
        "-L {input.bed} --output {output.vcf}) &> {log}"
