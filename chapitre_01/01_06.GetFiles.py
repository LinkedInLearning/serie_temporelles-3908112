import os
# pip install requests
import requests
# pip install psycopg2
import psycopg2 as pg

# L'URL du répertoire Webdav
url = "https://files.data.gouv.fr/lcsqa/concentrations-de-polluants-atmospheriques-reglementes/temps-reel/"

cn = pg.connect(
    host='localhost',
    dbname='air',
    user='postgres',
    password='postgres'
)

def log_import_prostgresql(fichier, cur):
    cur.execute('INSERT INTO import.log (fichier) VALUES (%s);', [os.path.basename(fichier)])

def copy_vers_postgresql(fichier):
    cur = cn.cursor()
    with open(fichier, 'r') as f:
        # cur.copy_from(f, 'import.concentration_france', sep=';')
        cur.copy_expert("COPY import.concentration_france from STDIN DELIMITER ';' CSV HEADER;", f)
    cur.execute('CALL import.import_concentration_france();')
    log_import_prostgresql(fichier, cur)
    cn.commit()

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
                        # Remplacez cette étape par le traitement que vous souhaitez effectuer sur chaque fichier CSV
                        # Par exemple, vous pouvez utiliser pandas pour lire le fichier CSV :
                        # df = pd.read_csv(fichier_url)
                        # print(df.head())
                        reponse = requests.get(fichier_url)
                        destination = f"C:\import\{filename}"
                        with open(destination, 'wb') as f:
                            f.write(reponse.content)
                        copy_vers_postgresql(destination)
                        os.remove(destination)
                        
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
cn.close()