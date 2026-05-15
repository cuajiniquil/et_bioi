#!/bin/bash

create db et_bioinfo
psql et_bioinfo

\i tables.sql
\i remplissage.sql
