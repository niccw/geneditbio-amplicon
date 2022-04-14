#!/usr/bin/env python3

import sys
from pathlib import Path
import itertools
import re

def create_batch_config(workdir:str, single_end = False):
    if single_end == "true":
        single_end = True
    elif single_end == "false":
        single_end = False
    
    p = Path(workdir)
    reads = p.glob('*.fastq.gz')
    reads = sorted(reads)
    # Lib007_S7_L001_1.trim.fastq.gz

    if single_end:
        with open("batch.batch","w") as f:
            f.write(f"name\tfastq_r1\n")
            for read in reads:
                readID = read.name.split("_",1)[0]
                r = re.search(r"\d(?=\.trim)",read.name)[0]
                f.write(f"{readID}_{r}\t{read}\n")
    else:
        with open("batch.batch","w") as f:
            f.write(f"name\tfastq_r1\tfastq_r2\n")
            for groupID,groupItems in itertools.groupby(reads, lambda x: x.name.split("_",1)[0]):
                gls = sorted(groupItems)
                f.write(f"{groupID}\t{gls[0]}\t{gls[1]}\n")


if __name__ == "__main__":
    create_batch_config(workdir = sys.argv[1],single_end = sys.argv[2])