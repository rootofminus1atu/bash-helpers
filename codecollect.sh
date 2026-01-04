output_file="collected_code.md"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' not found"
    exit 1
fi

rm -f "$output_file" 

process_directory() {
    local dir="$1"
    for entry in "$dir"/*; do
        if [ -f "$entry" ]; then
            if file "$entry" | grep -q "text" && [ "$entry" != "$output_file" ]; then
                echo "Processing: $entry"

                relative_path=$(echo "$entry" | sed "s|^$directory/||")
                extension="${entry##*.}"

                echo "\`\`\`$extension" >> $output_file
                echo "// $relative_path" >> $output_file
                cat "$entry" >> $output_file
                echo -e '\n' >> $output_file
                echo '```' >> $output_file
            fi
        elif [ -d "$entry" ]; then
            process_directory "$entry"
        fi
    done
}

process_directory "$directory"