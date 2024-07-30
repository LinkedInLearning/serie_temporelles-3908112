CREATE SCHEMA IF NOT EXISTS polluants;
CREATE SCHEMA IF NOT EXISTS "import";

---------------------------------------------
-- Table d'import
---------------------------------------------

-- DROP TABLE "import".concentration_france;

CREATE TABLE "import".concentration_france (
	date_debut varchar(50) NULL,
	date_fin varchar(50) NULL,
	organisme varchar(50) NULL,
	code_zas varchar(50) NULL,
	zas varchar(50) NULL,
	code_site varchar(50) NULL,
	nom_site varchar(50) NULL,
	type_implantation varchar(50) NULL,
	polluant varchar(50) NULL,
	type_influence varchar(50) NULL,
	discriminant varchar(50) NULL,
	reglementaire varchar(50) NULL,
	type_evaluation varchar(50) NULL,
	procedure_de_mesure varchar(50) NULL,
	type_de_valeur varchar(50) NULL,
	valeur float4 NULL,
	valeur_brute float4 NULL,
	unite_de_mesure varchar(50) NULL,
	taux_de_saisie varchar(50) NULL,
	couverture_temporelle varchar(50) NULL,
	couverture_de_donnees varchar(50) NULL,
	code_qualite varchar(50) NULL,
	validite int4 NULL
);
---------------------------------------------
-- Table "normale"
---------------------------------------------

-- DROP TABLE polluants.concentration_france;

CREATE TABLE polluants.concentration_france (
	date_debut timestamp(0) NOT NULL,
	date_fin timestamp(0) NOT NULL,
	code_site varchar(50) NOT NULL,
	polluant varchar(50) NOT NULL,
	type_influence varchar(50) NULL,
	discriminant varchar(50) NULL,
	reglementaire varchar(50) NULL,
	type_de_mesure_id int2 NOT NULL,
	valeur float4 NULL,
	valeur_brute float4 NULL,
	unite_de_mesure varchar(50) NULL,
	taux_de_saisie varchar(50) NULL,
	couverture_temporelle varchar(50) NULL,
	couverture_de_donnees varchar(50) NULL,
	code_qualite varchar(50) NULL,
	validite int4 NULL
)
PARTITION BY RANGE (date_debut);

-- clés étrangères
ALTER TABLE polluants.concentration_france ADD CONSTRAINT fk_code_site FOREIGN KEY (code_site) REFERENCES polluants.site(code_site);
ALTER TABLE polluants.concentration_france ADD CONSTRAINT fk_type_de_mesure FOREIGN KEY (type_de_mesure_id) REFERENCES polluants.type_de_mesure(type_de_mesure_id);

---------------------------------------------
-- timescaledb
---------------------------------------------

CREATE EXTENSION IF NOT EXISTS timescaledb;

-- DROP TABLE IF EXISTS polluants.concentration_france_ts;

CREATE TABLE IF NOT EXISTS polluants.concentration_france_ts (
	time timestamptz NOT NULL,
	code_site text NOT NULL,
	polluant text NOT NULL,
	valeur float4 NULL,
	type_de_mesure_id int2 NOT NULL,
	CONSTRAINT pk_concentration_polluants_france 
	PRIMARY KEY (time, code_site, polluant) 
);

ALTER TABLE polluants.concentration_france_ts 
ADD CONSTRAINT fk_code_site 
FOREIGN KEY (code_site) REFERENCES polluants.site(code_site);

ALTER TABLE polluants.concentration_france_ts 
ADD CONSTRAINT fk_type_de_mesure 
FOREIGN KEY (type_de_mesure_id) 
REFERENCES polluants.type_de_mesure(type_de_mesure_id);

SELECT create_hypertable(
	'polluants.concentration_france_ts', 
	by_range('time', INTERVAL '1 day'));

SELECT * 
FROM timescaledb_information.dimensions 
WHERE hypertable_schema = 'polluants'
AND hypertable_name = 'concentration_france_ts';

-- difficile avec une clé étrangère
ALTER TABLE polluants.concentration_france_ts
SET (
	timescaledb.compress, 
	timescaledb.compress_segmentby='code_site, type_de_mesure_id, polluant',
	timescaledb.compress_orderby='time');


SELECT add_compression_policy('polluants.concentration_france_ts', 
       INTERVAL '3 months');

SELECT add_retention_policy('polluants.concentration_france_ts', 
       INTERVAL '6 months');

SELECT j.hypertable_name,
       j.job_id,
       config,
       schedule_interval
  FROM timescaledb_information.jobs j
  WHERE j.proc_name = 'policy_retention';
  
CREATE MATERIALIZED VIEW polluants.concentration_france_ts_jour 
	(jour, code_site, polluant, valeur, type_de_mesure_id)
WITH (timescaledb.continuous) AS
	SELECT 
		time_bucket('1 day', time) AS jour,
		code_site,
		polluant,
		AVG(valeur) AS valeur,
		type_de_mesure_id  
	FROM polluants.concentration_france_ts
  GROUP BY (jour, code_site, polluant, type_de_mesure_id);

SELECT add_continuous_aggregate_policy('concentration_polluants_france_jours', '7 days', '1 day', '1 day');

SELECT view_name, format('%I.%I', materialization_hypertable_schema,
        materialization_hypertable_name) AS materialization_hypertable
    FROM timescaledb_information.continuous_aggregates;
    
