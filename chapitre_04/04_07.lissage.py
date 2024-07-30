import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt
# Importer la librairie statsmodels
# pip install statsmodels
from statsmodels.tsa.holtwinters import SimpleExpSmoothing

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

def afficher_graphique(df):
    plt.plot(df['mois'], df['avg_valeur'])
    plt.xlabel('Mois')
    plt.ylabel('Moyenne des valeurs')
    plt.title('Moyenne des valeurs par mois')
    plt.show()
    print("Moyenne : ", round(df['avg_valeur'].mean(), 3))

def afficher_lissage(df):
    model_ses = SimpleExpSmoothing(df['avg_valeur']).fit(smoothing_level=0.2)
    df['SES'] = model_ses.fittedvalues
    plt.plot(df['avg_valeur'], label='Données réelles')
    plt.plot(df['SES'], label='Lissage exponentiel simple')
    plt.legend()
    plt.title('Lissage exponentiel simple')
    plt.show()

def extrait_donnees(sql):
    cur = cn.cursor()
    cur.execute(sql)
    result = cur.fetchall()
    columns = [desc[0] for desc in cur.description]
    cur.close()
    df = pd.DataFrame(result, columns=columns)    

    # un peu de conversion
    df['annee_mois'] = pd.to_datetime(df['annee_mois'])
    df = df.set_index('annee_mois')
    df['avg_valeur'] = pd.to_numeric(df['avg_valeur'], errors='coerce')

    print(df)
    print("Moyenne : ", round(df['avg_valeur'].mean(), 3))
    return df

# Appel de la fonction
df = extrait_donnees(sql)
cn.close()               
afficher_lissage(df)