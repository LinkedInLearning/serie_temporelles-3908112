import os
# pip install requests
import requests

# L'URL du répertoire Webdav
url = "https://files.data.gouv.fr/lcsqa/concentrations-de-polluants-atmospheriques-reglementes/temps-reel/"

def parcourir_fichiers_csv(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            content = response.content.decode("utf-8")
            lines = content.split("\n")
            for line in lines:
                if line.startswith("<a href="):
                    filename = line.split('"')[1]
                    # print(filename)
                    if filename.endswith(".csv"):
                        fichier_url = url + filename
                        print(f"Ouverture du fichier : {fichier_url}")
                        reponse = requests.get(fichier_url)
                        destination = f"C:\import_influx\{filename}"
                        with open(destination, 'wb') as f:
                            f.write(reponse.content)
                        
        else:
            print(f"Erreur lors de la récupération du contenu de l'URL ({response.status_code})")
    except Exception as e:
        print(f"Erreur : {str(e)}")

# Fonction pour parcourir les fichiers CSV
def parcourir_dossiers(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            content = response.content.decode("utf-8")
            for dossier in content.split("\n"):
                if dossier.startswith("<a href="):
                    repertoire = url + dossier.split('"')[1]
                    # print(repertoire)
                    if repertoire.endswith("/"):
                        parcourir_fichiers_csv(repertoire)
        else:
            print(f"Erreur lors de la récupération du contenu de l'URL ({response.status_code})")
    except Exception as e:
        print(f"Erreur : {str(e)}")

# Appel de la fonction
parcourir_dossiers(url)