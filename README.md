# Projet Bioinformatique- Analyse des Copies d'Éléments Transposables

Analyse structurale et annotation de copies d'éléments transposables (ET) 
chez *Arabidopsis thaliana* (TAIR10), ainsi q'une base de données 
relationnelle PostgreSQL.

Familles étudiées : **ATLANTYS1** (LTR/Gypsy), **ATLINE1_1** (LINE), 
**TAG2**, **ATHAT7** (hAT/ADN)

---

## Structure du dépôt

```
et_bioi/
├── histogrammes/
│   ├── histv2.r            # script R - histogrammes et stats par famille
│   └── etls_tair.txt       # annotation TAIR10 des ET (point de départ)
├── blast/
│   ├── mkblastdb.sh        # initialisation de la base de données BLAST
│   ├── famblast.sh         # flux de travail BLAST pour une famille
│   ├── blastdb_ATET_full.fasta/
│   |    └── ATET_full.fasta # séquences FASTA de tous les ET TAIR10
|   └──blasts #dossiers base de donnees des familles etudiées
|        ├──ATHAT7
|        |    ├──athat7.fasta
|        |    ├──ATHAT7_accnum.txt
|        |    └──...
|        ├──ATLANTYS1
|        ├──ATLINE1_1
|        └──TAG2
├── donnees/
│   ├── atlantys_ltr.embl   # séquences de référence (format EMBL)
│   ├── atlantys_i.embl
│   ├── atline1_1.embl
│   ├── tag2.embl
│   ├── athat7.embl
│   └── gendesc.txt         # description des gènes A. thaliana
├── sqldb/
│   ├── tables.sql          # création des tables et types ENUM
│   ├── remplissage.sql     # insertion des données
│   └── requetes.sql        # requêtes biologiques + vue copies_annot
|
└── README.md
```

---

## Prérequis

- **R** (4.0+)
- **BLAST+** (2.12.0+) — `makeblastdb`, `blastdbcmd`, `blastn`
- **EMBOSS Seqret** — conversion EMBL → FASTA
- **PostgreSQL** (16+) — client `psql`
- **Bash** (5.2+)

---

## Utilisation

### 1. Histogrammes et sélection des familles (R)

```r
source("histogrammes/histv2.r")
histtrnspsn("TAG2")       # histogramme + stats pour la famille TAG2
histtrnspsn("ATLANTYS1")  # fonctionne avec n'importe quelle famille de etls_tair.txt
```

`histtrnspsn(fam)` retourne le nombre de copies, leur histogramme de taille et un résumé statistique (min, max, médiane, moyenne).

---

### 2. Analyse BLAST (Bash)

#### Étape 1 — Initialiser la base de données BLAST globale

À exécuter qu'une seule fois, depuis le dossier ou se trouve le fichier contenant tous les ETs :

```bash
bash blast/mkblastdb.sh ATET_full.fasta
```

#### Étape 2 — Lancer le flux de travail pour une famille

```bash
bash blast/famblast.sh NOMFAMILLE
```

`famblast.sh` effectue dans l'ordre :
1. extraction des numéros d'accession de la famille depuis la base globale
2. création d'une base BLAST spécifique à la famille
3. alignement `blastn` de la séquence de référence contre les copies
4. génération des fichiers `copiet.tsv` et `positioncp.tsv` pour import SQL

**Test :** la famille `BRODYAGA1A` est fournie comme exemple :

```bash
bash blast/famblast.sh BRODYAGA1A
# fichier de référence attendu : blast/brodyaga1a.fasta
```

> Note :pour les familles LTR (ex. ATLANTYS1), concaténer les fichiers  
> LTR et I avant de lancer `famblast.sh` :
> ```bash
> cat atlantys1_ltr.fasta <(tail -n +2 atlantys1_i.fasta) \
>     <(tail -n +2 atlantys1_ltr.fasta) > atlantys1.fasta
> ```

---

### 3. Base de données PostgreSQL

```bash
# Créer la base
createdb et_bioinfo

# Créer les tables (types ENUM inclus)
psql -d et_bioinfo -f sqldb/tables.sql

# Remplir les tables (nécessite les .tsv générés par famblast.sh)
psql -d et_bioinfo -f sqldb/remplissage.sql

# Lancer les requêtes biologiques
psql -d et_bioinfo -f sqldb/requetes.sql
```

Les requêtes disponibles dans `requetes.sql` incluent :
- vue `copies_annot` — annotations des copies étudiées
- proximité ET/gènes avec fenêtre [−1 000 ; +200] pb

---

## Limitations connues

- `famblast.sh` ne gère pas correctement la présence de plusieurs bases BLAST  
  dans le même répertoire (utilise la première trouvée par `find`)
- Les séquences chromosomiques complètes ne sont pas intégrées dans la base  
  (champ `SeqChr` = `'NR'`)
- Le pipeline est conçu pour TAIR10 (*A. thaliana*) ; une adaptation serait  
  nécessaire pour d'autres espèces
- Les gènes non-chromosomiques ne sont pas pris par genbdd.sh
