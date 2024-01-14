function uninstall_dotfiles(){
  echo "NOTICE: Your custom aliases still existed in $HOME/.zsh-custom"
  if [[ -f "$HOME/.zshrc" ]]; then
    rm -rf $HOME/.zshrc
  fi
  if [[ -f "$HOME/.zsh" ]]; then
    rm -rf $HOME/.zsh
  fi
  if [[ -f "$HOME/.zsh-plugin" ]]; then
    rm -rf $HOME/.zsh-plugin
  fi
  if [[ -f "$HOME/.config/nvim" ]]; then
    rm -rf $HOME/.config/nvim
  fi
  if [[ -f "$HOME/.termux/font-backup.ttf" ]]; then
    mv $HOME/.termux/font-backup.ttf $HOME/.termux/font.ttf
  fi
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
}
uninstall_dotfiles