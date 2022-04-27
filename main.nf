#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { FASTQC as FASTQC_RAW; FASTQC as FASTQC_TRIMMED } from './modules/nf-core/modules/fastqc/main.nf'  
include { MULTIQC as MULTIQC_RAW; MULTIQC as MULTIQC_TRIMMED } from './modules/nf-core/modules/multiqc/main.nf'
include { FASTP } from './modules/nf-core/modules/fastp/main.nf'

include { fastqScreen } from './modules/local/fastqScreen.nf'
include { crispresso; crispresso_batch } from './modules/local/crispresso2.nf'

log.info "Input directory: ${params.inputDir}"
log.info "Output directory: ${params.outdir}"
log.info "Single end: ${params.single_end}"
log.info "Amplicon seq: ${params.amplicon_seq}"
log.info "Guide seq: ${params.guide_seq}"
log.info "Coding seq: ${params.coding_seq}"
log.info "Coding seq len: ${params.coding_seq.length()}"
log.info "Crispresso args: ${params.crispresso_args}"
log.info "Crispresso batch mode: ${params.batch}"


ch_raw_short_reads = Channel.fromFilePairs(params.inputDir +'/*_{R1,R2}_*.fastq.gz', size: 2)
.ifEmpty { exit 1, "Cannot find any reads matching: ${params.inputDir}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
.map { row ->
		def meta = [:]
		meta.id           = row[0]
		meta.group        = 0
		meta.single_end   = false
		return [ meta, row[1] ]
	}


// TODO: Replace ifEmpty with small fake Undetermined.fastq.gz
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
	FASTP(ch_raw_short_reads_work,false,false) // For adapter trimming, also treat as paired end!

	FASTQC_TRIMMED(FASTP.out.reads)
	MULTIQC_TRIMMED(FASTQC_TRIMMED.out.zip.map{it[1]}.mix(FASTP.out.json.map{it[1]}).collect())

	// Crispresso
	if (params.single_end){
		reads_ch = FASTP.out.reads.transpose()
	}else{
		reads_ch = FASTP.out.reads
	}

	if ( params.coding_seq.length() == 0){
		params.coding_seq = false
	}

	if( !params.qc_only ){
		if( !params.batch){
			crispresso(reads_ch)
		}else{
			crispresso_batch(reads_ch.map{it[1]}.collect())
		}
	}
}