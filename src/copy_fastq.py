
import sys
import subprocess

sample_file = open(sys.argv[1])

for line in sample_file :
    lline = line.strip().split("\t")
    sample = lline[0]
    R1 = lline[1]
    R2 = lline[2]
    subprocess.call("cp " + R1 + " fastq/RNA/" + sample + "_R1.fastq.gz", shell=True)
    subprocess.call("cp " + R2 + " fastq/RNA/" + sample + "_R2.fastq.gz", shell=True)
