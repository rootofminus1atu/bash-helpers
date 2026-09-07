scripts_dir := "scripts"
services_dir := "services"
bin_dir := env("HOME") / ".local/bin"
systemd_user_dir := env("HOME") / ".config/systemd/user"

install:
    @echo "Installing scripts to {{bin_dir}}..."
    @for f in {{scripts_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        cp "$f" "{{bin_dir}}/$name"; \
        chmod +x "{{bin_dir}}/$name"; \
        echo "Installed: $name"; \
    done
    @echo "Installing services..."
    @mkdir -p {{systemd_user_dir}}
    @for f in {{services_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        cp "$f" "{{bin_dir}}/$name"; \
        chmod +x "{{bin_dir}}/$name"; \
    done
    @if ls {{services_dir}}/*.rules >/dev/null 2>&1; then \
        for f in {{services_dir}}/*.rules; do \
            name=$(basename "$f"); \
            if ! cmp -s "$f" "/etc/udev/rules.d/$name" 2>/dev/null; then \
                echo "Applying udev rule: $name (needs sudo)"; \
                sudo cp "$f" "/etc/udev/rules.d/$name"; \
                sudo udevadm control --reload-rules; \
                sudo udevadm trigger; \
            fi; \
        done; \
    fi
    @if ! groups $USER | grep -q '\binput\b'; then \
        echo "Adding $USER to 'input' group (needs sudo, requires logout/login to take effect)..."; \
        sudo usermod -aG input $USER; \
    fi
    @for f in {{services_dir}}/*.service; do \
        name=$(basename "$f"); \
        cp "$f" "{{systemd_user_dir}}/$name"; \
        systemctl --user daemon-reload; \
        systemctl --user enable --now "$name"; \
        echo "Installed & started: $name"; \
    done
    @echo "Done"

uninstall:
    @echo "Uninstalling scripts from {{bin_dir}}..."
    @for f in {{scripts_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        rm -f "{{bin_dir}}/$name"; \
        echo "Removed: $name"; \
    done
    @echo "Uninstalling services..."
    @for f in {{services_dir}}/*.service; do \
        name=$(basename "$f"); \
        systemctl --user disable --now "$name" || true; \
        rm -f "{{systemd_user_dir}}/$name"; \
    done
    @for f in {{services_dir}}/*.sh; do \
        name=$(basename "$f" .sh); \
        rm -f "{{bin_dir}}/$name"; \
    done
    @if ls {{services_dir}}/*.rules >/dev/null 2>&1; then \
        for f in {{services_dir}}/*.rules; do \
            name=$(basename "$f"); \
            if [ -f "/etc/udev/rules.d/$name" ]; then \
                sudo rm -f "/etc/udev/rules.d/$name"; \
                sudo udevadm control --reload-rules; \
                sudo udevadm trigger; \
            fi; \
        done; \
    fi
    @echo "Done"
