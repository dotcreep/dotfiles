echo "NOTICE: Your custom aliases still existed in $HOME/.zsh-custom"
[[ -f "$HOME/.zshrc" ]] && rm -rf $HOME/.zshrc
[[ -f "$HOME/.zsh" ]] && rm -rf $HOME/.zsh
[[ -f "$HOME/.zsh-plugin" ]] && rm -rf $HOME/.zsh-plugin
[[ -f "$HOME/.config/nvim" ]] && rm -rf $HOME/.config/nvim
[[ -f "$HOME/.termux/font-backup.ttf" ]] && mv $HOME/.termux/font-backup.ttf $HOME/.termux/font.ttf
if [[ $? -ne 0 ]]; then
  echo "ERROR: Failed uninstall"
  return 1
else
  echo "Result: Success uninstall"
fi
function changeShell(){
  [[ $_thisTermux ]] && chsh -s bash || chsh -s /bin/bash
}
if [[ $(basename $SHELL) != 'bash' ]]; then
    echo -ne "\nSet default shell to BASH (Y/n)? "
    read confirm
    case $confirm in
        y | Y | * ) changeShell && exec bash;;
        n | N ) break;;
    esac
fi