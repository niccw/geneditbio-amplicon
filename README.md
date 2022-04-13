### General workflow for amplicon seq analysis

Raw reads -> FastQC + MultiQC
Raw reads -> FastP ->  (FastQC + MultiQC) -> Crispresso

1. Parameters as cmd arguments
```
nextflow run main.nf --inputDir </path/contains/fastq.gz> --outdir <out_dir_name> \ 
--amplicon_seq <amp_seq> --guide_seq <guide_seq_without_pam> --crispresso_args <additional_args>
```

2. Parameters in a file
Or place all arguments into a config file i.e. `parameters.txt`
```
# This is how the parameters.txt look like

inputDir = "path/contains/raw_reads"
outdir = "test_out"
amplicon_seq = "CTGACATTTCTCTTGTCTCCTCTgtgcccagggtgctggagaatccaaatgtcctctgatggtcaaagtcctggatgctgtccgaggcagccctgctgtagacgtggctgtaaaagtgttcaaaaagaccTCTGAGGGATCCTGGGAGC"
guide_seq = "ttacagccacgtctacagca"
crispresso_args = "--default_min_aln_score 40"
```

```
nextflow run main.nf -params-file paramters.txt
```