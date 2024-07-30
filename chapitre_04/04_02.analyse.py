import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt

sql = """
SELECT 
    DATE_TRUNC('month', time) AS mois,
    ROUND(AVG(valeur)::decimal, 3) AS avg_valeur
FROM polluants.concentration_france_ts cf
JOIN polluants.site s ON cf.code_site = s.code_site 
WHERE ZAS = 'ZAG AVIGNON' AND polluant = 'O3'
GROUP BY DATE_TRUNC('month', time)
ORDER BY mois;
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
afficher_graphique(df)