
rule ID_SNP_pileup:
    input:
        bam="STAR/{sample}_Aligned.sortedByCoord.out.bam",
        bai="STAR/{sample}_Aligned.sortedByCoord.out.bam.bai",
        bed=config["bed"]["ID_SNPs"],
        ref=config["reference"]["ref"],
    output:
        vcf="ID_SNPs/{sample}_ID_SNPs.vcf",
    params:
        annotation="-a DP,AD,ADF,ADR",
    log:
        "logs/ID_SNPs/ID_SNP_pileup/{sample}.log",
    container:
        config["singularity"].get("bcftools", config["singularity"].get("default", ""))
    shell:
        "(bcftools mpileup -g 0,1 {params.annotation} -R {input.bed} -f {input.ref} -O v -o {output.vcf} {input.bam}) &> {log}"
