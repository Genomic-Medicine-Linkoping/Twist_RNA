SHELL = /bin/bash

CURRENT_CONDA_ENV_NAME = snakemake
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate $(CURRENT_CONDA_ENV_NAME)

run: clean
	@($(CONDA_ACTIVATE); \
	snakemake -p -j 1 -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml_fastq.smk; \
	snakemake --printshellcmds --forceall --cores 80 -s ./Twist_RNA.smk --use-singularity --singularity-args "--bind /data " --cluster-config Config/Slurm/cluster.json)

clean:
	rm -rf STAR/ STAR_fusion/ STAR2/ fusioncatcher/ exon_coverage/ Results/ Arriba_results/