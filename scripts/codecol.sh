#!/usr/bin/env bash

output_file="collected_code.md"

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <directory> [--include ext1,ext2,...] [--exclude pattern1,pattern2,...] [--exclude-dir dir1,dir2,...]"
    exit 1
fi

directory="${1%/}"
shift

if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' not found"
    exit 1
fi



ignore_dirs=(
    ".git"
    "venv"
    "__pycache__"
    "node_modules"
    "target"
)

ignore_files=(
    "Pulumi.dev.yaml"
    "Pulumi.yaml"
    "Cargo.lock"
    "package-lock.json"
    "$output_file"
)

ignore_patterns=(
    "copy"
    ".code-workspace"
)

allowed_ext=(
    "py"
    "rs"
    "js"
    "ts"
    "html"
    "css"
    "sh"
    "json"
    "yaml"
    "yml"
    "toml"
    "svelte"
)



while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --include)
            IFS=',' read -ra extra_exts <<< "$2"
            allowed_ext+=("${extra_exts[@]}")
            shift 2
            ;;
        --exclude)
            IFS=',' read -ra extra_patterns <<< "$2"
            ignore_patterns+=("${extra_patterns[@]}")
            shift 2
            ;;
        --exclude-dir)
            IFS=',' read -ra extra_dirs <<< "$2"
            ignore_dirs+=("${extra_dirs[@]}")
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 <directory> [--include ext1,ext2,...] [--exclude pattern1,pattern2,...] [--exclude-dir dir1,dir2,...]"
            exit 1
            ;;
    esac
done



is_ignored() {
    local path="$1"
    local filename
    filename="$(basename "$path")"

    for dir in "${ignore_dirs[@]}"; do
        if [[ "$path" == */"$dir"/* || "$path" == */"$dir" ]]; then
            return 0
        fi
    done

    for f in "${ignore_files[@]}"; do
        if [[ "$filename" == "$f" ]]; then
            return 0
        fi
    done

    for pattern in "${ignore_patterns[@]}"; do
        if [[ "$filename" == *"$pattern"* ]]; then
            return 0
        fi
    done

    return 1
}

is_allowed_extension() {
    local file="$1"
    local ext="${file##*.}"

    for allowed in "${allowed_ext[@]}"; do
        if [[ "$ext" == "$allowed" ]]; then
            return 0
        fi
    done

    return 1
}

process_directory() {
    local dir="$1"

    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue

        if is_ignored "$entry"; then
            continue
        fi

        if [ -f "$entry" ]; then
            if is_allowed_extension "$entry"; then
                echo "Processing: $entry"

                relative_path="${entry#$directory/}"
                extension="${entry##*.}"

                {
                    echo "$relative_path"
                    echo '```'"$extension"
                    cat "$entry"
                    echo
                    echo '```'
                    echo
                } >> "$output_file"
            fi

        elif [ -d "$entry" ]; then
            process_directory "$entry"
        fi
    done
}


rm -f "$output_file"
process_directory "$directory"
echo "Done! Output written to $output_file"
