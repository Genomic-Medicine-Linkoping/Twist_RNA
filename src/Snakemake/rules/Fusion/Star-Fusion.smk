
rule STAR:
    input:
        fq1 = "fastq/RNA/{sample}_R1.fastq.gz",
        fq2 = "fastq/RNA/{sample}_R2.fastq.gz",
    output:
        alignment = "STAR2/{sample}_Chimeric.out.junction",
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
    params:
        index = config["reference"]["STAR"],
    log:
        "logs/Star_fusion/STAR/{sample}.log",
    container:
        config["singularity"].get("STAR_fusion", config["singularity"].get("default_starfusion", ""))
    threads: 5
    shell:
        "(STAR "
        "--genomeDir {params.index} "
        "--readFilesIn {input.fq1} {input.fq2} "
        "--outReadsUnmapped None "
        "--twopassMode Basic "
        "--readFilesCommand \"gunzip -c\" "
        "--outSAMstrandField intronMotif "  # include for potential use with StringTie for assembly
        "--outSAMtype BAM SortedByCoordinate "
        "--outSAMattrRGline ID:Twist_RNA SM:{wildcards.sample} PL:ILLUMINA "
        "--outSAMunmapped Within "
        "--chimSegmentMin 12 "  # ** essential to invoke chimeric read detection & reporting **
        "--chimJunctionOverhangMin 12 "
        "--chimOutJunctionFormat 1 "   # **essential** includes required metadata in Chimeric.junction.out file.
        "--alignSJDBoverhangMin 10 "
        "--alignMatesGapMax 100000 "   # avoid readthru fusions within 100k
        "--alignIntronMax 100000 "
        "--alignSJstitchMismatchNmax 5 -1 5 5 "   # settings improved certain chimera detections
        "--chimMultimapScoreRange 3 "
        "--chimScoreJunctionNonGTAG -4 "
        "--chimMultimapNmax 20 "
        "--chimNonchimScoreDropMin 10 "
        "--peOverlapNbasesMin 12 "
        "--peOverlapMMp 0.1 "
        "--runThreadN {threads} "
        "--outFileNamePrefix STAR2/{wildcards.sample}_) &> {log}"


rule STAR_index:
    input:
        bam = "STAR2/{sample}_Aligned.sortedByCoord.out.bam",
    output:
        bai = "STAR2/{sample}_Aligned.sortedByCoord.out.bam.bai",
    log:
        "logs/Star_fusion/bam_index/{sample}.log",
    container:
        config["singularity"].get("samtools", config["singularity"].get("default", ""))
    shell:
        "(samtools index {input.bam}) &> {log}"


rule STAR_Fusion:
    input:
        alignment = "STAR2/{sample}_Chimeric.out.junction",
        fq1 = "fastq/RNA/{sample}_R1.fastq.gz",
        fq2 = "fastq/RNA/{sample}_R2.fastq.gz",
    output:
        fusion = "STAR_fusion/{sample}/Fusions/star-fusion.fusion_predictions.abridged.coding_effect.tsv",
        html = "STAR_fusion/{sample}/Fusions/FusionInspector-inspect/finspector.fusion_inspector_web.html",
    params:
        ref = config["reference"]["STAR_fusion"],
        out_FI_dir = "STAR_fusion/{sample}/Fusions/FusionInspector-inspect/",
    log:
        "logs/Star_fusion/Star_fusion/{sample}.log",
    container:
        config["singularity"].get("STAR_fusion", config["singularity"].get("default_starfusion", ""))
    threads: 5
    shell:
        "set +e; "
        "(STAR-Fusion "
        "--genome_lib_dir {params.ref} "
        "-J {input.alignment} "
        "--output_dir STAR_fusion/{wildcards.sample}/Fusions/ "
        "--CPU {threads} "
        "--left_fq {input.fq1} "
        "--right_fq {input.fq2} "
        "--examine_coding_effect "
        "--FusionInspector inspect "
        " && mkdir -p {params.out_FI_dir}"
        " && touch {output.html}) &> {log}; "
        #"exitcode=$?; "
        #"if [ $exitcode -eq 1 ]; then exit 1; else touch {output.html}; touch {output.fusion}; exit 0; fi "


rule Copy_STAR_to_results:
    input:
        #STAR_fusion1 = "STAR_fusion/{sample}/Fusions/star-fusion.fusion_predictions.tsv",
        STAR_fusion2 = "STAR_fusion/{sample}/Fusions/star-fusion.fusion_predictions.abridged.coding_effect.tsv",
        html = "STAR_fusion/{sample}/Fusions/FusionInspector-inspect/finspector.fusion_inspector_web.html",
    output:
        #STAR_fusion1 = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.tsv",
        STAR_fusion2 = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.abridged.coding_effect.tsv",
        html = "Results/RNA/{sample}/Fusions/Fusion_inspector_web.html",
    shell:
        #"cp {input.STAR_fusion1} {output.STAR_fusion1} && "
        "cp {input.STAR_fusion2} {output.STAR_fusion2} && "
        "cp {input.html} {output.html}"


# rule Star_fusion_validate:
#     input:
#         fusion = "Results/RNA/{sample}/Fusions/star-fusion.fusion_predictions.abridged.tsv",
#         fq1 = "fastq/RNA/{sample}_R1.fastq.gz",
#         fq2 = "fastq/RNA/{sample}_R2.fastq.gz"
#     output:
#         #fusion = "Results/RNA/{sample}/Fusions/finspector.FusionInspector.fusions.abridged.tsv"
#         fusion = "FI/{sample}/inspector.FusionInspector.fusions.abridged.tsv"
#     singularity:
#         config["singularity"]["STAR_fusion"]
#     shell:
#         "/usr/local/src/STAR-Fusion/FusionInspector/FusionInspector --fusions {input.fusion} "
#         "--genome_lib /projects/wp4/nobackup/workspace/jonas_test/STAR-Fusion/references/GRCh37_gencode_v19_CTAT_lib_Apr032020.plug-n-play/ctat_genome_lib_build_dir/ "
#         "--left_fq {input.fq1} "
#         "--right_fq {input.fq2} "
#         "--output_dir FI/{wildcards.sample} "
#         "--vis --examine_coding_effect"
