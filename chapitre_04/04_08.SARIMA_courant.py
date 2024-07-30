import os
# pip install psycopg2
import psycopg2 as pg
import pandas as pd
import matplotlib.pyplot as plt
# Importer la librairie statsmodels
# pip install statsmodels
from statsmodels.tsa.statespace.sarimax import SARIMAX  
# pip install scikit-learn
from sklearn.metrics import mean_squared_error, mean_absolute_error

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
    # Diviser les données en ensembles d'entraînement et de test
    train_data = df[:-nb_mois_prediction]
    test_data = df[-nb_mois_prediction:]

    # Créer le modèle SARIMA et l'entraîner sur les données d'entraînement
    model_sarima = SARIMAX(train_data['avg_valeur'], order=order, seasonal_order=seasonal_order).fit()
    
    # Prédiction sur l'ensemble de test
    predictions = model_sarima.predict(start=len(train_data), end=len(df)-1)
    
    # Créer un DataFrame pour les prédictions
    df_predictions = pd.DataFrame({'SARIMA': predictions}, index=test_data.index)
    
    # Concaténer les DataFrames pour l'affichage
    df_concat = pd.concat([df, df_predictions], axis=1)

    # Calculer le RMSE et le MAE
    rmse = mean_squared_error(test_data['avg_valeur'], predictions, squared=False)
    mae = mean_absolute_error(test_data['avg_valeur'], predictions)

    plt.plot(df_concat['avg_valeur'], label='Données réelles')
    plt.plot(df_concat['SARIMA'], label='Prédictions SARIMA')
    plt.legend()
    plt.title(f'Modèle SARIMA avec prédictions - RMSE: {rmse:.3f}, MAE: {mae:.3f}')
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
afficher_SARIMA(df, 6)