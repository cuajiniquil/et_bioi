-- faire 
CREATE VIEW copies_annot AS SELECT c.NumAcc, c.NomF, a.TypeTroncature, a.Parent, a.EstFonct, a.EstAutonome
FROM CopieET c LEFT JOIN Annotation a
ON c.NumAcc = a.NumAcc WHERE c.NumAcc IN (
-- TAG2
    'AT1TE76620',
    'AT5TE56560',
    'AT1TE36605',
-- ATHAT7
    'AT2TE26315',
    'AT3TE62570',
-- ATLINE 1_1
    'AT1TE70805',
    'AT4TE50995',
    'AT4TE50675',
-- ATLANTYS1
    'AT1TE53315',
    'AT2TE20435',
    'AT5TE45115'
);

-- 0: bilan donnees
SELECT 'Chromosome', COUNT(*) FROM Chromosome UNION ALL SELECT 'FamilleET', COUNT(*) FROM FamilleET UNION ALL SELECT 'CopieET', COUNT(*) FROM CopieET UNION ALL SELECT 'Gene', COUNT(*) FROM Gene UNION ALL SELECT 'Annotation', COUNT(*) FROM Annotation;


-- 1: question biologique
SELECT cpa.NumAcc, cpa.NomF, cpa.TypeTroncature,
       pg.GenID, pg.DebutGn, pg.FinGn, pg.BrinGn,
       pc.DebutCp, pc.FinCp, pc.BrinCp
FROM copies_annot cpa
JOIN PositionCp pc ON cpa.NumAcc = pc.NumAcc
JOIN PositionGn pg ON pc.NumChr = pg.NumChr
WHERE
    -- brin + : promoteur va de -1000 a +200 pb (voir biblio) 
    (pg.BrinGn = '+' AND pc.DebutCp <= pg.DebutGn + 200
                     AND pc.FinCp >= pg.DebutGn - 1000)
    OR
    -- brin - est l''inverse'
    (pg.BrinGn = '-' AND pc.FinCp >= pg.FinGn - 200
                     AND pc.DebutCp <= pg.FinGn + 1000);
                     
                  
                     
