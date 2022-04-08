---
title: Running Twist_RNA
---

The following steps should be undertaken in order to run `Twist_RNA`.

## Set up `samples.tsv`

`samples.tsv` file should have three tab separated columns without any column headers and should look like the following:

```tsv
Sample_name1	Path/to/fastq/R1.fastq.gz	Path/to/fastq/R2.fastq.gz
Sample_name2	Path/to/fastq/R1.fastq.gz	Path/to/fastq/R2.fastq.gz
```

This file should be saved to the project directory (`/home/lauri/Desktop/Twist_RNA/`)

## Run config file creator pipeline

The config file called `/home/lauri/Desktop/Twist_RNA/Twist_RNA.yaml` should be recreated for each run with new samples. It can be created after adjusting the `samples.tsv` file by running a short snakemake script from the project directory:

```bash
make config
```

In the recreated `Twist_RNA.yaml` file you should now see the new samples listed in the last rows:

```yaml
RNA_Samples:
    SeraSeq_Fusionv4-Pool1: "S1"
    SeraSeq_Fusionv4-Pool2: "S2"
```

## Run the main snakemake pipeline

The main snakemake pipeline can be run now from the project directory using command:

```bash
make
```

For one `SeraSeq_Fusionv4-Pool1` sample the run has taken approximately 3 hours. The results of the run will appear in the same directory. 

## (Optional) Gather all results files into one directory

Once the main snakemake pipeline has run, it may be nice to have all the results files in one aptly named directory. The  This can be achieved with command:

```bash
make move ALL_RESULTS_DIR=OUT
```

Note: Replace the word `OUT` in the previous command with a name of directory you wish to gather the results files into, e.g. `2022_04_11_SeraSeq_Fusionv4-Pool1`. Note also that there should **NOT** be any spaces on either side of the `=` sign.
