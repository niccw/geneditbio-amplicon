process fastqScreen{
  tag {meta.id}
  
  /* publishDir "./results/${fasta_basename}/cctyper", mode: 'copy', overwrite: false */

  input:
  tuple val(meta), path(reads)

  output:
  path('*'), emit: fastqScreen_out
  path('*_screen.txt'), emit: screen_txt

  beforeScript "PATH=${params.fastqscreen_path}:$PATH"

  script:
  """
  fastq_screen --conf ${params.fastqscreen_genomes}/fastq_screen.conf ${reads[0]} ${reads[1]}
  """
}