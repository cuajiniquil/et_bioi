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
    'AT1TE83175',
-- ATLANTYS1
    'AT1TE53315',
    'AT2TE20435',
    'AT5TE45115'
);

SELECT cpa.NumAcc, cpa.NomF, cpa.TypeTroncature,
       pg.GenID, pg.DebutGn, pg.FinGn, pg.BrinGn,
       pc.DebutCp, pc.FinCp, pc.BrinCp
FROM copies_annot cpa
JOIN PositionCp pc ON cpa.NumAcc = pc.NumAcc
JOIN PositionGn pg ON pc.NumChr = pg.NumChr
WHERE
    -- + strand: promoter is DebutGn-2000 to DebutGn+200
    (pg.BrinGn = '+' AND pc.DebutCp <= pg.DebutGn + 200
                     AND pc.FinCp >= pg.DebutGn - 1000)
    OR
    -- brin - est l''inverse'
    (pg.BrinGn = '-' AND pc.FinCp >= pg.FinGn - 200
                     AND pc.DebutCp <= pg.FinGn + 1000);
