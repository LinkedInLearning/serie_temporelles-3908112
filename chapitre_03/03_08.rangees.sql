-- utiliser les ranges
-- [,] = inclusif
-- (,) = exclusif

SELECT '[2024-01-01, 2024-01-10)'::tsrange;

SELECT '[2024-01-01, 2024-01-10)'::tsrange @> '2024-01-05'::timestamp AS inclut;
SELECT '2024-01-05'::timestamp <@ '[2024-01-01, 2024-01-10)'::tsrange AS est_inclus;

SELECT '[2024-01-01, 2024-01-10)'::tsrange && '[2024-01-05, 2024-01-15)'::tsrange;

SELECT '[2024-01-01, 2024-01-10)'::tsrange -|- '[2024-01-10, 2024-01-20)'::tsrange;

SELECT '[2024-01-01, 2024-01-10)'::tsrange + '[2024-01-05, 2024-01-15)'::tsrange;
-- Résultat : '[2024-01-01, 2024-01-15)'


-- DROP TABLE IF EXISTS polluants.concentration_france_FR06001_O3;
CREATE TABLE IF NOT EXISTS polluants.concentration_france_FR06001_O3 (
	plage_de_temps tsrange NOT NULL PRIMARY KEY,
	valeur decimal(5,2) NOT NULL,
	EXCLUDE USING GIST (plage_de_temps WITH &&)
)

INSERT INTO polluants.concentration_france_FR06001_O3
SELECT 
	tsrange(date_debut, date_fin, '[)'),
	valeur
FROM polluants.concentration_france cf
WHERE cf.date_debut BETWEEN '2024-03-31 00:00:00' AND '2024-04-01 00:05:00'
AND code_site = 'FR06001' AND polluant = 'O3'
ORDER BY cf.date_debut;

INSERT INTO polluants.concentration_france_FR06001_O3
SELECT 
	tsrange(date_debut + INTERVAL '15 minutes', date_fin + INTERVAL '15 minutes', '[)'),
	valeur
FROM polluants.concentration_france cf
WHERE cf.date_debut BETWEEN '2024-03-31 00:00:00' AND '2024-04-01 00:05:00'
AND code_site = 'FR06001' AND polluant = 'O3'
ORDER BY cf.date_debut;

SELECT *
FROM polluants.concentration_france_FR06001_O3
WHERE plage_de_temps = '(2024-03-31 01:23:00,2024-03-31 01:25:00)'

SELECT *
FROM polluants.concentration_france_FR06001_O3
WHERE plage_de_temps @> '2024-03-31 01:23:00'::timestamp;
