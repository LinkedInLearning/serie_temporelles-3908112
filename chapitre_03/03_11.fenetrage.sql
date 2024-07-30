-- fenêtrage
WITH t AS (
	SELECT 
	    DATE_TRUNC('month', time) AS mois,
	    ROUND(AVG(valeur)::decimal, 3) AS avg_valeur
	FROM polluants.concentration_france_ts cf
	JOIN polluants.site s ON cf.code_site = s.code_site 
	WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
	GROUP BY DATE_TRUNC('month', time)
)
SELECT *,
	SUM(avg_valeur) OVER (),
	avg_valeur / SUM(avg_valeur) OVER () * 100
FROM t
ORDER BY mois;

-- tendances à long terme
SELECT 
    time,
    valeur,
    AVG(valeur) OVER (ORDER BY time ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) AS moyenne_mobile_30_jours
FROM polluants.concentration_france_ts cf
JOIN polluants.site s ON cf.code_site = s.code_site 
	WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
ORDER BY time
LIMIT 100;