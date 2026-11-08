#!/bin/bash

TODAY=$(date +%F)
LOG="logs/run_$TODAY.log"
ID=0

# S'assurer que les dossiers existent
mkdir -p input output archive errors trash logs

# Créer l'en-tête du fichier de rapport s'il n'existe pas
[ -s output/report.csv ] || echo "id,date,city,reason,count" > output/report.csv

log() {
    echo "$1" | tee -a "$LOG"
}

log "[$(date +%H:%M)] INFO: job started"

# Nettoyer les fichiers temporaires .tmp
for f in input/*.tmp; do
    [ -e "$f" ] || continue
    mv "$f" trash/
    log "[$(date +%H:%M)] INFO: moved temporary file $f to trash"
done

# Traiter chaque fichier CSV de retours
for f in input/*.csv; do
    [ -e "$f" ] || continue
    
    filename=$(basename "$f" .csv)
    city=$(echo "$filename" | cut -d'_' -f2)
    city="$(tr '[:lower:]' '[:upper:]' <<< ${city:0:1})${city:1}"

    log "[$(date +%H:%M)] INFO: processing $f for city $city"

    # Détecter et corriger si la colonne reason est mal nommée
    if ! head -n 1 "$f" | grep -q "reason"; then
        log "[$(date +%H:%M)] WARNING: fixing malformed column in $f"
        sed -i '1s/rais[a-zA-Z]*/reason/' "$f"
    fi

    # Compter les retours par catégorie
    for reason in defective wrong_item changed_mind; do
        count=$(grep -c ",$reason," "$f")
        ID=$((ID + 1))
        echo "$ID,$TODAY,$city,$reason,$count" >> output/report.csv
    done

    mv "$f" archive/$filename-$TODAY.csv
    log "[$(date +%H:%M)] INFO: archived $f"
done

log "[$(date +%H:%M)] INFO: job finished successfully"