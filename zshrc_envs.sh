# Set default editor
if command -v zed &> /dev/null; then
    export VISUAL="zed"
    export EDITOR="zed"
elif command -v nvim &> /dev/null; then
  export VISUAL="nvim"
  export EDITOR="nvim"
elif command -v vim &> /dev/null; then
  export VISUAL="vim"
  export EDITOR="vim"
elif command -v nano &> /dev/null; then
  export VISUAL="nano"
  export EDITOR="nano"
fi

export BAT_PAGER="less -RF" # bat pager for scrolling support
