#!/bin/bash

REPO_URL="https://github.com/jdkarner/ap.git"
REPO_DIR="$HOME/ap"
SCRIPT_NAME="apt-proxy"

# Clone the repo if not present (for curl | sh usage)
if [ ! -f "$REPO_DIR/$SCRIPT_NAME" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
fi

# Install apt-proxy to ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/$SCRIPT_NAME" "$HOME/.local/bin/"

# Install apt-proxy to /usr/local/bin (requires sudo)
if [ -w /usr/local/bin ]; then
    cp "$REPO_DIR/$SCRIPT_NAME" /usr/local/bin/
else
    sudo cp "$REPO_DIR/$SCRIPT_NAME" /usr/local/bin/
fi

# Set up bash completion
mkdir -p "$HOME/.bash_completion.d"
if [ ! -f "$HOME/.bash_completion.d/apt-proxy" ]; then
    cp /usr/share/bash-completion/completions/apt "$HOME/.bash_completion.d/apt-proxy"
    if ! grep -q apt-proxy "$HOME/.bash_completion.d/apt-proxy"; then
        sed -i 's/complete -F _apt apt/complete -F _apt apt-proxy/' "$HOME/.bash_completion.d/apt-proxy"
    fi
fi

# Add sourcing of bash_completion.d to .bashrc if not present
if ! grep -q "\.bash_completion\.d" "$HOME/.bashrc"; then
    cat << 'EOF' >> "$HOME/.bashrc"
if [ -d ~/.bash_completion.d ]; then
    for f in ~/.bash_completion.d/*; do
        . "$f"
    done
fi
EOF
fi

# Add sourcing to .zshrc if present and not already added
if [ -f "$HOME/.zshrc" ] && ! grep -q "\.bash_completion\.d" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"
if [ -d ~/.bash_completion.d ]; then
    for f in ~/.bash_completion.d/*; do
        . "$f"
    done
fi
EOF
fi

# Add alias 'ap' for apt-proxy to .bashrc if not present
if ! grep -q "alias ap=" "$HOME/.bashrc"; then
    echo "alias ap='apt-proxy'" >> "$HOME/.bashrc"
fi

# Add alias 'apd' for update & dist-upgrade to .bashrc if not present
if ! grep -q "alias apd=" "$HOME/.bashrc"; then
    echo "alias apd=\"ap update && ap dist-upgrade -y\"" >> "$HOME/.bashrc"
fi

# Add alias 'apf' for update & full-upgrade to .bashrc if not present
if ! grep -q "alias apf=" "$HOME/.bashrc"; then
    echo "alias apf=\"ap update && ap full-upgrade -y\"" >> "$HOME/.bashrc"
fi

# Add alias to .zshrc if present and not already added
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias ap=" "$HOME/.zshrc"; then
        echo "alias ap='apt-proxy'" >> "$HOME/.zshrc"
    fi
    if ! grep -q "alias apd=" "$HOME/.zshrc"; then
        echo "alias apd=\"ap update && ap dist-upgrade -y\"" >> "$HOME/.zshrc"
    fi
    if ! grep -q "alias apf=" "$HOME/.zshrc"; then
        echo "alias apf=\"ap update && ap full-upgrade -y\"" >> "$HOME/.zshrc"
    fi
fi

echo "Setup complete. Restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to use 'ap', 'apd', 'apf' and completions."

