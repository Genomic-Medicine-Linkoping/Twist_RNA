.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS := -e -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

CURRENT_CONDA_ENV_NAME = Twist_RNA
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
CURRENT_CONDA_ENV_NAME = Twist_RNA
ACTIVATE_CONDA = source $$(conda info --base)/etc/profile.d/conda.sh
CONDA_ACTIVATE = $(ACTIVATE_CONDA) ; conda activate ; conda activate $(CURRENT_CONDA_ENV_NAME)


CPUS = 92

ARGS = --forceall

RESULTS_FILES = \
fastq/ \
STAR/ \
STAR_fusion/ \
STAR2/ \
fusioncatcher/ \
exon_coverage/ \
Results/ \
Arriba_results/ \
qc/ \
ID_SNPs/ \
logs/ \
nr_reads.txt \
report.html

ALL_RESULTS_DIR = 2022_01_21_SeraSeq_Fusionv4-Pool1
ARCHIVE_DIR = /data/Twist_RNA/results/

.PHONY: \
run \
config \
run \
clean \
move \
report \
help \
archive

## run: Continue running the pipeline
run:
	$(CONDA_ACTIVATE)
	snakemake --printshellcmds \
	--cores $(CPUS) \
	-s ./Twist_RNA.smk \
	--use-singularity \
	--singularity-args "--bind /data/Twist_RNA --bind /data/Twist_DNA" \
	--cluster-config Config/Slurm/cluster.json \
	$(ARGS)

## config: Create config file
config:
	$(CONDA_ACTIVATE)
	snakemake -p -j 1 -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml_fastq.smk $(ARGS)

## update: Update used conda environment based on env.yml
update_env:
	$(ACTIVATE_CONDA)
	mamba env update --file env.yml

## report: Create a snakemake report
report:
	$(CONDA_ACTIVATE)
	snakemake -j 1 --report report.html -s ./Twist_RNA.smk

## move: Gather all results files into one directory
move:
	mkdir -p $(ALL_RESULTS_DIR)
	mv $(RESULTS_FILES) $(ALL_RESULTS_DIR)
	cp samples.tsv Twist_RNA.yaml $(ALL_RESULTS_DIR)

## archive: Move all results files into a larger storage space
archive:
	mv $(ALL_RESULTS_DIR) $(ARCHIVE_DIR)

## help: Show this message
help:
	@grep '^##' ./Makefile

## clean: Remove the pipeline's output files
clean:
	rm -rf $(RESULTS_FILES)
