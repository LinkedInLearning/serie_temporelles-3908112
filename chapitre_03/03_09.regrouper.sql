SELECT 
	DATE_TRUNC('day', time) AS jour,
	AVG(valeur)
FROM polluants.concentration_france_ts
GROUP BY DATE_TRUNC('day', time)
ORDER BY jour
LIMIT 10;

SELECT 
    EXTRACT(YEAR FROM time) AS annee,
    EXTRACT(MONTH FROM time) AS mois,
    EXTRACT(DAY FROM time) AS jour,
    AVG(valeur) AS moyenne_valeur
FROM polluants.concentration_france_ts
GROUP BY EXTRACT(YEAR FROM time), EXTRACT(MONTH FROM time), EXTRACT(DAY FROM time)
ORDER BY annee, mois, jour
LIMIT 10;

SELECT 
    DATE_BIN('1 day', time, '2000-01-01') AS jour,
    AVG(valeur) AS moyenne_valeur
FROM polluants.concentration_france_ts
GROUP BY DATE_BIN('1 day', time, '2000-01-01')
ORDER BY jour
LIMIT 10;

SELECT 
    DATE_BIN('2 weeks', time, '2000-01-01') AS semaine,
    AVG(valeur) AS moyenne_valeur
FROM polluants.concentration_france_ts
GROUP BY DATE_BIN('2 weeks', time, '2000-01-01')
ORDER BY semaine
LIMIT 10;