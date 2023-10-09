#!/usr/bin/env nextflow
nextflow.enable.dsl=2


/* ========================================================================================
    INPUT FILES
======================================================================================== */
params.input = null
input_files  = file(params.input)


/* ========================================================================================
    OUTPUT DIRECTORY
======================================================================================== */
params.outdir = false
if(params.outdir){
    outdir = params.outdir
} else {
    outdir = '.'
}


/* ========================================================================================
    SKIP STEPS
======================================================================================== */
params.skip_fastq_screen = false
params.skip_trim_galore  = false


/* ========================================================================================
    DEFAULT PARAMETERS
======================================================================================== */
params.fastqc_args       = ''
params.fastq_screen_args = ''
params.trim_galore_args  = ''
params.multiqc_args      = ''

fastqc_args       = params.fastqc_args
fastq_screen_args = params.fastq_screen_args
trim_galore_args  = params.trim_galore_args
multiqc_args      = params.multiqc_args

// Force to input files to be  single-end
params.single_end = false

// Sequencing type
params.seqtype = ''

// FastQ Screen config file directory
params.fastq_screen_conf = "/cluster/work/nme/software/config/fastq_screen.conf" 

// FastQ Screen bisulfite parameter
params.bisulfite = false
bisulfite = params.bisulfite

// Trim Galore clip parameter
params.clip_r1 = false
params.clip_r2 = false
clip_r1        = params.clip_r1
clip_r2        = params.clip_r2


/* ========================================================================================
    TRIM GALORE PARAMETERS
======================================================================================== */

// PBAT
if(params.seqtype == 'PBAT'){
    clip_r1 = 9
    clip_r2 = clip_r1
    bisulfite = true

    trim_galore_args += " --clip_r1 $clip_r1 "
}

// RRBS
if(params.seqtype == 'RRBS'){
    bisulfite = true
    trim_galore_args += " --rrbs "
}

// SINGLE-CELL
if(params.seqtype == 'Single-cell'){
    clip_r1 = 6
    clip_r2 = clip_r1
    bisulfite = false

    trim_galore_args += " --clip_r1 $clip_r1 "
}


/* ========================================================================================
    FASTQ SCREEN PARAMETERS
======================================================================================== */

// BISULFITE
if (params.bisulfite){
	fastq_screen_args += " --bisulfite "
} else {
    if (bisulfite){
	fastq_screen_args += " --bisulfite "
    }
}


/* ========================================================================================
    FILES CHANNEL
======================================================================================== */
include { makeFilesChannel; getFileBaseNames } from './modules/files.mod.nf'
file_ch = makeFilesChannel(input_files)


/* ========================================================================================
    WORKFLOW
======================================================================================== */
include { FASTQC }            from './modules/fastqc.mod.nf'
include { FASTQC as FASTQC2 } from './modules/fastqc.mod.nf'
include { FASTQ_SCREEN }      from './modules/fastq_screen.mod.nf' params(fastq_screen_conf: params.fastq_screen_conf)
include { TRIM_GALORE }       from './modules/trim_galore.mod.nf'  params(clip_r2: clip_r2)
include { MULTIQC }           from './modules/multiqc.mod.nf'

workflow {

    main:
        if (!params.skip_fastq_screen){ 

            if (!params.skip_trim_galore){

                FASTQC        (file_ch, outdir, fastqc_args)
                FASTQ_SCREEN  (file_ch, outdir, fastq_screen_args)
                TRIM_GALORE   (file_ch, outdir, trim_galore_args)
                FASTQC2       (TRIM_GALORE.out.reads, outdir, fastqc_args)

            } else {

                FASTQC        (file_ch, outdir, fastqc_args)
                FASTQ_SCREEN  (file_ch, outdir, fastq_screen_args)

            }    

        } else {

            if (!params.skip_trim_galore){

            FASTQC      (file_ch, outdir, fastqc_args)
            TRIM_GALORE (file_ch, outdir, trim_galore_args)
            FASTQC2     (TRIM_GALORE.out.reads, outdir, fastqc_args)

            } else {

            FASTQC      (file_ch, outdir, fastqc_args)
            
            }

        }

         /* ========================================================================================
            Reports
        ======================================================================================== */       
        
        if (!params.skip_fastq_screen){ 

            if (!params.skip_trim_galore){

                multiqc_ch = FASTQC.out.report.mix(
                    TRIM_GALORE.out.report,
                    FASTQ_SCREEN.out.report.ifEmpty([]),
                    FASTQC2.out.report.ifEmpty([])
                ).collect()

            } else {

                multiqc_ch = FASTQC.out.report.mix(
                    FASTQ_SCREEN.out.report.ifEmpty([])
                ).collect()

            }    

        } else {

            if (!params.skip_trim_galore){

            multiqc_ch = FASTQC.out.report.mix(
                TRIM_GALORE.out.report,
                FASTQC2.out.report.ifEmpty([])
            ).collect()

            } else {

            multiqc_ch = FASTQC.out.report.collect()
            
            }

        }

        MULTIQC (multiqc_ch, outdir, multiqc_args)
}

workflow.onComplete {

    def msg = """\
        Pipeline execution summary
        ---------------------------
        Jobname     : ${workflow.runName}
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """
    .stripIndent()

    sendMail(to: "${workflow.userName}@ethz.ch", subject: 'Minimal pipeline execution report', body: msg)
}
