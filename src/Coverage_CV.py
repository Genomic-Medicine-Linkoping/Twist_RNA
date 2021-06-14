
import statistics
import sys

input_bed = open(sys.argv[1])
input_coverage = open(sys.argv[2])
output_CV = open(sys.argv[3], "w")

#input_bed = open("/home/jonas/Snakemake/TSO500/DATA/TSO500_exon_regions.txt")
#input_coverage = open("/home/jonas/Investigations/Twist_RNA/R20-246_coverage.tsv")
#output_CV = open("/home/jonas/Investigations/Twist_RNA/R20-246_avg_CV_genes_over_500X.tsv", "w")

#output_CV.write("Average CV for gene over 500X coverage\n")

#Read in all exon regions in design
chr_gene_dict = {}
for line in input_bed :
    lline = line.strip().split("\t")
    chrom = lline[0]
    start_pos = int(lline[1])
    end_pos = int(lline[2])
    exon = lline[3]
    gene = exon.split("_")[0]
    if chrom not in chr_gene_dict :
        chr_gene_dict[chrom] = {}
    if gene not in chr_gene_dict[chrom] :
        chr_gene_dict[chrom][gene] = [end_pos - start_pos + 1, [[start_pos, end_pos]], 0 , []]
    else :
        chr_gene_dict[chrom][gene][0] += end_pos - start_pos + 1
        chr_gene_dict[chrom][gene][1].append([start_pos, end_pos])


#Read coverage info created by cartools
i = 0
for line in input_coverage :
    i += 1
    lline = line.strip().split("\t")
    chrom = lline[0]
    pos = int(lline[1])
    coverage = int(lline[2])
    if coverage == 0 :
        continue
    for gene in chr_gene_dict[chrom] :
        for region in chr_gene_dict[chrom][gene][1] :
            if pos >= region[0] and pos <= region[1] :
                chr_gene_dict[chrom][gene][2] += coverage
                chr_gene_dict[chrom][gene][3].append(coverage)
                break

#Calculate the average CV (Coefficient of Variation = stdev / mean) for genes with average coverage above 500X
nr_CV = 0
sum_CV = 0
for chrom in chr_gene_dict :
    for gene in chr_gene_dict[chrom] :
        avg_coverage = chr_gene_dict[chrom][gene][2] / float(chr_gene_dict[chrom][gene][0])
        if avg_coverage > 500 :
            stdev = statistics.stdev(chr_gene_dict[chrom][gene][3])
            CV = stdev / avg_coverage
            nr_CV += 1
            sum_CV += CV
            print(chrom, gene, statistics.stdev(chr_gene_dict[chrom][gene][3]), chr_gene_dict[chrom][gene][2], chr_gene_dict[chrom][gene][0], chr_gene_dict[chrom][gene][2] / float(chr_gene_dict[chrom][gene][0]), statistics.stdev(chr_gene_dict[chrom][gene][3]) / (chr_gene_dict[chrom][gene][2] / float(chr_gene_dict[chrom][gene][0])))
if nr_CV > 0 :
    avg_CV = sum_CV / float(nr_CV)
else :
    avg_CV = 0

output_CV.write(str(avg_CV) + "\n")
