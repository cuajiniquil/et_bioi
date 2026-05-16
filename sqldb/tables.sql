-- ========== 1: ENUM ========== --
-- Creation de nouveaux types avec ENUM pour eviter des contraintes CHECK trop longues
CREATE TYPE brin AS ENUM ('+', '-');

CREATE TYPE te_classe_type AS ENUM ('I', 'II','NR');

CREATE TYPE te_ordre_type AS ENUM (
    -- I
    'LTR', 'DIRS', 'PLE', 'SINE', 'LINE',
    -- II 
    'TIR', 'Crypton', 'Maverick', 'Helitron',
    -- si inconnue/hors liste
    'NR', 'Autre'
);

CREATE TYPE te_superfam_type AS ENUM (
    -- LTR
    'Copia', 'Gypsy', 'Bel-Pao', 'Retrovirus', 'ERV',
    -- Autres CI
    'DIRS','VIPER','Penelope','RTE','Jockey','L1','tRNA','7SL','5S',    
    -- TIR
    'MuDR', 'hAT', 'CACTA', 'Mariner', 'Harbinger', 'Mutator'
    -- Autres CII
    'Crypton', 'Helitron', 'Maverick',
    -- si inconnue/hors liste
    'NR' , 'Autre'
);

CREATE TYPE troncature_type AS ENUM (
    'complete',          
    '5-tronque',         
    '3-tronque',         
    'interne', -- si hits forts en 5' ET 3' mais pas au milieu 
    'soloLTR' -- modif: ajouter contrainte soloLTR ssi type est LTR
);

-- ========== 2: INIT TABLES ========== --
-- notes:
-- text pour stocker les donnees de sequences (>>> varchar)
-- "references ... on delete cascade" permet de bien effacer tout malgre les dependances
CREATE TABLE IF NOT EXISTS Chromosome (
    NumChr INT NOT NULL PRIMARY KEY,
    -- NomSp VARCHAR(100) NOT NULL,
    Taille INT NOT NULL CHECK (Taille > 0),
    SeqChr TEXT    -- revoir comment l'extraire des fichiers fasta
    --, PRIMARY KEY (NumChr,NomSp) -- a implementer si d'autres especes sont utilisees dans la bdd, mais pour TAIR exclusivement cest pas necessaire 
);

CREATE TABLE IF NOT EXISTS FamilleET (
    NomF VARCHAR(50) NOT NULL PRIMARY KEY,
    Superfam te_superfam_type NOT NULL,
    Ordre te_ordre_type NOT NULL,
    Classe te_classe_type NOT NULL
);

CREATE TABLE IF NOT EXISTS CopieET (
    NumAcc VARCHAR(50) PRIMARY KEY, -- meme si pour AT la convention est 10 char, 50 laisse ouvert pour d'autres especes
    NomF VARCHAR(50) NOT NULL REFERENCES FamilleET(NomF) ON DELETE RESTRICT,
    EstRef BOOLEAN NOT NULL DEFAULT FALSE, -- ne pas init EstRef si ligne n'est pas refseq
    SeqET TEXT NOT NULL
   );


-- condition obligeant a avoir au plus 1 (unique idx) refseq par famille
CREATE UNIQUE INDEX idx_ref_fam_unique ON CopieET (NomF) WHERE EstRef = TRUE;

CREATE TABLE IF NOT EXISTS Annotation (
    NumAcc VARCHAR(50) PRIMARY KEY REFERENCES CopieET(NumAcc) ON DELETE CASCADE,
    TypeTroncature troncature_type NOT NULL, -- RMQ: troncature sera donc selon la sequence parent (refseq si null)
    Parent VARCHAR(50) REFERENCES CopieET(NumAcc) ON DELETE SET NULL,
    EstFonct BOOLEAN NOT NULL,
    EstAutonome BOOLEAN,
    CONSTRAINT chk_solo_non_auto CHECK (TypeTroncature != 'soloLTR' OR EstAutonome = FALSE OR EstAutonome IS NULL) -- soloLTR n'est jamais autonome
);

CREATE TABLE IF NOT EXISTS Gene (
    GenID VARCHAR(20) PRIMARY KEY,
    Nom  VARCHAR(50), -- enlever not null car fichier pos ne contient pas des noms
    Description TEXT
);

CREATE TABLE IF NOT EXISTS PositionCp (
    NumAcc VARCHAR(50) PRIMARY KEY REFERENCES CopieET(NumAcc) ON DELETE CASCADE,
    NumChr INT NOT NULL REFERENCES Chromosome(NumChr) ON DELETE RESTRICT,
    DebutCp INT NOT NULL CHECK (DebutCp > 0),
    FinCp INT NOT NULL CHECK (FinCp > 0),
    BrinCp brin NOT NULL,
    CONSTRAINT chk_coords_cp CHECK (DebutCp <= FinCp)
);

CREATE TABLE IF NOT EXISTS PositionGn (
    GenID VARCHAR(20) PRIMARY KEY REFERENCES Gene(GenID) ON DELETE CASCADE,
    NumChr INT NOT NULL REFERENCES Chromosome(NumChr) ON DELETE RESTRICT,
    DebutGn INT NOT NULL CHECK (DebutGn > 0),
    FinGn INT NOT NULL CHECK (FinGn > 0),
    BrinGn brin NOT NULL,
    CONSTRAINT chk_coords_gn CHECK (DebutGn <= FinGn)
);
