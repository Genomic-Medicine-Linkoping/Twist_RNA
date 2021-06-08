
localrules: Arriba_HC, Arriba_IGV_bat


rule STAR_arrbia:
    input:
        fastq1 = "fastq/RNA/{sample}_R1.fastq.gz",
        fastq2 = "fastq/RNA/{sample}_R2.fastq.gz",
    output:
        bam = "STAR/{sample}_Aligned.sortedByCoord.out.bam",
        junctions = "STAR/{sample}_SJ.out.tab",
    params:
        index = config["reference"]["Arriba_index"],
    log:
        "logs/Arriba/STAR/{sample}.log",
    container:
        config["singularity"].get("Arriba", config["singularity"].get("default_arriba", ""))
    threads: 5
    shell:
        "(STAR "
    	"--runThreadN {threads} "
    	"--genomeDir {params.index} "
        "--genomeLoad NoSharedMemory "
    	"--readFilesIn {input.fastq1} {input.fastq2} "
        "--readFilesCommand zcat "
        "--outSAMtype BAM SortedByCoordinate "
        "--outSAMunmapped Within "
    	"--outFilterMultimapNmax 1 "
        "--outFilterMismatchNmax 3 "
    	"--chimSegmentMin 10 "
        "--chimOutType WithinBAM SoftClip "
        "--chimJunctionOverhangMin 10 "
        "--chimScoreMin 1 "
        "--chimScoreDropMax 30 "
        "--chimScoreJunctionNonGTAG 0 "
        "--chimScoreSeparation 1 "
        "--alignSJstitchMismatchNmax 5 -1 5 5 "
        "--chimSegmentReadGapMax 3 "
        "--outFileNamePrefix STAR/{wildcards.sample}_) &> {log}"


rule STAR_arrbia_index:
    input:
        bam = "STAR/{sample}_Aligned.sortedByCoord.out.bam",
    output:
        bai = "STAR/{sample}_Aligned.sortedByCoord.out.bam.bai",
    log:
        "logs/Arriba/bam_index/{sample}.log",
    container:
        config["singularity"].get("samtools", config["singularity"].get("default_arriba", ""))
    shell:
        "(samtools index {input.bam}) &> {log}"


rule Arriba:
    input:
        bam = "STAR/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        fusions1 = "Arriba_results/{sample}.fusions.tsv",
        fusions2 = "Arriba_results/{sample}.fusions.discarded.tsv",
    params:
        ref = config["reference"]["Arriba_ref"],
        gtf = config["reference"]["Arriba_gtf"],
        blacklist = config["reference"]["Arriba_blacklist"],
    log:
        "logs/Arriba/Arriba/{sample}.log",
    container:
        config["singularity"].get("Arriba", config["singularity"].get("default_arriba", ""))
    shell:
        "(arriba "
    	"-x {input.bam} "
    	"-o {output.fusions1} "
        "-O {output.fusions2} "
    	"-a {params.ref} "
        "-g {params.gtf} "
        #"-b {params.blacklist} "
    	#"-T "
        #"-P) &> {log}"
        "-b {params.blacklist}) &> {log}"


rule Arriba_HC:
    input:
        fusions = "Arriba_results/{sample}.fusions.tsv",
        refseq = "DATA/refseq_full_hg19.txt",
    output:
        fusions1 = "Arriba_results/{sample}.Arriba.HighConfidence.fusions.tsv",
        fusions2 = "Results/RNA/{sample}/Fusions/Arriba.fusions.tsv",
    log:
        "logs/Arriba/HC/{sample}.log",
    container:
        config["singularity"].get("python", config["singularity"].get("default", ""))
    shell:
        "(head -n 1 {input.fusions} > {output.fusions1} && "
        "grep 'high' {input.fusions} >> {output.fusions1} || true && "
        "python src/Add_fusion_exon_name.py {input.refseq} {output.fusions1} && "
        "cp {input.fusions} {output.fusions2}) &> {log}"


rule Arriba_image:
    input:
        fusion = "Results/RNA/{sample}/Fusions/Arriba.fusions.tsv",
        bam = "STAR/{sample}_Aligned.sortedByCoord.out.bam",
        bai = "STAR/{sample}_Aligned.sortedByCoord.out.bam.bai",
    output:
        image = "Results/RNA/{sample}/Fusions/Arriba.fusions.pdf",
    params:
        image_out_path = "Results/RNA/{sample}/Fusions/",
        Arriba_singularity = config["singularity"].get("Arriba", config["singularity"].get("default_arriba", "")),
        ref = config["reference"]["Arriba_refdir"],
    log:
        "logs/Arriba/image/{sample}.log",
    run:
        import subprocess
        command = "singularity exec "
        command += "-B " + params.image_out_path + ":/output "
        command += "-B " + params.ref + ":/references:ro "
        command += "-B " + input.fusion + ":/fusions.tsv:ro "
        command += "-B " + input.bam + ":/Aligned.sortedByCoord.out.bam:ro "
        command += "-B " + input.bai + ":/Aligned.sortedByCoord.out.bam.bai:ro "
        # command += params.Arriba_singularity + " "
        command += "docker://uhrigs/arriba:2.1.0 "
        command += "draw_fusions.sh"
        print(command)
        subprocess.call(command, shell=True)
        subprocess.call("mv " + params.image_out_path + "fusions.pdf " + output.image, shell=True)

#rule Arriba_IGV_bat:
#    input:
#        fusion = "Results/RNA/{sample}/{sample}.Arriba.HighConfidence.fusions.tsv",
#        bam = "STAR/{sample}Aligned.sortedByCoord.out.bam"
#    output:
#        bat = "Arriba_results/{sample}_IGV.bat"
#    run:
#        sample = output.bat.split("Arriba_results/")[1].split("_IGV")[0]
#        outfile = open(output.bat, "w")
#        outfile.write("new\n")
#        outfile.write("genome DATA/igv/genomes/hg19.genome\n")
#        outfile.write("load " + input.bam + "\n")
#        outfile.write("snapshotDirectory Arriba_results/" + sample + "/\n")
#        header = True
#        infile = open(input.fusion)
#        for line in infile :
#            if header:
#                header = False
#                continue
#            lline = line.strip().split("\t")
#            pos1 = "chr" + lline[4]
#            pos2 = "chr" + lline[5]
#            gene1 = lline[0]
#            gene2 = lline[1]
#            outfile.write("goto " + pos1 + " " + pos2 + "\n")
#            outfile.write("sort base\n")
#            outfile.write("squish\n")
#            outfile.write("preference SAM.SHOW_SOFT_CLIPPED true\n")
#            outfile.write("snapshot " + gene1 + "_" + gene2 + "_" + pos1.split(":")[0] + "_" + pos1.split(":")[1] + "_" + pos2.split(":")[0] + "_" + pos2.split(":")[1] + ".svg\n")
#        outfile.write("exit\n")
#        infile.close()
#        outfile.close()

#rule Arriba_IGV_run:
#    input:
#        bat = "Arriba_results/{sample}_IGV.bat"
#    output:
#        done_file = "Arriba_results/{sample}/IGV_done.txt"
#    singularity: "/projects/wp4/nobackup/workspace/somatic_dev/singularity/igv-2.4.10-0.simg"
#    shell:
#        "xvfb-run --server-args='-screen 0 3200x2400x24' --auto-servernum --server-num=1 igv.sh -b {input.bat} && touch {output.done_file}"
