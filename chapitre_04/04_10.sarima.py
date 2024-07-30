import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt
# Importer la librairie statsmodels
# pip install statsmodels
from statsmodels.tsa.statespace.sarimax import SARIMAX  # Importer SARIMAX

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

def afficher_SARIMA(df, nb_mois_prediction, order=(5,1,0), seasonal_order=(1,1,1,12)):
    # Créer le modèle SARIMA
    model_sarima = SARIMAX(df['avg_valeur'], order=order, seasonal_order=seasonal_order).fit()
    
    # Prédiction sur les mois suivants
    index_futur = pd.date_range(start=df.index[-1] + pd.DateOffset(months=1), periods=nb_mois_prediction, freq='MS')
    predictions = model_sarima.predict(start=len(df), end=len(df) + nb_mois_prediction - 1)
    
    # Créer un DataFrame pour les prédictions
    df_predictions = pd.DataFrame({'SARIMA': predictions}, index=index_futur)
    
    # Concaténer les DataFrames pour l'affichage
    df_concat = pd.concat([df, df_predictions])

    plt.plot(df_concat['avg_valeur'], label='Données réelles')
    plt.plot(df_concat['SARIMA'], label='Prédictions SARIMA')
    plt.legend()
    plt.title('Modèle SARIMA avec prédictions')
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
afficher_SARIMA(df, 6)  # Prédire pour les 6 prochains mois