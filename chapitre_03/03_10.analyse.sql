-- Analyse de la pollution
SELECT 
    DATE_TRUNC('day', time) AS jour,
    AVG(valeur) AS avg_valeur,
    MIN(valeur) AS min_valeur,
    MAX(valeur) AS max_valeur
FROM polluants.concentration_france_ts cf
JOIN polluants.site s ON cf.code_site = s.code_site 
WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
GROUP BY DATE_TRUNC('day', time)
ORDER BY max_valeur DESC
--ORDER BY min_valeur DESC
LIMIT 10;

-- variabilité
SELECT 
    DATE_TRUNC('month', time) AS mois,
    VARIANCE(valeur) AS variance_valeur,
    STDDEV(valeur) AS ecart_type_valeur
FROM polluants.concentration_france_ts cf
JOIN polluants.site s ON cf.code_site = s.code_site 
WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
GROUP BY DATE_TRUNC('month', time)
ORDER BY mois;

-- Saisonnalité
SELECT 
    DATE_TRUNC('month', time) AS mois,
    AVG(valeur) AS moyenne_valeur
FROM polluants.concentration_france_ts cf
JOIN polluants.site s ON cf.code_site = s.code_site 
WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
GROUP BY DATE_TRUNC('month', time)
ORDER BY mois;
