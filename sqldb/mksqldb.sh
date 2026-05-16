#!/bin/bash

create db etat_psql

psql -d etat_psql -f tables.sql
psql -d etat_psql -f remplissage.sql
