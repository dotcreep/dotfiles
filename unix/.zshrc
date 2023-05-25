# History command
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=10000

# ZSH + Starship Configuration
[[ -f $HOME/.zsh/aliases.zsh ]] && source $HOME/.zsh/aliases.zsh
[[ -f $HOME/.zsh/aliases-devops.zsh ]] && source $HOME/.zsh/aliases-devops.zsh
[[ -f $HOME/.zsh/aliases-pentest.zsh ]] && source $HOME/.zsh/aliases-pentest.zsh
[[ -f $HOME/.zsh/starship.zsh ]] && source $HOME/.zsh/starship.zsh
[[ -f $HOME/.zsh-plugin/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source $HOME/.zsh-plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $HOME/.zsh-plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source $HOME/.zsh-plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export STARSHIP_CONFIG=$HOME/.zsh/starship.toml
export STARSHIP_CACHE=$HOME/.starship/cache

# Bindkey shortcut
bindkey "\e[H" beginning-of-line # Home
bindkey "\e[F" end-of-line # End
bindkey "\e[5~" history-beginning-search-backward # Page Up
bindkey "\e[6~" history-beginning-search-forward # Page Down
bindkey "^A" beginning-of-line # Beginning of line - Ctrl + A
bindkey "^E" end-of-line # End of line - Ctrl + E
bindkey "^L" clear-screen # Clear Screen - Ctrl + L
bindkey "\e^?" backward-kill-word # Delete word before cursor - Alt + Backspace
bindkey "\ef" forward-word # Move word after - Alt + F
bindkey "\eb" backward-word # Move word before - Alt + B
bindkey "^U" backward-kill-line # Delete before cursor - Ctrl + U
bindkey "^K" kill-line # Delete after cursor - Ctrl + K
bindkey "^W" backward-kill-word # Delete word before cursor - Ctrl + W
bindkey "^R" history-incremental-search-backward - Ctrl + R

# Run Starship
eval "$(starship init zsh)"