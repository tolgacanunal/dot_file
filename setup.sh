#!/bin/bash

# Get the directory of the script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

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


# --- Tmux Setup ---
TMUX_CONF_PATH="${DOTFILES_DIR}/tmux.conf"
TMUX_SYMLINK_PATH="$HOME/.tmux.conf"

if [ -f "$TMUX_CONF_PATH" ]; then
    if [ -L "$TMUX_SYMLINK_PATH" ]; then
        echo "Tmux symlink already exists."
    else
        if [ -f "$TMUX_SYMLINK_PATH" ]; then
            echo "Backing up existing tmux.conf to tmux.conf.bak"
            mv "$TMUX_SYMLINK_PATH" "$TMUX_SYMLINK_PATH.bak"
        fi
        echo "Creating symlink for tmux.conf"
        ln -s "$TMUX_CONF_PATH" "$TMUX_SYMLINK_PATH"
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

    if [ -L "$GHOSTTY_SYMLINK_PATH" ]; then
        echo "Ghostty config symlink already exists."
    else
        if [ -f "$GHOSTTY_SYMLINK_PATH" ]; then
            echo "Backing up existing Ghostty config to config.bak"
            mv "$GHOSTTY_SYMLINK_PATH" "${GHOSTTY_SYMLINK_PATH}.bak"
        fi
        echo "Creating symlink for ghosttyconf"
        ln -s "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_SYMLINK_PATH"
    fi
else
    echo "ghosttyconf not found, skipping."
fi

echo "Dotfiles setup complete! Please restart your shell." 