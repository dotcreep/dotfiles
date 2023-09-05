echo "Your custom aliases still existed in $HOME/.zsh-custom"
[[ -f "$HOME/.zshrc" ]] && rm -rf $HOME/.zshrc
[[ -f "$HOME/.zsh" ]] && rm -rf $HOME/.zsh
[[ -f "$HOME/.zsh-plugin" ]] && rm -rf $HOME/.zsh-plugin
[[ -f "$HOME/.config/nvim" ]] && rm -rf $HOME/.config/nvim
[[ -f "$HOME/.termux/font-backup.ttf" ]] && mv $HOME/.termux/font-backup.ttf $HOME/.termux/font.ttf