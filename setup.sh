#!/bin/bash

# Get the directory of the script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# --- Homebrew Setup ---
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current shell session
    if [[ "$(uname -m)" == "arm64" ]]; then # For Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else # For Intel
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

echo "Updating Homebrew..."
brew update

BREWFILE_PATH="${DOTFILES_DIR}/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$BREWFILE_PATH"
else
    echo "Brewfile not found. I'll create one for you."
    touch "$BREWFILE_PATH"
    echo "# Add your Homebrew packages here (e.g., brew 'neofetch')" >> "$BREWFILE_PATH"
fi

# --- Zsh Setup ---
ZSHRC_PATH="$HOME/.zshrc"
ZSHRC_SOURCE_LINE="source \"${DOTFILES_DIR}/zshrc_base.sh\""

# Backup .zshrc if it exists and hasn't been backed up
if [ -f "$ZSHRC_PATH" ] && ! grep -q "$ZSHRC_SOURCE_LINE" "$ZSHRC_PATH"; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    cp "$ZSHRC_PATH" "$ZSHRC_PATH.bak"
fi

# Add sourcing line to .zshrc if not already there
if ! grep -q "$ZSHRC_SOURCE_LINE" "$ZSHRC_PATH"; then
    echo "Adding dotfiles source to .zshrc"
    echo -e "\n# Load dotfiles\n${ZSHRC_SOURCE_LINE}" >> "$ZSHRC_PATH"
else
    echo "Dotfiles source already in .zshrc"
fi

# --- Git Setup ---
GITCONF_PATH="${DOTFILES_DIR}/gitconf"
if [ -f "$GITCONF_PATH" ]; then
    echo "Running gitconf setup"
    bash "$GITCONF_PATH"
else
    echo "gitconf not found, skipping."
fi

# --- Symlink Setup Function ---
setup_symlink() {
    local source_path=$1
    local destination_path=$2
    local backup_path="${destination_path}.bak"

    if [ -L "$destination_path" ]; then
        echo "Symlink for $(basename "$source_path") already exists."
        return
    fi

    if [ -f "$destination_path" ]; then
        echo "Backing up existing $(basename "$destination_path") to $(basename "$backup_path")"
        mv "$destination_path" "$backup_path"
    fi

    echo "Creating symlink for $(basename "$source_path")"
    ln -s "$source_path" "$destination_path"
}

# --- Tmux Setup ---
TMUX_CONF_PATH="${DOTFILES_DIR}/tmux.conf"
TMUX_SYMLINK_PATH="$HOME/.tmux.conf"

if [ -f "$TMUX_CONF_PATH" ]; then
    setup_symlink "$TMUX_CONF_PATH" "$TMUX_SYMLINK_PATH"

    # Install tpm if not already installed
    TPM_PATH="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_PATH" ]; then
        echo "Installing tmux plugin manager (tpm)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    fi
else
    echo "tmux.conf not found, skipping."
fi


# --- Ghostty Setup ---
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="${DOTFILES_DIR}/ghosttyconf"
GHOSTTY_SYMLINK_PATH="${GHOSTTY_CONFIG_DIR}/config"

if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
    if [ ! -d "$GHOSTTY_CONFIG_DIR" ]; then
        echo "Creating Ghostty config directory."
        mkdir -p "$GHOSTTY_CONFIG_DIR"
    fi

    setup_symlink "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_SYMLINK_PATH"
else
    echo "ghosttyconf not found, skipping."
fi

# --- Aerospace Setup ---
AEROSPACE_CONFIG_FILE="${DOTFILES_DIR}/.aerospace.toml"
AEROSPACE_SYMLINK_PATH="$HOME/.aerospace.toml"

if [ -f "$AEROSPACE_CONFIG_FILE" ]; then
    setup_symlink "$AEROSPACE_CONFIG_FILE" "$AEROSPACE_SYMLINK_PATH"
else
    echo ".aerospace.toml not found, skipping."
fi

echo "Dotfiles setup complete! Please restart your shell." 