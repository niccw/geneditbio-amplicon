#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { FASTQC as FASTQC_RAW; FASTQC as FASTQC_TRIMMED } from './modules/nf-core/modules/fastqc/main.nf'  
include { MULTIQC as MULTIQC_RAW; MULTIQC as MULTIQC_TRIMMED } from './modules/nf-core/modules/multiqc/main.nf'
include { FASTP } from './modules/nf-core/modules/fastp/main.nf'

include { fastqScreen } from './modules/local/fastqScreen.nf'
include { crispresso } from './modules/local/crispresso2.nf'

log.info "Input directory: ${params.inputDir}"


ch_raw_short_reads = Channel.fromFilePairs(params.inputDir +'/*_{R1,R2}_*.fastq.gz', size: params.single_end ? 1 : 2)
	.ifEmpty { exit 1, "Cannot find any reads matching: ${params.inputDir}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
	.map { row ->
			def meta = [:]
			meta.id           = row[0]
			meta.group        = 0
			meta.single_end   = params.single_end
			return [ meta, row[1] ]
		}

undetermined_reads = Channel.fromFilePairs(params.inputDir +'/Undetermined*_{R1,R2}_*.fastq.gz', size: params.single_end ? 1 : 2)
	.ifEmpty { exit 1, "Cannot find any reads matching: ${params.inputDir}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
	.map { row ->
			def meta = [:]
			meta.id           = row[0]
			meta.group        = 0
			meta.single_end   = false
			return [ meta, row[1] ]
		}


workflow {

    // QC: raw reads
	FASTQC_RAW(ch_raw_short_reads)
	fastqScreen(undetermined_reads)
	MULTIQC_RAW(FASTQC_RAW.out.zip.map{it[1]}.mix(fastqScreen.out.screen_txt).collect())
	
	
	// Filtering and adapter trimming
	ch_raw_short_reads_work = ch_raw_short_reads.filter{ meta,p -> !((meta.id).contains("Undetermined"))}
	FASTP(ch_raw_short_reads_work,false,false)
	FASTQC_TRIMMED(FASTP.out.reads)
	MULTIQC_TRIMMED(FASTQC_TRIMMED.out.zip.map{it[1]}.collect())

	// Crispresso
	crispresso(FASTP.out.reads)


}