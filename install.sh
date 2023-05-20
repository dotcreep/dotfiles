[[ ! -d $HOME/.zsh-plugin ]] && mkdir -p $HOME/.zsh-plugin
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh-plugin/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-plugin/zsh-syntax-highlighting
ln -s ${PWD}/unix/.zshrc $HOME/.zshrc
ln -s ${PWD}/unix/.zsh/ $HOME/.zsh
