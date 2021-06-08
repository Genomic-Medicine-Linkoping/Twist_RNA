
import subprocess
import sys

bam_file = sys.argv[1]
bedfile = open(sys.argv[2])
outfile_all = open(sys.argv[3], "w")
outfile_low = open(sys.argv[4], "w")
outfile_all.write("Sample\tExon\tAverage_coverage(max_8000)\n")
outfile_low.write("Sample\tExon\tAverage_coverage\n")


for line in bedfile :
    lline = line.strip().split("\t")
    chrom = lline[0]
    start = lline[1]
    end = lline[2]
    exon = lline[3]
    coverage_sum = 0
    coverage_nr_pos = 0
    coverage_list = []
    region = chrom + ":" + start + "-" + end
    sample = bam_file.split("/")[-1].split(".bam")[0]
    cov_outfile_name = "DATA/RNA_gene_depth_" + sample + ".txt"
    subprocess.call("samtools depth -a -r " + region + " " + bam_file + " > " + cov_outfile_name, shell=True)
    depthfile = open(cov_outfile_name)
    coverage_sum = 0
    coverage_nr_pos = 0
    for line in depthfile :
        coverage = int(line.strip().split("\t")[2])
        coverage_sum += coverage
        coverage_nr_pos += 1
    if coverage_nr_pos == 0 :
        coverage_nr_pos = 1
    depthfile.close()
    avg_coverage = 0.0
    if coverage_nr_pos != 0 :
        avg_coverage = coverage_sum / float(coverage_nr_pos)
    outfile_all.write(sample + "\t" + exon + "\t" + str(round(avg_coverage,1)) + "\n")
    if avg_coverage < 500 :
        outfile_low.write(sample + "\t" + exon + "\t" + str(round(avg_coverage,1)) + "\n")
outfile_all.close()
outfile_low.close()
