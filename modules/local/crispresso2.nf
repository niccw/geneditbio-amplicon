process crispresso{
    tag {meta.id}
    container 'pinellolab/crispresso2'

    input:
    tuple val(meta), path(reads)

    output:
    path('*'), emit: crispresso_out

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    if (params.single_end)
    """
    CRISPResso --fastq_r1 ${reads} --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} --coding_seq ${params.coding_seq} $args
    """
    else
    """
    CRISPResso --fastq_r1 ${reads[0]} --fastq_r2 ${reads[1]} --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} --coding_seq ${params.coding_seq} $args
    """
}


process crispresso_batch{
    container 'pinellolab/crispresso2'

    cpus 4

    input:
    path(reads)

    output:
    path('*'), emit: crispresso_batch_out

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    if (params.single_end){
        if (params.coding_seq){
            """
            create_batch_config.py . true
            CRISPRessoBatch -p 4 --batch_settings batch.batch --skip_failed --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} --coding_seq ${params.coding_seq} $args
            """
        }else{
            """
            create_batch_config.py . true
            CRISPRessoBatch -p 4 --batch_settings batch.batch --skip_failed --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} $args
            """
        }
    }
    else{
        if (params.coding_seq){
            """
            create_batch_config.py . false
            CRISPRessoBatch -p 4 --batch_settings batch.batch --skip_failed --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} --coding_seq ${params.coding_seq} $args
            """
        }else{
            """
            create_batch_config.py . false
            CRISPRessoBatch -p 4 --batch_settings batch.batch --skip_failed --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} $args
            """
        }

    }

}