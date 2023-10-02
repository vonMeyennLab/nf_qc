# Sequencing QC Pipeline

<img width="40%" src="https://raw.githubusercontent.com/nextflow-io/trademark/master/nextflow2014_no-bg.png" /></br>

A Nextflow pipeline to perform quality control of sequencing data.


### Pipeline steps
1. [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)</br>
2. [FastQ Screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)</br>
3. [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)</br>
4. [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)


### Required parameters

`--input` _Path to the folder where the FASTQ files are located. For example: /cluster/work/nme/data/josousa/project/fastq/*fastq.gz_</br>
`--outdir` _output directory where the files will be saved._


### Optional parameters
- Option to provide a custom FastQ Screen config file.</br>
`--fastq_screen_conf` _[default: /cluster/work/nme/software/config/fastq_screen.conf]_</br>

- Option to pass the option --bisulfite to FastQ Screen. This will result with FastQ Screen having the arguments: fastq_screen_args='--bisulfite'</br>
`--bisulfite`</br>

- Option to define sequencing data as **single-cell**. This will result with Trim Galore having the arguments: trim_galore_args='--clip_R1 6 --clip_R2 6'</br>
`--singlecell`</br>

- Option to define sequencing data as **PBAT**. This will result with Trim Galore having the arguments: trim_galore_args='--clip_R1 9 --clip_R2 9'</br>
`--pbat`</br>

- Option to define sequencing data as **RRBS**. This will result with Trim Galore having the arguments: trim_galore_args='--rrbs'</br>
`--rrbs`</br>

- Option to skip FastQ Screen: </br>
`--skip_fastq_screen`</br>

- Option to skip FastQ Screen: </br>
`--skip_trim_galore`
