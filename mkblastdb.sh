#!/bin/bash

NOMBD=$1

#1: BLAST

sed -e 's/|/ /g' ${NOMBD} > et_bdclean.fasta

makeblastdb -in et_bdclean.fasta -parse_seqids -dbtype nucl

mkdir -p blastdb_${NOMBD}
mkdir -p blasts

mv ${NOMBD} blastdb_${NOMBD}/
mv et_bdclean.fasta* blastdb_${NOMBD}/
