#!/bin/bash

createdb etat_egh

psql -d etat_egh -f tables.sql
psql -d etat_egh -f remplissage.sql
psql -d etat_egh -f requetes.sql
