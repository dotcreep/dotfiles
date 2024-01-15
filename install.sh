
[[ -f "$(pwd)/unix/.zsh/aliases.zsh" ]] && source "$(pwd)/unix/.zsh/aliases.zsh"
[[ ! $(command -v zsh) ]] && installnc zsh
[[ ! $(command -v wget) ]] && installnc wget
[[ ! $(command -v curl) ]] && installnc curl
[[ ! $(command -v chsh) ]] && installnc shadow
[[ ! $(command -v chsh) ]] && installnc bash-completion
if $_thisTermux; then
  installnc starship
else
  [[ ! $(command -v starship) ]] && (curl -sS https://starship.rs/install.sh | sh)
fi
[[ ! -d "$HOME/.zsh-plugin" ]] && mkdir -p $HOME/.zsh-plugin
[[ ! -d "$HOME/.config" ]] && mkdir $HOME/.config
[[ ! -d "$HOME/.zsh-plugin/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugin/zsh-autosuggestions
[[ ! -d "$HOME/.zsh-plugin/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-plugin/zsh-syntax-highlighting
[[ ! -f "$HOME/.zshrc" ]] && ln -s ${PWD}/unix/.zshrc $HOME/.zshrc
[[ ! -d "$HOME/.zsh" ]] && ln -s ${PWD}/unix/.zsh $HOME/.zsh
[[ ! -d "$HOME/.config/nvim/" ]] && ln -s ${PWD}/unix/nvim $HOME/.config/nvim
if [[ -d "/data/data/com.termux/files/home" ]]; then
  if [[ -f "$HOME/.termux/font.ttf" ]]; then
    mv $HOME/.termux/font.ttf $HOME/.termux/font-backup.ttf
  fi
  ln -s ${PWD}/font/font.ttf $HOME/.termux/font.ttf
fi
echo -ne "\n\nUse path '$HOME/.zsh-custom/many-your-alias.zsh' for custom alias with your own.\nCreate 'mkdir $HOME/.zsh-custom' if not exists\n"
function changeShell(){
  [[ $_thisTermux ]] && chsh -s zsh || chsh -s /bin/zsh
}
if [[ $(basename $SHELL) != 'zsh' ]]; then
    echo -ne "\nSet default shell to ZSH (y/N)? "
    read confirm
    case $confirm in
        y | Y ) changeShell;;
        n | N | * ) break;;
    esac
fi
exec zsh
if [[ -d "/data/data/com.termux/files/home" ]]; then
  termux-reload-settings
fi