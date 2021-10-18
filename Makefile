SHELL = /bin/bash
.ONESHELL:
#.SHELLFLAGS := -eu -o pipefail -c
.SHELLFLAGS := -e -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

CURRENT_CONDA_ENV_NAME = snakemake
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate $(CURRENT_CONDA_ENV_NAME)

CPUS = 90

ARGS = --forceall

.PHONY: resume, \
config, \
run, \
clean, \
report, \
help

## resume: Continue running the pipeline
resume: 
	@($(CONDA_ACTIVATE); \
	snakemake -p -j 1 -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml_fastq.smk; \
	snakemake --printshellcmds --cores $(CPUS) -s ./Twist_RNA.smk --use-singularity --singularity-args "--bind /data " --cluster-config Config/Slurm/cluster.json)

## config: Create config file
config: 
	@($(CONDA_ACTIVATE); \
	snakemake -p -j 1 -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml_fastq.smk $(ARGS))

## run: Run the pipeline from scracth
run:
	@($(CONDA_ACTIVATE); \
	snakemake --printshellcmds $(ARGS) --cores $(CPUS) -s ./Twist_RNA.smk --use-singularity --singularity-args "--bind /data " --cluster-config Config/Slurm/cluster.json)

## clean: Remove the pipeline's output files
clean:
	rm -rf STAR/ STAR_fusion/ STAR2/ fusioncatcher/ exon_coverage/ Results/ Arriba_results/

## report: Create a snakemake report
report:
	@($(CONDA_ACTIVATE); \
	snakemake -j 1 --report report.html -s ./Twist_RNA.smk)

## help: Show this message
help:
	@grep '^##' ./Makefile	