[[ ! $(which starship 2>/dev/null) ]] && curl -sS https://starship.rs/install.sh | sh
[[ ! $(which zsh 2>/dev/null) || ! $(which git 2>/dev/null) || ! $(which wget 2>/dev/null) ]] && (echo "Dependency are missing. Trying install 'wget git zsh'" ;return 1)
[[ ! -d $HOME/.zsh-plugin ]] && mkdir -p $HOME/.zsh-plugin
[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
[[ ! -d $HOME/.zsh-plugin/zsh-autosuggestions ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugin/zsh-autosuggestions
[[ ! -d $HOME/.zsh-plugin/zsh-syntax-highlighting ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-plugin/zsh-syntax-highlighting
[[ ! -f $HOME/.zshrc ]] && ln -s ${PWD}/unix/.zshrc $HOME/.zshrc
[[ ! -d $HOME/.zsh ]] && ln -s ${PWD}/unix/.zsh $HOME/.zsh
[[ ! -d $HOME/.config/nvim/ ]] && ln -s ${PWD}/unix/nvim $HOME/.config/nvim
echo -ne "\n\nUse path '$HOME/.zsh-custom/many-your-alias.zsh' for custom alias with your own.\nCreate 'mkdir $HOME/.zsh-custom' in not exists\n"
if [[ $(basename $SHELL) != 'zsh' ]]; then
    echo -ne "\nSet default shell to ZSH (y/N)? "
    read confirm
    case $confirm in
        y | Y ) chsh -s /bin/zsh;;
        n | N | * ) return 1;;
    esac
fi
exec zsh