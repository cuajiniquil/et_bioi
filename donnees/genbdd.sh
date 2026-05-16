#!/bin/bash
GENFILE=$1

tail -n +2 "$GENFILE" | while read line; do
    idgene=$(echo "$line" | awk '{print $2}')
    nomg=$(echo "$line" | awk '{NR1}')
    chr=$(echo "$line" | awk '{print $4}')
    debut=$(echo "$line" | awk '{print $5}')
    fin=$(echo "$line" | awk '{print $6}')
    orientation=$(echo "$line" | awk '{print $7}')
    
    #awk au lieu de $8+ pour description
    desc=$(echo "$line" | awk '{
        for(i=8; i<=NF; i++) printf "%s%s", $i, (i<NF?" ":"")
    }' | sed 's/.*description://;s/ \[Source:.*$//')

    #conversion en +/-
    if [ "$orientation" = "1" ]; then
        brin="+"
    else
        brin="-"
    fi

    #append (assume a nouveau que dans dossier d tq doc\d et la bdd est en doc/sqldb)
echo -e "${idgene}\t${nomg}\t${desc}" >> ../sqldb/gene.tsv

echo -e "${idgene}\t${chr}\t${debut}\t${fin}\t${brin}" >> ../sqldb/positiongn.tsv

done
