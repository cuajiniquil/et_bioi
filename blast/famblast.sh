#!/bin/bash

NOMF=$1
PATHDB=$(dirname $(find blastdb_* -name "et_bdclean.fasta" -print -quit))

#limitation: si >1 blastdb, ne trouve pas la bonne (que la 1ere dans find; solution eventuelle: specifier quelle bd comme argument $2)

#I: BLAST - sequencce traitement de sequence de ref vs et_bdclean

#0: creer dossier resutats et aller dans blastdb (ou dossier ou se trouve la bd generee par mkblastdb)
mkdir blasts/${NOMF}
mv ${NOMF,,}.fasta "$PATHDB"
cd "$PATHDB"

#1 - Accnum - obtenir numeros accession de fam
awk '/^>/ && $0 ~ NOMF {print $1}' NOMF="${NOMF^^}" et_bdclean.fasta | sed 's/>//' > ${NOMF}_accnum.txt

#2: Copylist - fichier fasta avec les sequences des copies uniquement de fam
blastdbcmd -db et_bdclean.fasta -entry_batch ${NOMF}_accnum.txt > ${NOMF}_copylist.fasta

#3: BD - creer bdd blast pour en faire des requetes
makeblastdb -in ${NOMF}_copylist.fasta -parse_seqids -dbtype nucl

#4: BLAST
blastn -db ${NOMF}_copylist.fasta  -query ${NOMF,,}.fasta -outfmt 6 > ${NOMF}_blastres.txt

#II: TSV pour import psql
#1: boucle permettant de transformer les resultats de blast (NOMF_blastres) en tsv, qui peut etre importe en psql
awk '{print $2}' ${NOMF}_blastres.txt | sort -u | while read hit; do
    header=$(grep -m 1 "^>${hit}" ${NOMF}_copylist.fasta)
    numacc=$(echo "$header" | awk '{print $1}' | sed 's/>//')
    brincp=$(echo "$header" | awk '{print $2}')
    debutcp=$(echo "$header" | awk '{print $3}')
    fincp=$(echo "$header" | awk '{print $4}')
    numchr=$(echo "$numacc" | cut -c3)
    sequence=$(awk -v h="${hit}" '
        /^>/ { found = ($0 ~ h); next }
        found { printf "%s", $0 }
    ' ${NOMF}_copylist.fasta | tr '[:lower:]' '[:upper:]')
  
    # copiet.tsv: NumAcc, NomF, SeqET
    echo -e "${numacc}\t${NOMF}\tFALSE\t${sequence}" >> ../../sqldb/copiet.tsv

    #ajout des copies normales
    echo -e "${numacc}\t${numchr}\t${debutcp}\t${fincp}\t${brincp}" >> ../../sqldb/positioncp.tsv

done

#2: ajout de la sequence de reference (refseq), qui correspond a NOMF_fasta
refheader=$(grep -m 1 "^>" ${NOMF,,}.fasta)
refacc=$(echo "$refheader" | awk '{print $1}' | sed 's/>//')
refseq=$(awk '/^>/ { found=1; next } found { printf "%s", $0 }' ${NOMF,,}.fasta | tr '[:lower:]' '[:upper:]')

#sortie majuscule pour eviter les pb de lecture sql (familles en maj par defaut la-bas aussi)
echo -e "${refacc}\t${NOMF^^}\tTRUE\t${refseq}" >> ../../sqldb/copiet.tsv
    
#fin: reorganiser
mv ${NOMF}*.* ../blasts/${NOMF}
mv ${NOMF,,}*.* ../blasts/${NOMF}
mv ${NOMF^^}*.* ../blasts/${NOMF}
