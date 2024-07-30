import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt
# Importer la librairie statsmodels
# pip install statsmodels
from statsmodels.tsa.stattools import adfuller

sql = """
SELECT 
    DATE_TRUNC('month', date_debut) AS annee_mois,
    ROUND(AVG(valeur)::decimal, 3) AS avg_valeur
FROM polluants.concentration_france cf
JOIN polluants.site s ON cf.code_site = s.code_site 
WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
GROUP BY DATE_TRUNC('month', date_debut)
ORDER BY annee_mois;
"""

cn = pg.connect(
    host='localhost',
    dbname='air',
    user='postgres',
    password='postgres'
)

def calculer_stationnarite(df):
    result = adfuller(df['avg_valeur'])

    # Afficher les résultats du test
    print('Statistique ADF:', result[0])
    print('p-valeur:', result[1])
    print('Valeurs critiques :', result[4])

    # Interprétation des résultats
    if result[1] <= 0.05:
        print("La série temporelle est stationnaire.")
    else:
        print("hypothèse nulle possible : La série temporelle n'est pas stationnaire.")

def extrait_donnees(sql):
    cur = cn.cursor()
    cur.execute(sql)
    result = cur.fetchall()
    columns = [desc[0] for desc in cur.description]
    cur.close()
    df = pd.DataFrame(result, columns=columns)    
    print(df)
    print("Moyenne : ", round(df['avg_valeur'].mean(), 3))
    return df

# Appel de la fonction
df = extrait_donnees(sql)
cn.close()               
calculer_stationnarite(df)