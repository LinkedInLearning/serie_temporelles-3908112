------------------------------------------------
--           support des timezones
------------------------------------------------

SHOW config_file;

-- attention à l'heure d'été
SELECT 
	date_debut,
	date_debut AT TIME ZONE 'UTC',
	valeur
FROM polluants.concentration_france cf
WHERE DATE_TRUNC('day', cf.date_debut) = '2024-03-31 00:00:00'
AND code_site = 'FR06001' AND polluant = 'O3'
ORDER BY cf.date_debut;

-- modifier le fuseau horaire
ALTER DATABASE air SET timezone TO 'Europe/Paris';
SELECT pg_reload_conf();

ALTER USER postgres SET timezone = 'Europe/Paris';

-- liste des noms de fuseaux horaires
SELECT * FROM pg_timezone_names;

select current_setting('TIMEZONE');
SHOW timezone;
SHOW time zone;

SET TIME ZONE 'Europe/Paris';
SET TIMEZONE TO 'Europe/Paris';

SELECT current_timestamp;
SELECT current_timestamp AT TIME ZONE 'UTC';
SELECT LOCALTIMESTAMP;

-- dans un SELECT
SELECT 
	date_debut,
	date_debut::TIMESTAMPTZ,
	date_debut AT TIME ZONE 'UTC',
	EXTRACT(TIMEZONE FROM date_debut::TIMESTAMPTZ) AS timezone_offset,
	valeur
FROM polluants.concentration_france cf
WHERE DATE_TRUNC('day', cf.date_debut) = '2024-03-31 00:00:00'
AND code_site = 'FR06001' AND polluant = 'O3'
ORDER BY cf.date_debut;