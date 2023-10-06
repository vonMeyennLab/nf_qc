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
    PARAMETERS
======================================================================================== */
params.fastq_screen_conf = "/cluster/work/nme/software/config/fastq_screen.conf" // FastQ Screen config file directory
params.bisulfite         = false
bisulfite                = params.bisulfite
params.singlecell        = false
params.rrbs		         = false
params.pbat		         = false
params.verbose           = false
params.single_end        = false  // default mode is auto-detect. NOTE: params are handed over automatically  
params.help              = false

// If the option PBAT is selected, the bisulfite option will automatically be set to true
if(params.pbat){
    bisulfite = true
} 

// If the option RRBS is selected, the bisulfite option will automatically be set to true
if(params.rrbs){
    bisulfite = true
} 

params.fastqc_args       = ''
params.fastq_screen_args = ''
params.trim_galore_args  = ''
params.multiqc_args      = ''


/* ========================================================================================
    MESSAGES
======================================================================================== */
// Show help message and exit
if (params.help){
    helpMessage()
    exit 0
}

if (params.verbose){
    println ("[WORKFLOW] FASTQC ARGS: "           + params.fastqc_args)
    println ("[WORKFLOW] FASTQ SCREEN ARGS ARE: " + params.fastq_screen_args)
    println ("[WORKFLOW] TRIM GALORE ARGS: "      + params.trim_galore_args)
    println ("[WORKFLOW] MULTIQC ARGS: "          + params.multiqc_args)
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
include { FASTQ_SCREEN }      from './modules/fastq_screen.mod.nf' params(fastq_screen_conf: params.fastq_screen_conf, bisulfite: bisulfite)
include { TRIM_GALORE }       from './modules/trim_galore.mod.nf'  params(singlecell: params.singlecell, rrbs: params.rrbs, pbat: params.pbat)
include { MULTIQC }           from './modules/multiqc.mod.nf' 

workflow {

    main:
        if (!params.skip_fastq_screen){ 

            if (!params.skip_trim_galore){

                FASTQC                      (file_ch, outdir, params.fastqc_args, params.verbose)
                FASTQ_SCREEN                (file_ch, outdir, params.fastq_screen_args, params.verbose)
                TRIM_GALORE                 (file_ch, outdir, params.trim_galore_args, params.verbose)
                FASTQC2                     (TRIM_GALORE.out.reads, outdir, params.fastqc_args, params.verbose)

            } else {

                FASTQC                      (file_ch, outdir, params.fastqc_args, params.verbose)
                FASTQ_SCREEN                (file_ch, outdir, params.fastq_screen_args, params.verbose)

            }    

        } else {

            if (!params.skip_trim_galore){

            FASTQC                      (file_ch, outdir, params.fastqc_args, params.verbose)
            TRIM_GALORE                 (file_ch, outdir, params.trim_galore_args, params.verbose)
            FASTQC2                     (TRIM_GALORE.out.reads, outdir, params.fastqc_args, params.verbose)

            } else {

            FASTQC                      (file_ch, outdir, params.fastqc_args, params.verbose)
            
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

            multiqc_ch = FASTQC.out.report()
            
            }

        }

        MULTIQC      (multiqc_ch, outdir, params.multiqc_args, params.verbose)
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
