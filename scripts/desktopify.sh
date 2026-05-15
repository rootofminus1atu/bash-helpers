#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "usage: desktopify <app-name>"
    exit 1
fi

# query="$1"
query="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

# TODO: other dirs to search (might not work for all flatpaks)
search_paths=(
    "/usr/share/applications"
    "$HOME/.local/share/applications"
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
)

matches=()

for path in "${search_paths[@]}"; do
    echo "Checking: $path"
    [ -d "$path" ] || continue
    echo "  Running grep in $path"
    while IFS= read -r file; do
        echo "    Found: $file"
        matches+=("$file")
    done < <(find "$path" -type f -name "*.desktop" -exec grep -il "$query" {} +)

done


if [ "${#matches[@]}" -eq 0 ]; then
    echo "no desktop entries found for: $query"
    exit 1
fi

echo "found:"
for i in "${!matches[@]}"; do
    echo "[$i] ${matches[$i]}"
done

read -p "Select number: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#matches[@]}" ]; then
    echo "not a valid number bruh"
    exit 1
fi

src="${matches[$choice]}"
dest="$HOME/Desktop/$(basename "$src")"

cp "$src" "$dest"
chmod +x "$dest"

gio set "$dest" metadata::trusted true 2>/dev/null

echo "desktop shortcut created:"
echo "$dest"
