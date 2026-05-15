INSERT INTO Chromosome (NumChr,Taille,SeqChr) VALUES 
    (1,30427671,'NR'),
    (2,19698289,'NR'),
    (3,23459830,'NR'),
    (4,18585056,'NR'),
    (5,26975502,'NR')
;

INSERT INTO FamilleET (NomF,Superfam,Ordre,Classe) VALUES 
    ('ATHAT7','hAT','TIR','II'),
    ('TAG2','hAT','TIR','II'),
    ('ATLANTYS1','Gypsy','LTR','I'),
    ('ATLINE1_1','L1','LINE','II'),
    ('BRODYAGA1A','MuDR','TIR','I')
;

-- CopieET (NomF references FamilleET so FamilleET must already be filled)
\copy CopieET(NumAcc, NomF, EstRef, SeqET) FROM 'copiet.tsv' DELIMITER E'\t';

-- faire visualisation des copies a annoter uniquement 

-- PositionCp (NumAcc references CopieET so must come after)
\copy PositionCp(NumAcc, NumChr, DebutCp, FinCp, BrinCp) FROM 'positioncp.tsv' DELIMITER E'\t';
