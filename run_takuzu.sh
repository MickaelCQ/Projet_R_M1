#!/bin/bash

echo "Lancement de l'application Takuzu..."

# Supprimer l'ancien log
rm -f takuzu.log

# Lancer le script R en arrière-plan avec les logs
nohup Rscript Takuzulm.R > takuzu.log 2>&1 &

# Attendre un peu que ça démarre
sleep 10

# Vérifier si une erreur est survenue
if grep -qi "Error" takuzu.log; then
  echo "Une erreur est survenue :"
  grep -i "Error" takuzu.log
  exit 1
fi

# Extraire le port sur lequel écoute Shiny
URL=$(grep -o 'http://127.0.0.1:[0-9]*' takuzu.log | head -n 1)

if [ -z "$URL" ]; then
  echo "L'application n'a pas démarré correctement. Vérifiez takuzu.log"
  exit 1
fi

echo "Application lancée à l'adresse : $URL"

# Ouvrir dans le navigateur (Linux)
if command -v xdg-open > /dev/null; then
  xdg-open "$URL"
fi

