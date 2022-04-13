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
    """
    CRISPResso --fastq_r1 ${reads[0]} --fastq_r2 ${reads[1]} --amplicon_seq ${params.amplicon_seq} --guide_seq ${params.guide_seq} $args
    """
}


process crispresso_batch{
    tag {meta.id}
    container 'pinellolab/crispresso2'

    input:
    tuple val(meta), path(reads)

    output:
    path('*'), emit: crispresso_batch_out

    script:
    """
    CRISPRessoBatch --batch_settings ${params.batch_setting} --amplicon_seq ${params.amplicon_seq} -p 4 -g ${params.sgrna} -wc -10 -w 20
    """
}
