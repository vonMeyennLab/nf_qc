# Sequencing QC Pipeline

<img width="30%" src="https://raw.githubusercontent.com/nextflow-io/trademark/master/nextflow2014_no-bg.png" />
<img width="30%" src="https://tower.nf/assets/nf-tower-black.svg" />

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

## Input optional parameters

- Option to force the pipeline to assign input as single-end.
`--single_end`

    _By default, the pipeline detects whether the input files are single-end or paired-end._

## FastQ Screen optional parameters

- Option to provide a custom FastQ Screen config file.
`--fastq_screen_conf`
    ``` bash
    # Default
    --fastq_screen_conf /cluster/work/nme/software/config/fastq_screen.conf
    ```

- Option to pass the option --bisulfite to FastQ Screen.
`--bisulfite`

## Sequencing method optional parameters

- Option to choose the sequencing method. This will adapt the default parameters to the method.
    ``` bash
    # PBAT
    --seq_method PBAT

    # RRBS
    --seq_method RRBS

    # Single-cell
    --seq_method Single-cell
    ```

The default parameters for each sequencing method.

PBAT: 
>fastq_screen_args='--bisulfite'<br>
>trim_galore_args='--clip_R1 9 --clip_R2 9'

RRBS:
>fastq_screen_args='--bisulfite'<br>
>trim_galore_args='--rrbs'

Single-cell:
>trim_galore_args='--clip_R1 6 --clip_R2 6'

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

## Additional information
The pipeline was created to run in the [ETH Euler cluster](https://scicomp.ethz.ch/wiki/Euler) and it relies on the [Lmod environmental modules](https://lmod.readthedocs.io/en/latest/) available in the cluster. Thus, the pipeline needs to be adapted before running it in another HPC cluster.

## Acknowledgements
This pipeline was adapted from the Nextflow pipelines created by the [Babraham Institute Bioinformatics Group](https://github.com/s-andrews/nextflow_pipelines) and from the [nf-core](https://nf-co.re/) pipelines. We thank all the contributors for both projects. We also thank the [Nextflow community](https://nextflow.slack.com/join) and the [nf-core community](https://nf-co.re/join) for all the help and support.
