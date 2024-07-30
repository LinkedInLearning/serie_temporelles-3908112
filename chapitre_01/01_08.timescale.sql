CREATE EXTENSION IF NOT EXISTS timescaledb;

-- DROP TABLE IF EXISTS concentration_polluants_france;

CREATE TABLE IF NOT EXISTS concentration_polluants_france (
	time timestamptz NOT NULL,
	code_site text NOT NULL,
	polluant text NOT NULL,
	valeur float4 NULL,
	unite_de_mesure text NULL,
	CONSTRAINT pk_concentration_polluants_france 
	PRIMARY KEY (time, code_site, polluant) 
);

SELECT create_hypertable(
	'concentration_polluants_france', 
	by_range('time', INTERVAL '1 day'));

SELECT * 
FROM timescaledb_information.dimensions 
WHERE hypertable_name = 'concentration_polluants_france';

ALTER TABLE concentration_polluants_france
SET (timescaledb.compress, timescaledb.compress_orderby='time');


SELECT add_compression_policy('concentration_polluants_france', INTERVAL '3 months');

SELECT add_retention_policy('concentration_polluants_france', INTERVAL '6 months');

SELECT j.hypertable_name,
       j.job_id,
       config,
       schedule_interval
  FROM timescaledb_information.jobs j
  WHERE j.proc_name = 'policy_retention';
  
CREATE MATERIALIZED VIEW concentration_polluants_france_jours 
	(jour, code_site, polluant, valeur, unite_de_mesure)
WITH (timescaledb.continuous) AS
	SELECT 
		time_bucket('1 day', time) AS jour,
		code_site,
		polluant,
		AVG(valeur),
		unite_de_mesure  
	FROM concentration_polluants_france
  GROUP BY (jour, code_site, polluant, unite_de_mesure);

SELECT add_continuous_aggregate_policy('concentration_polluants_france_jours', '7 days', '1 day', '1 day');

SELECT view_name, format('%I.%I', materialization_hypertable_schema,
        materialization_hypertable_name) AS materialization_hypertable
    FROM timescaledb_information.continuous_aggregates;
    
