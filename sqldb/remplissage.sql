INSERT INTO Chromosome (NumChr,Taille,SeqChr) VALUES 
    (1,30427671,'NR'),
    (2,19698289,'NR'),
    (3,23459830,'NR'),
    (4,18585056,'NR'),
    (5,26975502,'NR')

-- do nothing pour laisser valeurs deja existantes telles qu'elles sont
ON CONFLICT DO NOTHING;

INSERT INTO FamilleET (NomF,Superfam,Ordre,Classe) VALUES 
    ('ATHAT7','hAT','TIR','II'),
    ('TAG2','hAT','TIR','II'),
    ('ATLANTYS1','Gypsy','LTR','I'),
    ('ATLINE1_1','L1','LINE','I'),
    ('BRODYAGA1A','MuDR','TIR','II')

ON CONFLICT DO NOTHING;

-- copies:
-- pour \copy on conflict n'est pas compatible: creer des tables temporelles
CREATE TEMP TABLE temp_copiet (LIKE CopieET);
CREATE TEMP TABLE temp_positioncp (LIKE PositionCp);

-- imperativement apres toutes les famillet se trouvent dedans
\copy temp_copiet(NumAcc, NomF, EstRef, SeqET) FROM 'copiet.tsv' DELIMITER E'\t';

-- faire visualisation des copies a annoter uniquement 

-- imp. apres copiet 
\copy temp_positioncp(NumAcc, NumChr, DebutCp, FinCp, BrinCp) FROM 'positioncp.tsv' DELIMITER E'\t';

INSERT INTO CopieET SELECT * FROM temp_copiet
ON CONFLICT DO NOTHING;

INSERT INTO PositionCp SELECT * FROM temp_positioncp
ON CONFLICT DO NOTHING;


-- genes:
CREATE TEMP TABLE temp_gene (LIKE Gene);
CREATE TEMP TABLE temp_positiongn (LIKE PositionGn);

\copy temp_gene(GenID, Nom, Description) FROM 'gene.tsv' DELIMITER E'\t';

\copy temp_positiongn(GenID, NumChr, DebutGn, FinGn, BrinGn) FROM 'positiongn.tsv' DELIMITER E'\t';

INSERT INTO Gene SELECT * FROM temp_gene
ON CONFLICT DO NOTHING;

INSERT INTO PositionGn SELECT * FROM temp_positiongn
ON CONFLICT DO NOTHING;

INSERT INTO Annotation (NumAcc, TypeTroncature, Parent, EstFonct, EstAutonome) VALUES
-- TAG2
    ('AT1TE76620','5-tronque',NULL,TRUE,FALSE),
    ('AT5TE56560','interne',NULL,FALSE,FALSE),
    ('AT1TE36605','interne',NULL,FALSE,FALSE),
-- ATHAT7
    ('AT2TE26315','complete',NULL,TRUE,TRUE),
    ('AT3TE62570','complete',NULL,TRUE,TRUE),
-- ATLINE 1_1
    ('AT1TE70805','complete',NULL,TRUE,TRUE),
    ('AT4TE50995','5-tronque',NULL,FALSE,FALSE),
    ('AT1TE83175','3-tronque','AT4TE50995',FALSE,FALSE),
-- ATLANTYS1
    ('AT1TE53315','soloLTR',NULL,FALSE,FALSE),
    ('AT2TE20435','complete',NULL,TRUE,TRUE),
    ('AT5TE45115','5-tronque',NULL,FALSE,FALSE)
-- si besoin de mettre a jout les annotations:
ON CONFLICT (NumAcc) DO UPDATE SET
    TypeTroncature = EXCLUDED.TypeTroncature,
    Parent = EXCLUDED.Parent,
    EstFonct = EXCLUDED.EstFonct,
    EstAutonome = EXCLUDED.EstAutonome;
