# Twist_RNA
**Run the pipeline with demultiplexning in Uppsala: <br>**
git clone https://github.com/clinical-genomics-uppsala/Twist_RNA.git . <br>
git checkout develop <br>
module add snakemake <br>
module add slurm-drmaa <br>
module add singularity <br>
snakemake -p -j 1 --drmaa "-A wp1 -p core -n 1 -t 2:00:00 "  -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml.smk <br>
snakemake -p -j 80 --drmaa "-A wp1 -p core -n {cluster.n} -t {cluster.time}" -s ./Twist_RNA.smk --use-singularity --singularity-args "--bind /data --bind /projects --bind /scratch " --cluster-config Config/Slurm/cluster.json <br>

**Run the pipeline from Fastq-files anywhere: <br>**
cd <analysis_dir> <br>
git clone https://github.com/clinical-genomics-uppsala/Twist_RNA.git . <br>
git checkout develop <br> <br>
Create samples.csv with the following format: <br>
Sample_name1\tPath/to/fastq/R1.fastq.gz\tPath/to/fastq/R2.fastq.gz <br>
Sample_name2\tPath/to/fastq/R1.fastq.gz\tPath/to/fastq/R2.fastq.gz <br> <br>
Adapt Config/Pipeline/configdefaults201012.yaml to your system by providing paths to the references needed<br> <br>
Create Twist_RNA.yaml with the following command:  <br>
snakemake -p -j 1 --drmaa "-A wp1 -p core -n 1 -t 2:00:00 "  -s ./src/Snakemake/rules/Twist_RNA_yaml/Twist_RNA_yaml_fastq.smk <br> <br>
Run pipeline with a command similar to this with bind points and -A adapted to your system: #Use screen or similar! <br>
snakemake -p -j 80 --drmaa "-A wp1 -p core -n {cluster.n} -t {cluster.time}" -s ./Twist_RNA.smk --use-singularity --singularity-args "--bind /data --bind /projects --bind /scratch " --cluster-config Config/Slurm/cluster.json <br> <br>

**Reference files: #Or get them directly from us to get exactly the same versions**
Arriba Star reference files (Needs 8 cores and 45Gb memory):<br>
mkdir /path/to/references<br>
singularity exec -B /path/to/references:/references docker://uhrigs/arriba:2.1.0 download_references.sh GRCh37+RefSeq <br> <br>
Star-fusion reference files:<br>
Download from: https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/__genome_libs_StarFv1.9/ <br> <br>
FusionCatcher:<br>
See instructions on Fusioncatcher github or follow commands in:<br>
https://github.com/ndaniel/fusioncatcher/blob/master/data/download-human-db.sh <br>
