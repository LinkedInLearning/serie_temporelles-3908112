SELECT *
FROM polluants.concentration_france_ts

SELECT * 
FROM timescaledb_information.hypertables;

SELECT * 
FROM timescaledb_information.chunks; 

SELECT * 
FROM chunks_detailed_size('polluants.concentration_france_ts')
ORDER BY chunk_name;

SELECT *
FROM polluants.concentration_france_ts
WHERE time BETWEEN '2024-06-20' AND '2024-06-30';

EXPLAIN SELECT *
FROM polluants.concentration_france_ts
WHERE time BETWEEN '2024-06-20' AND '2024-06-30';
