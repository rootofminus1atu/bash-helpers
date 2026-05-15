#!/bin/bash

audio_only=false

while [[ "$1" == -* ]]; do
    case "$1" in
        -audio|-a)
            audio_only=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

url="$1"
outdir="$HOME/Downloads"

if [ -z "$url" ]; then
    echo "Usage: ytd [-audio] <youtube-url>"
    exit 1
fi


if [ "$audio_only" = true ]; then
    echo "Downloading audio as MP3..."

    yt-dlp -x --audio-format mp3 \
        -o "$outdir/%(title)s.%(ext)s" \
        "$url"

    exit 0
fi

mapfile -t formats < <(yt-dlp -F "$url" | awk '
/^[0-9]/ && $0 !~ /audio only/ && $0 !~ /video only/ {
    print $1 " | " $3 " | " $0
}')

if [ ${#formats[@]} -eq 0 ]; then
    echo "No combined audio+video formats found."
    exit 1
fi

echo "Available formats:"
for i in "${!formats[@]}"; do
    echo "[$i] ${formats[$i]}"
done

echo
read -p "Pick a format number: " choice

format_id=$(echo "${formats[$choice]}" | cut -d' ' -f1)

if [ -z "$format_id" ]; then
    echo "Invalid choice"
    exit 1
fi

echo "Downloading format $format_id to $outdir..."

yt-dlp -f "$format_id" \
    -o "$outdir/%(title)s.%(ext)s" \
    "$url"
    