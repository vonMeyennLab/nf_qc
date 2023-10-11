#!/usr/bin/env nextflow
nextflow.enable.dsl=2


/* ========================================================================================
    PROCESSES
======================================================================================== */
process MULTIQC {

	label 'multiQC'

	input:
		path(file)
		val(outputdir)
		val(multiqc_args)

	output:
		path "*html", emit: html
		
		publishDir "$outputdir/qc", mode: "link", overwrite: true

	script:

		"""
		module load multiqc

		multiqc $multiqc_args -x ${NXF_WORK} --filename multiqc_report.html .
		"""
}
