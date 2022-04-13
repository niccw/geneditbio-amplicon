process create_batch_config{
    input:
    val(fastqs)

    script:
    """
    echo ${fastqs}
    create_batch_config.py ${fastqs}
    """
}