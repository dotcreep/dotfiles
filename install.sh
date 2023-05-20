[[ ! -d $HOME/.zsh-plugin ]] && mkdir -p $HOME/.zsh-plugin
[[ ! -d $HOME/.config ]] && mkdir $HOME/.config
[[ ! -d $HOME/.zsh-plugin/zsh-autosuggestions ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugin/zsh-autosuggestions
[[ ! -d $HOME/.zsh-plugin/zsh-syntax-highlighting ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-plugin/zsh-syntax-highlighting
[[ ! -f $HOME/.zshrc ]] && ln -s ${PWD}/unix/.zshrc $HOME/.zshrc
[[ ! -d $HOME/.zsh ]] && ln -s ${PWD}/unix/.zsh $HOME/.zsh
[[ ! -d $HOME/.config/nvim/ ]] && ln -s ${PWD}/unix/nvim $HOME/.config/nvim