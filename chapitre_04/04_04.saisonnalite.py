import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt
# Importer la librairie statsmodels
# pip install statsmodels
from statsmodels.tsa.seasonal import seasonal_decompose

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

def afficher_decomposition(df):
    df['annee_mois'] = pd.to_datetime(df['annee_mois'], utc=True)
    df = df.set_index('annee_mois')
    result = seasonal_decompose(df['avg_valeur'], model='multiplicative')
        # Additif (model='additive'): Ce modèle suppose que la série temporelle 
        #         est la somme de la tendance, de la saisonnalité et des résidus :
        #         Y(t) = Tendance(t) + Saisonnalité(t) + Résidus(t)
        # Multiplicatif (model='multiplicative'): Ce modèle suppose que la série temporelle 
        #         est le produit de la tendance, de la saisonnalité et des résidus :
        #         Y(t) = Tendance(t) * Saisonnalité(t) * Résidus(t)`
    result.plot()
    plt.show()

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
afficher_decomposition(df)