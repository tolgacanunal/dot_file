# Universal shell script directory detection
if [ -n "$ZSH_VERSION" ]; then
    # Zsh
    DOT_FILES_DIR="${${(%):-%x}:h}"
elif [ -n "$BASH_VERSION" ]; then
    # Bash
    DOT_FILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY         # Write timestamps to history
setopt SHARE_HISTORY            # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry
setopt HIST_IGNORE_SPACE        # Don't write the commands with space in the beginning to history
setopt AUTO_CD                  # Automatically cd into a directory if you just type its name
setopt AUTO_PUSHD               # Automatically push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS        # Don't push directories that are already on the stack
setopt EXTENDED_GLOB            # Use extended globbing features

# Init ZSH
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Case-insensitive completion matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Homebrew install path customization
if command -v brew &>/dev/null; then
    # brew shellenv exports HOMEBREW_PREFIX, PATH etc.
    eval "$(brew shellenv)"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
else
    echo >&2 "Skipping homebrew initialization in shell."
fi

autoload -U compinit && compinit

# Zinit plugins
zinit ice wait lucid atinit"zicompinit; zicdreplay"
zinit light-mode for \
    zsh-users/zsh-completions \
    Aloxaf/fzf-tab \
    hlissner/zsh-autopair \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    OMZP::colored-man-pages \
    OMZP::fzf \
    OMZP::git

zinit ice depth=1; zinit light romkatv/powerlevel10k

# FZF tab completions settings
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'cat $realpath'
zstyle ':fzf-tab:complete:less:*' fzf-preview 'cat $realpath'
zstyle ':fzf-tab:complete:vi:*' fzf-preview 'cat $realpath'
zstyle ':fzf-tab:complete:zed:*' fzf-preview 'cat $realpath'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'cat $realpath'

# Enable Vi mode
bindkey -v

# url quoting on paste
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Source local configs
if [[ -f "${DOT_FILES_DIR}/zshrc_function.sh" ]]; then
  source "${DOT_FILES_DIR}/zshrc_function.sh"
fi

# Load custom aliases
if [[ -f "${DOT_FILES_DIR}/zshrc_alias.sh" ]]; then
    source "${DOT_FILES_DIR}/zshrc_alias.sh"
fi

if [[ -f "${DOT_FILES_DIR}/zshrc_envs.sh" ]]; then
    source "${DOT_FILES_DIR}/zshrc_envs.sh"
fi
