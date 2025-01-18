RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"
_notSupport="Sorry, your system is not supported."
_comingSoon="Under Maintenance"

function _found(){
  [[ $1 ]] && command -v $1 && return 0
}

function _checkSystem(){
  _thisTermux=false
  _thisWin=false
  _thisLinux=false
  _sysName="Unknown"
  _sysArch=$(uname -m)
  local checkRelease=("/etc/os-release" "/etc/lsb-release" "/etc/redhat-release")
  for sysRelease in "${checkRelease[@]}"; do
    [[ -f "$sysRelease" ]] && _sysName=$(awk -F= '/^ID=/{print $2}' "$sysRelease") && break
  done

  function notermux(){
    if [[ $_sysName == "alpine" ]]; then
      _packageManager="apk"
    elif [[ $_sysName == '^(debian|ubuntu)$' ]]; then
      _packageManager="apt-get"
    elif [[ $_sysName == '^(arch|*gentoo*|*manjaro*)$' ]]; then
      _packageManager="pacman"
    else
      for _checkPackage in pacman apk zypper xbps-install pkg yum dnf apt; do
        [[ $(_found $_checkPackage) ]] && _packageManager=$(basename $_checkPackage) && break;
      done
    fi
  }
  if [[ -d "/data/data/com.termux" ]] && [ -n $PREFIX ] && [ -d "$PREFIX" ] && [[ $(command -v pkg) ]]; then
    _systemType="termux" && _thisTermux=true
  elif [[ -n $(uname -mrs | grep -w Microsoft | sed "s/.*\-//" | awk "{print $1}") ]]; then
    _systemType="windows" && _thisWin=true
  else
    _systemType="linux" && _thisLinux=true
  fi

  [[ $_systemType == "termux" ]] && _packageManager="pkg" || notermux

  # Out
  # _systemType
  # _packageManager
  # _sysName
  # _sysArch
}
_checkSystem

function ___COLORIZE___(){
  local colors=("31" "33" "32" "36" "35" "34")
  local text="$1"
  local len=${#text}
  for ((i = 0; i < len; i++)); do
    local color_idx=$((i % ${#colors[@]}))
    local color_code="\e[${colors[$color_idx]}m"
    echo -ne "${color_code}${text:$i:1}"
  done
  echo -e "\e[0m"
}

function _HandleWarn(){
  local warning="${YELLOW}Warning:${RESET} $1"
  echo "$warning"
}

function _HandleStart(){
  local started="${CYAN}Process:${RESET} $1"
  echo "$started"
}

function _HandleError(){
  local error_message="${RED}Error:${RESET} $1"
  echo "$error_message"
  return 1
}

function _HandleResult(){
  local result_message="${GREEN}Result:${RESET} $1"
  echo "$result_message"
}

function _HandleCustom(){
  local message="$1$2${RESET} $3"
  echo "$message"
}

function _checkingPackage(){
  while getopts ":i:p:" opt; do
    case $opt in
      "i") local code=$OPTARG;;
      "p") local name=$OPTARG;;
      \? ) _HandleWarn "Invalid option" >&2; return 1; break;;
    esac
  done
  [[ -z $code ]] && echo "Option install package ('-i') and optional package ('-p') is required" && return 0
  [[ -z $name ]] && name=$code
  [[ ! $(_found $name) ]] && _HandleWarn "$name not installed. Installing now!"
  if [[ ! $(search $name 2>/dev/null) ]]; then
    _HandleError "$name is not found in the repository"
    return 1
  fi
  _HandleStart "Installing $code"
  local tryInstall=$(installnc $code &>/dev/null)
  [[ $? -eq 0 && $(_found $name) ]] && \
    _HandleResult "Success installing $name" && return 0 || \
    _HandleError "Failed installing $name" && return 1
}

function _processCheck(){
  if [[ $(_found pgrep) ]]; then
    pgrep $1 && return 0
  elif [[ $(_found ps) ]]; then
    ps aux | grep $1 && return 0
  elif [[ $(_found pidof) ]]; then
    pidof $1
  fi
}

function instal(){
  [[ $_systemType == "termux" ]] && $_packageManager install $* && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    apt|dnf|yum|pkg|zypper) sudo $_packageManager install $*;;
    pacman|xbps-install) sudo $_packageManager -S $*;;
    apk) sudo $_packageManager add $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function installnc(){
  [[ $_systemType == "termux" ]] && $_packageManager install $* -y && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    apt|dnf|yum|pkg|zypper) sudo $_packageManager install -y $* 2>/dev/null;;
    pacman) sudo $_packageManager -S --noconfirm $*;;
    xbps-install) sudo xbps-install -Sy $*;;
    apk) sudo $_packageManager add --no-cache --quiet $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function update(){
  [[ $_systemType == "termux" ]] && $_packageManager update && return 0
  case $_packageManager in
    apt|apk|pkg) sudo $_packageManager update;;
    pacman) sudo $_packageManager -Syu;;
    xbps-install) sudo $_packageManager -Su;;
    zypper|dnf|yum) sudo $_packageManager update;;
    *) echo $_notSupport; return 1;;
  esac
}

function upgrade(){
  [[ $_systemType == "termux" ]] && $_packageManager upgrade && return 0
  case $_packageManager in
    pacman) sudo $_packageManager -Syu;;
    xbps-install) sudo $_packageManager -Su;;
    zypper|dnf|yum) sudo $_packageManager update;;
    apt|pkg|apk) sudo $_packageManager upgrade;;
    *) echo $_notSupport; return 1;;
  esac
}

function remove(){
  [[ $_systemType == "termux" ]] && $_packageManager uninstall $* && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    pkg|apt|zypper|dnf|yum) sudo $_packageManager remove $*;;
    pacman) sudo $_packageManager -R $*;;
    xbps-install) sudo xbps-remove -R $*;;
    apk) sudo $_packageManager del $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function search(){
  [[ $_systemType == "termux" ]] && $_packageManager search $* && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    apt|zypper|apk|pkg|dnf|yum) $_packageManager search $*;;
    xbps-install) xbps-query -Rs $*;;
    pacman) $_packageManager -Ss $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function orphan(){
  [[ $_systemType == "termux" ]] && $_packageManager autoremove &&
    $_packageManager autoclean && return 0
  case $_packageManager in
    apt|apk|pkg|dnf|yum) sudo $_packageManager autoremove;;
    pacman) sudo $_packageManager -Rns $(pacman -Qtdq);;
    zypper) sudo $_packageManager remove $(rpm -qa --qf "%{NAME}\n" | grep -vx "$(rpm -qa --qf "%{INSTALLTIME}:%{NAME}\n" | sort -n | uniq -f1 | cut -d: -f2-)");;
    xbps-install) sudo xbps-remove -O;;
    *) echo $_notSupport; return 1;;
  esac
}

function reinstall(){
  [[ $_systemType == "termux" ]] && $_packageManager reinstall $* && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    pacman) sudo $_packageManager -S --needed $*;;
    zypper) sudo $_packageManager in -f $*;;
    apk) sudo $_packageManager add --force --no-cache $*;;
    xbps-install) sudo $_packageManager -f $*;;
    yum|dnf) sudo $_packageManager reinstall $*;;
    pkg) sudo $_packageManager install -f $*;;
    apt) sudo apt reinstall $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function updateupgrade(){
  [[ $_systemType == "termux" ]] && $_packageManager update &&
    $_packageManager upgrade && return 0
  case $_packageManager in
    apt) sudo $_packageManager update && sudo $_packageManager upgrade -y;;
    apk) sudo $_packageManager update && sudo $_packageManager upgrade;;
    pacman) sudo $_packageManager -Syu;;
    zypper|dnf|yum) sudo $_packageManager update;;
    xbps-install) sudo $_packageManager -Su;;
    pkg) sudo freebsd-update install;;
    *) echo $_notSupport; return 1;;
  esac
}

function detail(){
  [[ $_systemType == "termux" ]] && $_packageManager show $* && return 0
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    apt) $_packageManager show $*;;
    pacman) $_packageManager -Si $*;;
    zypper|dnf|yum|pkg) $_packageManager info $*;;
    apk) $_packageManager info -a $*;;
    xbps-install) xbps-query -R $*;;
    *) echo $_notSupport; return 1;;
  esac
}

function checkpackage(){
  [[ $_systemType == "termux" ]] && echo $_notSupport && return 1
  case $_packageManager in
    apt) dpkg -C;;
    pacman) $_packageManager -Qkk;;
    zypper|dnf|yum) rpm -Va;;
    apk|pkg) $_packageManager check;;
    xbps-install) xbps-query -H check;;
    *) echo $_notSupport; return 1;;
  esac
}

function listpackage(){
  [[ $_systemType == "termux" ]] && $_packageManager list-installed && return 0
  case $_packageManager in
    apt) dpkg --list;;
    pacman) $_packageManager -Q;;
    zypper|dnf|yum) rpm -qa;;
    apk) $_packageManager list;;
    xbps-install) xbps-query -l;;
    pkg) $_packageManager info;;
    *) echo $_notSupport; return 1;;
  esac
}

function holdpackage(){
  [[ $_systemType == "termux" ]] && echo $_notSupport && return 1
  if [[ $# -eq 0 ]]; then
    _HandleError "Need a package argument"
    return 1
  fi
  case $_packageManager in
    apt) sudo apt-mark hold $*;;
    pacman) sudo $_packageManager -D $*;;
    zypper) sudo $_packageManager addlock $*;;
    apk) sudo $_packageManager add --lock $*;;
    pkg) sudo $_packageManager lock $*;;
    *) echo $_notSupport; return 1;;
  esac
}

# AUR
if [[ $(_found yay) ]]; then
  function auri() { yay -S $*; }
  function aurinc() { yay -S --noconfirm $*; }
  function auru() { yay -Sy $*; }
  function auruu() { yay -Syu $*; }
  function aurs() { yay -Ss $*; }
  function aurr() { yay -Runscd $*; }
fi

# SNAP
if [[ $(_found snap) ]]; then
  function snapi() { sudo snap install $*; }
  function snapu() { sudo snap refresh $*; }
  function snapv() { sudo snap revert $*; }
  function snaps() { snap find $*; }
  function snapl() { snap list $*; }
  function snapla() { snap list --all $*; }
  function snapon() { sudo snap enable $*; }
  function snapoff() { sudo snap disable $*; }
  function snapr() { sudo snap remove $*; }
fi




function play(){
  ___COLORIZE___ "Happy Gaming! :)"
  PS3="Choose game: "
  local list=("Moon-buggy" "Tetris" "Pacman" "Space-Invaders" "Snake" "Greed" "Nethack" "Sudoku" "2048")
  local nameGame="" playGame=""
  select playing in "${list[@]}"; do
    case $playing in
      Moon-buggy) nameGame="moon-buggy" playGame="moon-buggy"; break;;
      Tetris) nameGame="bastet" playGame="bastet"; break;;
      Pacman) nameGame="pacman4console" playGame="pacmanplay"; break;;
      Space-Invaders) nameGame="ninvaders" playGame="ninvaders"; break;;
      Snake) nameGame="nsnake" playGame="nsnake"; break;;
      Greed) nameGame="greed" playGame="greed"; break;;
      Nethack) nameGame="nethack" playGame="nethack"; break;;
      Sudoku) nameGame="nudoku" playGame="nudoku"; break;;
      2048) nameGame="2048" playGame="2048"; break;;
      *) _HandleWarn "Invalid input. Try again!"; break;;
    esac
  done
  
  if [[ $playGame == "2048" ]]; then
    [[ ! $(_found gcc) ]] && _checkingPackage -i clang -p gcc
    [[ ! $(_found wget) ]] && _checkingPackage -i wget 
    wget -q https://raw.githubusercontent.com/mevdschee/2048.c/master/2048.c
    gcc -o $PREFIX/bin/2048 2048.c
    chmod +x $PREFIX/bin/2048
    rm 2048.c
  fi
  if [[ ! $(_found $playGame) ]]; then
    _checkingPackage -i $nameGame -p $nameGame
    [[ $? -eq 0 ]] && $playGame || return 1
  else
    $playGame
  fi
}

function sctl(){
  if $_thisTermux; then
    [[ ! $(_found sv) ]] && _checkingPackage -i termux-services
    _sysService="sv"
  elif $_thisWin && [[ $(_found service) ]]; then
    _sysService="service"
  else
    if [[ $(_found systemctl) ]]; then
      _sysService="systemctl"
    elif [[ $(_found service) ]]; then
      _sysService="service"
    elif [[ $(_found sv) ]]; then
      _sysService="sv"
    else
      _sysService=""
      _HandleWarn "$_notSupport" && return 1
    fi
  fi

  function _sctl_usage(){
    echo "Usage: sctl <options> service"
    echo ""
    echo "Options :"
    echo "------------------------------------------------"
    echo "    -D      Disable service"
    echo "    -d      Stop service"
    echo "    -E      Enable service"
    echo "    -h      Show this help message"
    echo "    -r      Restart service"
    echo "    -s      Show status service"
    echo "    -u      Start service"
  }

  while getopts ":u:d:D:E:s:r:h" opt; do
    case $opt in
      u ) local action="start" actionSV="up" service="$OPTARG"; break;;
      r ) local action="restart" actionSV="reload" service="$OPTARG"; break;;
      d ) local action="stop" actionSV="down" service="$OPTARG"; break;;
      E ) [[ $_thisTermux == true ]] && local action="sv-enable" || local action="enable"
          local actionSV="sv-enable" service="$OPTARG"; break;;
      D ) [[ $_thisTermux == true ]] && local action="sv-disable" || local action="disable"
          local actionSV="sv-disable" service="$OPTARG"; break;;
      s ) local action="status" actionSV="status" service="$OPTARG"; break;;
      h ) _sctl_usage; return 0; break;;
      : ) _HandleError "Option -$OPTARG requires an argument"; return 1; break;;
      \?) _HandleWarn "Invalid option -$OPTARG"; return 1; break;;
    esac
  done

  if [[ $# -eq 0 ]]; then
    _HandleError "Must specify one option"
    return 1
  fi
  if $_thisTermux; then
    local thisAction='^(up|reload|status|down|sv-enable|sv-disable)$'
    if [[ $actionSV =~ $thisAction ]]; then
      $_sysService $actionSV $service && return 0
    else
      _HandleWarn "Invalid Options" && return 1
    fi
  elif $_thisWin; then
    local thisAction='^(start|restart|stop|status|enable|disable)$'
    if [[ $action =~ $thisAction ]]; then
      sudo $_sysService $service $action && return 0
    else
      _HandleWarn "Invalid Options" && return 1
    fi
  else
    local thisAction='^(start|restart|stop|status|enable|disable)$'
    local updown='^(up|down)$'
    if [[ $_sysService == "systemctl" ]]; then
      if [[ $action =~ $thisAction ]]; then
        sudo $_sysService $action $service && return 0
      else
        _HandleWarn "Invalid Options" && return 1
      fi
    elif [[ $_sysService == "service" ]]; then
      if [[ $action =~ $thisAction ]]; then
        sudo $_sysService $service $action && return 0
      else
        _HandleWarn "Invalid Options" && return 1
      fi
    elif [[ $_sysService == "sv" ]]; then
      if [[ $action =~ $updown ]]; then
        sudo $_sysService $action $service && return 0
      elif [[ $action =~ $thisAction ]]; then
        sudo $_sysService $action $service && return 0
      else
        _HandleWarn "$_notSupport" && return 1
      fi
    else
      _HandleWarn "$_notSupport" && return 1
    fi
  fi
}

function ls(){
  if [[ $(uname -a | grep "\-aws") ]]; then
    ls
  else
    if [[ ! $(_found exa) ]]; then
      _checkingPackage -i exa -p exa
      if [[ $? -eq 1 ]] || [[ ! $(_found exa) ]] && [[ "$_sysName" == "ubuntu" ]] || [[ "$_thisTermux" ]]; then
        _HandleStart "Trying install dependency"
        if [[ ! $(_found unzip) ]]; then
          _checkingPackage -i unzip -p unzip
        fi
        if $_thisTermux; then
          if [[ "$_sysArch" == "aarch64" ]]; then
            if [[ ! -f "/data/data/com.termux/files/usr/bin/exa" ]]; then
              _HandleStart "Installing ..."
              wget -qO /data/data/com.termux/files/usr/bin/exa https://github.com/dotcreep/dotfiles/releases/download/exa-v0.10.1/exa
              _HandleStart "Configuring ..."
              chmod 755 /data/data/com.termux/files/usr/bin/exa
            fi
          fi
        else
          if [[ "$_sysArch" == "aarch64" ]]; then
            if [[ ! -f "/usr/bin/exa" ]]; then
              _HandleStart "Installing ..."
              sudo wget -qO /usr/bin/exa https://github.com/dotcreep/dotfiles/releases/download/exa-v0.10.1/exa
              _HandleStart "Configuring ..."
              sudo chmod +x /usr/bin/exa
            fi
          fi
          if [[ "$_sysArch" == "x86_64" ]]; then
            _HandleStart "Download dependency"
            wget -qO /tmp/exa.zip https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
            if [[ ! -f "/usr/bin/exa" ]]; then
              _HandleStart "Installing ..."
              sudo unzip -qqj /tmp/exa.zip 'bin/exa' -d /usr/bin/
              _HandleStart "Configuring ..."
              sudo chmod +x /usr/bin/exa
              rm /tmp/exa.zip
            fi
          fi
        fi
        _HandleResult "Success install dependency"
        echo ""
        exa --icons --group-directories-first $*
      fi
    else
      exa --icons --group-directories-first $*
    fi
  fi
}

function aliasHelp(){
  function __PACKAGE_MANAGER__(){
    echo "    instal          Install package"
    echo "    installnc       Install package with no confirm"
    echo "    update          Update package"
    echo "    upgrade         Upgrade package"
    echo "    remove          Remove package"
    echo "    search          Search package"
    echo "    orphan          Remove unused package"
    echo "    reinstall       Reinstall package"
    echo "    updateupgrade   Update and upgrade package"
    echo "    detail          Show etail package"
    echo "    checkpackage    Check package"
    echo "    listpakcage     Package list"
    echo "    holdpackage     Hold package from update"
  }
  function __AUR_MANAGER__(){
    echo "    auri            Install package from aur"
    echo "    aurinc          Install package from aur with no confirm"
    echo "    auru            Update package from aur"
    echo "    auruu           Upgrade package from aur"
    echo "    aurs            Search package from aur"
    echo "    aurr            Remove package from aur"
  }
  function __SNAP_MANAGER__(){
    echo "    snapi           Install package from snap"
    echo "    snapu           Update package from snap"
    echo "    snapv           Check version package from snap"
    echo "    snaps           Search package from snap"
    echo "    snapl           List package from snap"
    echo "    snapla          List all package from snap"
    echo "    snapon          Enable package from snap"
    echo "    snapoff         Disable package from snap"
    echo "    snapr           Remove package from snap"
  }
  function __NET_TOOLS__(){
    echo "    myip            Check network ip"
    echo "    getip           Get IP of domain"
    if $_thisWin; then echo "    netChange       Change network\n    proxyConnect    Connect proxy"; fi
    echo "    sshConnect      SSH Manager"
    echo "    restartDNS      Restart DNS"
    echo "    speeds          Speedtest"
    echo "    fileBrowser     File sharing based browser"
    echo "    cloudTunnel     Cloudflared Tunnel management for termux"
  }
  function __REGULAR_TOOLS__(){
    if $_thisTermux; then echo "    termux_tools    Termux tools"; fi
    echo "    dl_tools        Download manager"
    echo "    git_tools       Git manager"
    echo "    image_tools     Image coverter and compress"
    echo "    document_tools  Documment converter and merge"
    echo "    media_tools     Audio and video converter"
  }
  function __OTHERS__(){
    echo "    installBundles  Bundling installer"
    echo "    play            Play console games"
    echo "    sctl          System control"
  }
  function __PACKAGE_MANAGER_MINI__(){
    echo "    i               Install package"
    echo "    inc             Install package with no confirm"
    echo "    u               Update package"
    echo "    uu              Upgrade package"
    echo "    uuu             Remove package"
    echo "    r               Search package"
    echo "    s               Remove unused package"
    echo "    o               Reinstall package"
    echo "    ri              Update and upgrade package"
    echo "    d               Show etail package"
    echo "    cpkg            Check package"
    echo "    lpkg            Package list"
    echo "    hpkg            Hold package from update"
  }
  function __NET_TOOLS_MINI__(){
    echo "    nch             Change network (wsl 1)"
    echo "    pc              Connect proxy (wsl 1)"
    echo "    sc              SSH Manager"
    echo "    rdns            Restart DNS"
    echo "    spd             Speedtest"
    echo "    fbw             File sharing based browser"
    echo "    ct              Cloudflared Tunnel management for termux"
  }
  function __GIT_TOOLS_MINI__(){
    echo "    gpull           Git pull"
    echo "    gpush           Git push"
    echo "    gits            Build GIT Server on current directory"
    echo "    gitw            Create working directory for GIT Server"
    echo "    gitl            Show log of commit"
    echo "    gitr            Git soft reset (rollback)"
    echo "    gitR            Git hard reset (rollback)"
  }
  function __REGULAR_MINI__(){
    echo "    ttmux           Termux tools"
    echo "    dlt             Download manager"
    echo "    imt             Image coverter and compress"
    echo "    doct            Documment converter and merge"
    echo "    met             Audio and video converter"
    echo "    ibun            Bundling installer"
    echo "    e               Exit session"
    echo "    c               Clear terminal"
    echo "    v               nVim"
    echo "    p               Ping tools"
    echo "    vz              Vim .zshrc"
    echo "    vv              Vim .vimrc"
    echo "    rz              Restart ZSH"
  }
  function __EXAMPLE__(){
    echo "Usage: aliasHelp [option] <arguments>"
    echo ""
    echo "Options:"
    echo "    -h ARG                 See command needed"
    echo ""
    echo "Arguments:"
    echo "    example | <empty>      Show this message"
    echo "    pm | packagemanager    Package Manager command"
    echo "    aur | yay              AUR command"
    echo "    snap                   SNAP command"
    echo "    net | nettool          Internet tools command"
    echo "    regular                Regular tools command"
    echo "    other                  Other command"
    echo "    git                    Git command"
    echo "    simple                 Simple command"
  }
  while getopts ":h:" opt; do
    case $opt in
      "h" ) local helper="$OPTARG" && break ;;
      \? ) _HandleError "Invalid option '-$OPTARG'" >&2;;
      : ) __EXAMPLE__; return 0;;
    esac
  done
  [[ -z $helper || ! $helper ]] && return 1
  function _template(){
    echo "Helper Aliases from ${CYAN}$1${RESET}"
    echo ""
    echo "------------------------------------------------"
    echo "Regular Command:"
    $2
    if [[ -n $3 ]]; then
    echo -ne "\nSimple Command: \n"
    $3
    fi
  }
  case $helper in
    pm | packagemanager ) _template "Package Manager" \
      "__PACKAGE_MANAGER__" "__PACKAGE_MANAGER_MINI__";;
    aur | yay ) _template "AUR" "__AUR_MANAGER__";;
    snap ) _template "SNAP" "__SNAP_MANAGER__";;
    net | nettool ) _template "Net Tools" "__NET_TOOLS__" "__NET_TOOLS_MINI__";;
    regular ) _template "Regular Tools" "__REGULAR_TOOLS__";;
    other ) _template "Other Command" "__OTHERS__";;
    git ) _template "GIT Command" "__GIT_TOOLS_MINI__";;
    simple ) _template "Regular Simple Command" "__REGULAR_MINI__";;
    example | * ) __EXAMPLE__;;
  esac
}

alias i="instal"
alias u="update"
alias uu="upgrade"
alias uuu="updateupgrade"
alias r="remove"
alias s="search"
alias o="orphan"
alias ri="reinstall"
alias d="detail"
alias cpkg="checkpackage"
alias lpkg="listpackage"
alias hpkg="holdpackage"

alias nch="netChange"
alias pc="proxyConnect"
alias sc="sshConnect"
alias rdns="restartDNS"
alias spd="speeds"
alias fbw="fileBrowser"
alias ct="cloudTunnel"

alias gpull="git_tools -p"
alias gpush="git_tools -P"
alias gits="git_tools -s"
alias gitw="git_tools -w"
alias gitl="git_tools -l"
alias gitr="git_tools -r"
alias gitR="git_tools -R"

alias ttmux="termux_tools"
alias dlt="dl_tools"
alias imt="image_tools"
alias doct="document_tools"
alias met="media_tools"

alias ibun="installBundles"

alias e="exit"
alias c="clear"
alias v="nvim"
alias p="ping"
alias vz="vim ~/.zshrc"
alias vv="vim ~/.vimrc"
alias rz="exec zsh"
alias l="ls"
alias la="ls -la"
alias ll="ls -l"
alias ls="ls"
