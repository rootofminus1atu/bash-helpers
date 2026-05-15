scripts_dir := "scripts"
bin_dir := env("HOME") / ".local/bin"

install:
    @echo "Installing scripts to {{bin_dir}}..."
    @for f in {{scripts_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        cp "$f" "{{bin_dir}}/$name"; \
        chmod +x "{{bin_dir}}/$name"; \
        echo "Installed: $name"; \
    done
    @echo "Done"

uninstall:
    @echo "Uninstalling scripts from {{bin_dir}}..."
    @for f in {{scripts_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        rm -f "{{bin_dir}}/$name"; \
        echo "Removed: $name"; \
    done
    @echo "Done"