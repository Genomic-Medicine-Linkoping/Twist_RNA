

localrules: all, Create_Twist_RNA_yaml_fastq

rule all:
    input:
        Twist_RNA_yaml = "Twist_RNA.yaml",


rule Create_Twist_RNA_yaml_fastq:
    input:
        samples = "samples.tsv", #Sample_name\tPath_to_fastq_R1\tPath_to_fastq_R2\n
        config = "Config/Pipeline/configdefaults201012.yaml",
    output:
        Twist_RNA_yaml = "Twist_RNA.yaml",
    run:
        import glob
        import os
        import subprocess
        subprocess.call("cp " + input.config + " " + output.Twist_RNA_yaml, shell=True)
        outfile = open(output.Twist_RNA_yaml, "a")
        outfile.write("\nDemultiplex: False\n")
        RNA_sample_list = []
        i = 1
        infile = open(input.samples)
        for line in infile:
            lline = line.strip().split("\t")
            sample = lline[0]
            if sample.find(" ") != -1 :
                print("incorrect sample name: " + sample)
                quit()
            RNA_sample_list.append([sample, i])
            i += 1
        outfile = open(output.Twist_RNA_yaml, "a")
        outfile.write("\nRNA_Samples:\n")
        for sample in RNA_sample_list :
            outfile.write("  " + sample[0] + ": \"S" + str(sample[1]) + "\"\n")
        outfile.close()
