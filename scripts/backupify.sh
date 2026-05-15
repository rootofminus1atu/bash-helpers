#!/bin/bash

set -euo pipefail

SRC=(
    "$HOME/Documents"
    "$HOME/Pictures"
    "$HOME/Music"
    "$HOME/Videos/clips"
)

DEST="/run/media/$USER/Shared_Data/backups"
LOGFILE="$DEST/backup.log"

if [ ! -d "$DEST" ]; then
    echo "Backup destination not found: $DEST"
    exit 1
fi

exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting backup to: $DEST"
echo "===================================================="

for folder in "${SRC[@]}"; do
    if [ -d "$folder" ]; then
        echo "Backing up: $folder"

        rsync -avh \
            --progress \
            --partial \
            --delete \
            --backup \
            --backup-dir="$DEST/deleted/$(date +%Y-%m-%d_%H-%M-%S)/$(basename "$folder")" \
            --human-readable \
            "$folder/" \
            "$DEST/$(basename "$folder")/"
    else
        echo "Skipping missing folder: $folder"
    fi
done

echo "===================================================="
echo "Backup complete"
