# History command
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=10000

# Add your on custom alias in ~/.zsh-custom
if [[ -d $HOME/.zsh-custom ]]; then
    for zsh_custom in $HOME/.zsh-custom/*.zsh; do
        [[ -f "$zsh_custom" ]] && source "$zsh_custom"
    done
fi
# Bash completion
autoload -U +X bashcompinit && bashcompinit
# ZSH + Starship Configuration
for zsh in $HOME/.zsh/*.zsh; do
    [[ -f "$zsh" ]] && source "$zsh"
done
[[ -f $HOME/.zsh-plugin/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source $HOME/.zsh-plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $HOME/.zsh-plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source $HOME/.zsh-plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export STARSHIP_CONFIG=$HOME/.zsh/starship.toml
export STARSHIP_CACHE=$HOME/.starship/cache
export GIT_SSH_COMMAND='git -c command.timeout=300'
if [ -d "/snap/bin" ] ; then
    PATH="/snap/bin:$PATH"
fi
if [ -d "/usr/local/go/bin" ] ; then
    PATH="/usr/local/go/bin:$PATH"
fi
if [ -d "/opt/nvim-linux64/bin" ] ; then
    PATH="/opt/nvim-linux64/bin:$PATH"
fi

# Bindkey shortcut
bindkey "\e[H" beginning-of-line # Home
bindkey "\e[F" end-of-line # End
bindkey "\e[5~" history-beginning-search-backward # Page Up
bindkey "\e[6~" history-beginning-search-forward # Page Down

# Run Starship
eval "$(starship init zsh)"
