
[[ -f "$(pwd)/unix/.zsh/aliases.zsh" ]] && source "$(pwd)/unix/.zsh/aliases.zsh"
[[ ! $(_found zsh) ]] && installnc zsh
[[ ! $(_found wget) ]] && installnc wget
[[ ! $(_found curl) ]] && installnc curl
[[ ! $(_found chsh) ]] && installnc shadow
[[ ! $(_found chsh) ]] && installnc bash-completion
if $_thisTermux; then
  installnc starship
else
  [[ ! $(_found starship) ]] && (curl -sS https://starship.rs/install.sh | sh)
fi
[[ ! -d "$HOME/.zsh-plugin" ]] && mkdir -p $HOME/.zsh-plugin
[[ ! -d "$HOME/.config" ]] && mkdir $HOME/.config
[[ ! -d "$HOME/.zsh-plugin/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugin/zsh-autosuggestions
[[ ! -d "$HOME/.zsh-plugin/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-plugin/zsh-syntax-highlighting
[[ ! -f "$HOME/.zshrc" ]] && ln -s ${PWD}/unix/.zshrc $HOME/.zshrc
[[ ! -d "$HOME/.zsh" ]] && ln -s ${PWD}/unix/.zsh $HOME/.zsh
# [[ ! -d "$HOME/.config/nvim/" ]] && ln -s ${PWD}/unix/nvim $HOME/.config/nvim
if $_thisTermux; then
  if [[ -f "$HOME/.termux/font.ttf" ]]; then
    mv $HOME/.termux/font.ttf $HOME/.termux/font-backup.ttf
  fi
  ln -s ${PWD}/font/font.ttf $HOME/.termux/font.ttf
fi
echo -ne "\n\nUse path '$HOME/.zsh-custom/many-your-alias.zsh' for custom alias with your own.\nCreate 'mkdir $HOME/.zsh-custom' if not exists\n"
function changeShell(){
  echo "Set default shell to ZSH"
  [[ $_thisTermux ]] && chsh -s zsh || chsh -s /bin/zsh
}
[[ $(basename $SHELL) != 'zsh' ]] && changeShell
if $_thisTermux; then termux-reload-settings; fi
exec zsh