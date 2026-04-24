# Zsh configuration for Pablo
# Migrated from bash with ble.sh to clean Zsh setup

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# Zsh Options
# ============================================================================

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from history items
setopt INC_APPEND_HISTORY    # Save history entries as soon as they are entered
setopt SHARE_HISTORY         # Share history between all sessions

# Directory navigation
setopt AUTO_CD              # Go to folder path without using cd
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd

# Completion
setopt COMPLETE_IN_WORD     # Complete from both ends of a word
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word
setopt AUTO_MENU            # Show completion menu on a successive tab press
setopt AUTO_LIST            # Automatically list choices on ambiguous completion
setopt COMPLETE_ALIASES     # Complete aliases

# Correction
unsetopt CORRECT_ALL        # Don't try to correct all arguments in a line
setopt CORRECT              # Only correct commands

# ============================================================================
# Key Bindings (Vi-mode navigation)
# ============================================================================

# Use vi key bindings (ESC to enter normal mode, then h/j/k/l, w/b, etc.)
bindkey -v

# Reduce ESC key delay (faster mode switching)
export KEYTIMEOUT=1

# Vi mode indicator in cursor shape and prompt
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # Block cursor for normal mode
    export VI_MODE_NORMAL="[N]"
    export VI_MODE_INSERT=""
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # Beam cursor for insert mode
    export VI_MODE_NORMAL=""
    export VI_MODE_INSERT="[I]"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

# Start with beam cursor on zle init
function zle-line-init {
  echo -ne "\e[5 q"
  export VI_MODE_NORMAL=""
  export VI_MODE_INSERT="[I]"
  zle reset-prompt
}
zle -N zle-line-init

# Ctrl+O to switch to normal mode from insert mode (simpler approach)
# Just switches to normal mode - you return to insert with 'i' or 'a' as usual
bindkey -M viins '^O' vi-cmd-mode

# Keep some useful emacs bindings in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank

# Navigation keys that work in both modes
bindkey "^[[1;5D" backward-word      # Ctrl+Left
bindkey "^[[1;5C" forward-word       # Ctrl+Right
bindkey "^[[H" beginning-of-line     # Home
bindkey "^[[F" end-of-line           # End
bindkey "^[[3~" delete-char          # Delete
bindkey "^[[3;5~" kill-word          # Ctrl+Delete
bindkey "^H" backward-kill-word      # Ctrl+Backspace

# History search in vi mode
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# ============================================================================
# Completion System (MUST be loaded early)
# ============================================================================

# Enable completion system BEFORE loading any tools that use compdef
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================================
# Load Omarchy components
# ============================================================================

# Load Omarchy aliases and functions (bash compatible)
if [[ -f ~/.local/share/omarchy/default/bash/aliases ]]; then
  source ~/.local/share/omarchy/default/bash/aliases
fi

if [[ -f ~/.local/share/omarchy/default/bash/functions ]]; then
  source ~/.local/share/omarchy/default/bash/functions
fi

if [[ -f ~/.local/share/omarchy/default/bash/envs ]]; then
  source ~/.local/share/omarchy/default/bash/envs
fi

# ============================================================================
# Tool Integrations
# ============================================================================

# mise (version manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
  eval "$(mise completion zsh)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# zoxide (smart cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# try (temporary environments)
if command -v try &> /dev/null; then
  eval "$(try init ~/Work/tries)"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  source /usr/share/fzf/key-bindings.zsh 2>/dev/null
  source /usr/share/fzf/completion.zsh 2>/dev/null
fi

# ============================================================================
# User customizations
# ============================================================================

# Add your own exports, aliases, and functions here

# ============================================================================
# Auto-launch tmux
# ============================================================================

# Auto-launch tmux with a new anonymous session for each terminal
# Only if not already inside tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ]; then
  # Create new session without name (tmux will auto-generate: 0, 1, 2, etc.)
  exec tmux new-session
fi

# ============================================================================
# Zsh Plugins (MUST be loaded at the END)
# ============================================================================

# Syntax highlighting - MUST be loaded at the end
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions (fish-like) - Load after syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

. "$HOME/.local/share/../bin/env"

# opencode
export PATH=/home/pablo/.opencode/bin:$PATH

# bun completions
[ -s "/home/pablo/.bun/_bun" ] && source "/home/pablo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='/home/pablo/.bun/bin/bun "/home/pablo/.claude/plugins/cache/thedotmack/claude-mem/12.2.0/scripts/worker-service.cjs"'
alias dots="git --git-dir=$HOME/Work/personal/.dots --work-tree=$HOME"
