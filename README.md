# Sequencing QC Pipeline

<img width="40%" src="https://raw.githubusercontent.com/nextflow-io/trademark/master/nextflow2014_no-bg.png" />

A Nextflow pipeline to perform quality control of sequencing data.

## Pipeline steps
1. [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
2. [FastQ Screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)
3. [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
4. [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
5. [MultiQC](https://multiqc.info/)

## Required parameters

Path to the folder where the FASTQ files are located. 
`--input`
``` bash
--input /cluster/work/nme/data/josousa/project/fastq/*fastq.gz
```


Output directory where the files will be saved.
`--outdir`
``` bash
--outdir /cluster/work/nme/data/josousa/project
```

## Optional parameters
- Option to provide a custom FastQ Screen config file.
`--fastq_screen_conf`
``` bash
# Default
--fastq_screen_conf /cluster/work/nme/software/config/fastq_screen.conf
```

- Option to pass the option --bisulfite to FastQ Screen. This will result with FastQ Screen having the arguments: fastq_screen_args='--bisulfite'.
`--bisulfite`

- Option to define sequencing data as **single-cell**. This will result with Trim Galore having the arguments: trim_galore_args='--clip_R1 6 --clip_R2 6'.
`--singlecell`

- Option to define sequencing data as **PBAT**. This will result with Trim Galore having the arguments: trim_galore_args='--clip_R1 9 --clip_R2 9'.
`--pbat`
    > If this option is selected, the optional parameter `--bisulfite` will automatically be set to `true`.

- Option to define sequencing data as **RRBS**. This will result with Trim Galore having the arguments: trim_galore_args='--rrbs'.
`--rrbs`
    > If this option is selected, the optional parameter `--bisulfite` will automatically be set to `true`.


## Skipping options
- Option to skip FastQ Screen. 
`--skip_fastq_screen`

- Option to skip Trim Galore. 
`--skip_trim_galore`


## Extra arguments
- Option to add extra arguments to the package [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).
`--fastqc_args`

- Option to add extra arguments to the package [FastQ Screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/).
`--fastq_screen_args`

- Option to add extra arguments to the package [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/).
`--trim_galore_args`

- Option to add extra arguments to the package [MultiQC](https://multiqc.info/).
`--multiqc_args`
