SELECT CURRENT_DATE - INTERVAL '3 month';
SELECT INTERVAL '1 day 3 month';
SELECT INTERVAL '36 hours 4 days';
SELECT EXTRACT(HOUR FROM INTERVAL '36 hours 4 days');

CREATE TABLE tache (
    tache_id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nom VARCHAR(255) NOT NULL,
    duree_estimee INTERVAL HOUR DEFAULT '1 hour'
);

INSERT INTO tache (nom, duree_estimee)
VALUES ('Task A', '2 hours'::INTERVAL + '30 minutes'::INTERVAL),
       ('Task B', '1 day'::INTERVAL - '2 hours'::INTERVAL);

SELECT * FROM tache;
      
SELECT *
FROM polluants.concentration_france
WHERE date_debut BETWEEN CURRENT_DATE - INTERVAL '1 month' AND CURRENT_DATE;