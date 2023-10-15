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
  if [[ -d "/data/data/com.termux/files/usr" ]]; then
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

function install(){
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
    apt|dnf|yum|pkg|zypper) sudo $_packageManager install -y $*;;
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

############################ NETTOOL #############################

function myip(){
  [[ ! $(_found curl) ]] && _checkingPackage -i curl -p curl
  if [[ ! $(_found ip) ]]; then
    if $_thisTermux; then
      [[ $(search iproute2 2>/dev/null) ]] && _checkingPackage -i iproute2 -p ip
    else
      [[ $(search ip-utils 2>/dev/null) ]] && _checkingPackage -i ip-utils -p ip 
    fi
  fi
  local ipPublic=$(curl -s -m 30 ifconfig.me)
  local list_ipDevice=() list_macDevice=() list_ip6Device=() list_gateway=()
  for checkGateway in $(ip route list match 0 table all scope global | awk '{for (i=1; i<=NF; i++) if ($i == "via") print $(i+1)}')
  do
    list_gateway+="${GREEN}$checkGateway${RESET}"
  done
  for device in $(ip route list match 0 table all scope global | grep "via" | awk '{for (i=1; i<=NF; i++) if ($i == "dev") print $(i+1)}')
  do
    checkIP=$(ip a show dev $device 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1)
    [[ $checkIP ]] && list_ipDevice+="${GREEN}$checkIP${RESET}"
    checkMAC=$(ip a show dev $device 2>/dev/null | awk '/link\// {print $2}')
    [[ $checkMAC ]] && list_macDevice+="${GREEN}$checkMAC${RESET}"
    checkIPv6=$(ip a show dev $device 2>/dev/null | awk '/inet6/ {print $2}' | cut -d '/' -f 1)
    [[ $checkIPv6 ]] && list_ip6Device+="${GREEN}$checkIPv6${RESET}" || list_ip6Device+="${YELLOW}Nonactive${RESET}"
  done
  local ipDevice=$(IFS=,; echo "${list_ipDevice[*]}") 
  local macDevice=$(IFS=,; echo "${list_macDevice[*]}")
  local ip6Device=$(IFS=,; echo "${list_ip6Device[*]}")
  local gateway=$(IFS=,; echo "${list_gateway[*]}")
  [[ $gateway ]] && local gatewayDevice="$gateway" || local gatewayDevice="${YELLOW}Disconnect${RESET}"
  [[ $ipDevice ]] && local ipAddress="$ipDevice" || local ipAddress="${YELLOW}Disconnect${RESET}"
  [[ $macDevice ]] && local MACAddr="$macDevice" || local MACAddr="${YELLOW}Disconnect${RESET}"
  [[ $ipPublic ]] && local publicIP="${CYAN}$ipPublic${RESET}" || local publicIP="${RED}No Internet${RESET}"
  [[ $ip6Device ]] && local ip6Address="$ip6Device" || local ip6Address="${YELLOW}Disconnect${RESET}"
  echo "=================================="
  echo "|            IP Info             |"
  echo "=================================="
  echo " IP Public    : $publicIP"
  echo " Gateway      : $gatewayDevice"
  echo " IPv4 Address : $ipAddress"
  echo " IPv6 Address : $ip6Address"
  echo " MAC Address  : $MACAddr"
  echo "=================================="
}

function getip(){
  [[ ! $(_found curl) ]] && _checkingPackage -i curl -p curl
  function _getip_usage(){
    echo "Usage : getip [options] <domain>";
    echo "------------------------------------------------"
    echo "    -h        Show this message"
    echo "    -l        Use localhost"
    echo "    -s        Use server"
  }
  local server=false lokal=false
  while getopts "lsh" opt; do
    case $opt in
      "l") lokal=true; break;;
      "s") server=true; break;;
      "h" | *) _getip_usage; break;;
      \?) _HandleWarn "Invalid option"; break;;
    esac
  done
  domain='^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$'
  [[ -z $1 || $1 =~ $domain ]] && _getip_usage && return 1
  local net=false
  [[ $(curl -s -I www.f-droid.org) ]] && net=true
  if [[ $net ]]; then
    if $lokal; then
      shift
      [[ ! $(_found dig) ]] && _checkingPackage -i dnsutils -p dig
      for i in "$@"; do
        local execute=$(dig $i | awk '/^;; ANSWER SECTION:/{flag=1; next} /^;; /{flag=0} flag{print $NF}' | tr '\n' ',' | sed 's/,,$//' | sed 's/,/, /g')
        [[ $execute == "0.0.0.0" || $execute == "127.0.0.1" ]] && echo " - ${RED}$i${RESET} : Error Access or Blocked by Internal" || echo " - ${GREEN}$i${RESET} : $execute"
      done
    fi
    if $server; then
      shift
      echo "$_comingSoon"
    fi
  fi
}

function netChange(){
  if ! $_thisWin; then
    _HandleWarn "$_notSupport" && return 1
  fi
  local interface=$(ip route list match 0 table all scope global | grep "via" | awk '{for (i=1; i<=NF; i++) if ($i == "dev") print $(i+1)}')
  local wlan= lan=
  for intf in $interface; do
    if [[ $intf =~ '^(wlo|wlan|wifi|wlp0s|wlp1s|wlp2s|wlp3s|wlp4s|ath)[0-9]+$' ]]; then
        [[ -z $wlan ]] && wlan=$intf
    elif [[ $intf =~ '^(en|eth|eno|ens|enp)[0-9]+$' ]]; then
        [[ -z $lan ]] && lan=$intf
    fi
  done
  local psCheck=$(powershell.exe /c '& {ipconfig}')
  for checkInterface in "Ethernet adapter Ethernet:" "Wireless LAN adapter WiFi:"; do
    local checking=$(grep -A3 -e "$checkInterface" <<< "$psCheck" | grep -o 'Media disconnected')
    [[ $checkInterface == *Ethernet* && -z $checking ]] && local wire="LAN" || local wire=""
    [[ $checkInterface == *Wireless* && -z $checking ]] && local wired="WLAN" || local wired=""
  done
  PS3=$(_HandleCustom ${CYAN} "Change:" "")
  if [[ -z $wire && -z $wired ]]; then
    _HandleError "No Interfaces"
    return 1
  fi
  select opt in $wire $wired Cancel; do
    case $opt in
      WLAN ) local device="Wifi"; break;;
      LAN ) local device="Ethernet"; break;;
      Cancel ) return 0; break;;
      * ) _HandleWarn "Selected is invalid!"; continue;;
    esac
  done
  PS3=$(_HandleCustom ${CYAN} "Change:" "")
  select opt in IP DNS Cancel; do
    case $opt in
      IP ) local nextOPT="ip"; break;;
      DNS ) local nextOPT="dns"; break;;
      Cancel ) return 0; break;;
      * ) _HandleWarn "Selected is invalid!"; continue;;
    esac
  done
  PS3=$(_HandleCustom ${CYAN} "Change:" "")
  select opt in DHCP STATIC Cancel; do
    case $opt in
      DHCP ) local nextTYPE="dhcp"; break;;
      STATIC ) local nextTYPE="static"; break;;
      Cancel ) return 0; break;;
      * ) _HandleWarn "Selected is invalid!"; continue;;
    esac
  done 
  if [[ $nextTYPE == "static" && $nextOPT == "ip" ]]; then
    local defaultWlanIP=$(ip a show dev $wlan 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1)
    local defaultLanIP=$(ip a show dev $lan 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1)
    local defaultWlanGw=$(ip route list match 0 table all scope global | grep "via.*$wlan" | awk '{for (i=1; i<=NF; i++) if ($i == "via") print $(i+1)}')
    local defaultLanGw=$(ip route list match 0 table all scope global | grep "via.*$lan" | awk '{for (i=1; i<=NF; i++) if ($i == "via") print $(i+1)}')
    echo -ne "${CYAN}"IP Address: "${RESET}"
    read __IP_ADDRESS
    if [[ ! $__IP_ADDRESS =~ '^([0-9]{1,3}\.){3}[0-9]{1,3}$' && -n $__IP_ADDRESS ]]; then 
      _HandleError "Invalid IP Address"
      return 1
    fi
    if [[ -z $__IP_ADDRESS ]]; then
      [[ $device == "Wifi" ]] && local _ipAddr=$defaultWlanIP
      [[ $device == "Ethernet" ]] && local _ipAddr=$defaultLanIP
    else
      [[ $device == "Wifi" ]] && local _ipAddr=$__IP_ADDRESS
      [[ $device == "Ethernet" ]] && local _ipAddr=$__IP_ADDRESS
    fi
    echo -ne "${CYAN}"Subnet: "${RESET}"
    read __NETMASK
    if [[ ! $__NETMASK =~ '^([0-9]{1,3}\.){3}[0-9]{1,3}$' && -n $__NETMASK ]]; then
      _HandleError "Invalid Subnet Mask"
      return 1
    fi
    [[ -z $__NETMASK ]] && local _netmask="255.255.255.0" || local _netmask=$__NETMASK
    echo -ne "${CYAN}"Gateway: "${RESET}"
    read __GATEWAY
    if [[ ! $__GATEWAY =~ '^([0-9]{1,3}\.){3}[0-9]{1,3}$' && -n $__GATEWAY ]]; then
      _HandleError "Invalid Gateway"
      return 1
    fi
    if [[ -z $__GATEWAY ]]; then
      [[ $device == "Wifi" ]] && local _gateway=$defaultWlanGw
      [[ $device == "Ethernet" ]] && local _gateway=$defaultLanGw
    else
      [[ $device == "Wifi" ]] && local _gateway=$__GATEWAY
      [[ $device == "Ethernet" ]] && local _gateway=$__GATEWAY
    fi
    _HandleStart "Gateway: $_gateway | IP: $_ipAddr | Subnet: $_netmask"
    local changeStatis=$(powershell.exe /c "& {Start-Process powershell -verb RunAs -ArgumentList 'netsh interface ipv4 set address name=$device static $_ipAddr $_netmask $_gateway'}")
    [[ $? -eq 0 ]] && _HandleResult "Complete change IP Configuration" && return 1 || \
      _HandleError "Failed change IP Configuration" && return 1
  fi
  if [[ $nextTYPE == "dhcp" && $nextOPT == "ip" ]]; then
    _HandleStart "Settings up IP DHCP"
    local changeDHCP=$(powershell.exe /c "& {Start-Process powershell -verb RunAs -ArgumentList 'netsh interface ipv4 set address name=$device dhcp'}")
    [[ $? -eq 0 ]] && _HandleResult "Complete DHCP Setup" && return 1 || \
      _HandleError "Failed change" && return 1
  fi
  if [[ $nextTYPE == "static" && $nextOPT == "dns" ]]; then
    PS3=$(_HandleCustom ${CYAN} "Select DNS:" "")
    select dns in Local Google Cloudflare OpenDNS Adguard Quad9 Cancel; do
      case $dns in
        Local ) local dnsName="Local DNS" dnsOne="127.0.0.1" dnsTwo="127.0.1.1"; break;;
        Google ) local dnsName="Google DNS" dnsOne="8.8.8.8" dnsTwo="8.8.4.4"; break;;
        Cloudflare ) local dnsName="Cloudflare DNS" dnsOne="1.1.1.1" dnsTwo="1.0.0.1"; break;;
        OpenDNS ) local dnsName="OpenDNS" dnsOne="208.67.222.222" dnsTwo="208.67.220.220"; break;;
        AdGuard ) local dnsName="Adguard DNS" dnsOne="94.140.14.14" dnsTwo="94.140.15.15"; break;;
        Quad9 ) local dnsName="Quad9 DNS" dnsOne="9.9.9.9" dnsTwo="149.112.112.112"; break;;
        Cancel ) return 0;break;;
        * ) _HandleWarn "Selected is invalid!"; continue;;
      esac
    done
    _HandleStart "Setting up DNS $dnsName"
    local changeDNSSTATIC=$(powershell.exe /c "& {Start-Process powershell -verb RunAs -ArgumentList 'netsh interface ipv4 set dns name=$device static $dnsOne; netsh interface ipv4 add dns name=$device $dnsTwo index=2'}")
    [[ $? -eq 0 ]] && _HandleResult "Complete DNS Setup" && return 1 || \
      _HandleError "Failed change" && return 1
  fi
  if [[ $nextTYPE == "dhcp" && $nextOPT == "dns" ]]; then
    _HandleStart "Settings up DNS DHCP"
    local changeDHCPDNS=$(powershell.exe /c "& {Start-Process powershell -verb RunAs -ArgumentList 'netsh interface ipv4 set dns name=$device dhcp'}")
    [[ $? -eq 0 ]] && _HandleResult "Complete DHCP Setup" && return 1 || \
      _HandleError "Failed change" && return 1
  fi
}

function proxyConnect(){
  [[ $_systemType != "windows" ]] && _HandleError $_notSupport && return 1
  local lan='localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*'
  local regexPort='^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5]?[0-9]{1,4})$'
  local regexIp='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
  local regexProt='^(socks|http|https|ftp)$'
  local regPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  function ___PROXY___CHANGE____(){
    powershell.exe /c "& {
      Set-ItemProperty -path '$regPath' -name 'ProxyServer' -type 'String' -value "$1"
      Set-ItemProperty -path '$regPath' -name 'ProxyOverride' -type 'String' -value '$lan'
      Set-ItemProperty -path '$regPath' -name 'ProxyEnable' -type 'DWord' -value '1'
    }"
  }
  function ___PROXY___RESET____(){
    powershell.exe /c "& {
      Set-ItemProperty -path '$regPath' -name 'ProxyServer' -type 'String' -value ''
      Set-ItemProperty -path '$regPath' -name 'ProxyOverride' -type 'String' -value ''
      Set-ItemProperty -path '$regPath' -name 'ProxyEnable' -type 'DWord' -value '0'
    }"
  }
  function ___PROXY___TOGGLE____(){
    # ON = 1 & OFF = 0
    powershell.exe /c "& {
      Set-ItemProperty -path '$regPath' -name 'ProxyEnable' -type 'DWord' -value '$1'
    }"
  }
  function _proxy_connect_usage(){
    echo "Usage : proxyConnect [options] <domain>";
    echo "------------------------------------------------"
    echo "    -a        Set your own proxy"
    echo "    -d        Disable proxy"
    echo "    -e        Enable proxy"
    echo "    -h        Show this message"
    echo "    -p        Change port (127.0.0.1)"
    echo "    -r        Reset proxy"
    echo "    -s        Change socks 1080 proxy"
  }
  while getopts ":a:p:dersh" opt; do
    case $opt in
      a ) local inputPROT=$(echo "$OPTARG" | cut -d "=" -f 1)
          local inputIP=$(echo "$OPTARG" | cut -d ":" -f 1 | cut -d "=" -f 2)
          local inputPORT=$(echo "$OPTARG" | cut -d ":" -f 2)
          if [[ ! $inputPROT =~ $regexProt ]]; then _HandleError "Invalid PROTOCOL - '$inputPROT'" && return 1; fi
          if [[ ! $inputPORT =~ $regexPort ]]; then _HandleError "Invalid PORT - '$inputPORT'" && return 1; fi
          if [[ ! $inputIP =~ $regexIp ]]; then _HandleError "Invalid IP - '$inputIP'" && return 1; fi
          _HandleStart "Change proxy to '$OPTARG'"
          ___PROXY___CHANGE____ "$OPTARG"
          [[ $? -eq 0 ]] && _HandleResult "Success change proxy" || _HandleError "Failed change proxy"
          break;;
      d ) _HandleStart "Disable proxy"
          ___PROXY___TOGGLE____ 0
          [[ $? -eq 0 ]] && _HandleResult "Success disable proxy" || _HandleError "Failed disable proxy"
          break;;
      e ) _HandleStart "Enable proxy"
          ___PROXY___TOGGLE____ 1
          [[ $? -eq 0 ]] && _HandleResult "Success enable proxy" || _HandleError "Failed enable proxy"
          break;;
      p ) [[ ! $OPTARG =~ $regexPort ]] && _HandleError "Allow port only 1 - 65535" && return 1 && break
          _HandleStart "Change proxy to '127.0.0.1:$OPTARG'"
          ___PROXY___CHANGE____ "socks=127.0.0.1:$OPTARG"
          [[ $? -eq 0 ]] && _HandleResult "Success change proxy" || _HandleError "Failed change proxy"
          break;;
      r ) _HandleStart "Reset proxy to default"
          ___PROXY___RESET____
          [[ $? -eq 0 ]] && _HandleResult "Success change proxy" || _HandleError "Failed change proxy"
          break;;
      s ) _HandleStart "Change proxy to 127.0.0.1:1080"
          ___PROXY___CHANGE____ "socks=127.0.0.1:1080"
          [[ $? -eq 0 ]] && _HandleResult "Success change proxy" || _HandleError "Failed change proxy"
          break;;
      h ) _proxy_connect_usage; break;;
      : ) _HandleError "Option -$OPTARG requires an argument"; break;;
      \?) _HandleWarn "Invalid option -$OPTARG"; break;;
    esac
  done
  [[ $# -eq 0 ]] && _proxy_connect_usage; return 0
}

function sshConnect(){
  [[ ! $(_found ssh) ]] && _checkingPackage -i openssh -p ssh
  file_config="$HOME/.sshconnectrc"
  [[ ! -f $file_config ]] && touch $file_config
  function _ssh_connect_usage() {
    echo "Usage: sshConnect [options]"
    echo ""
    echo "Options :"
    echo "------------------------------------------------"
    echo "    -a ACCOUNT  Add ssh account"
    echo "    -c          Connect ssh account"
    echo "    -d          Delete ssh account"
    echo "    -h          Show this message"
    echo "    -k KEY      Add public key"
    echo "    -K          Show default public key"
    echo "    -s          Show all ssh account"
  }
  function check_ssh_connect(){
    if [[ ! $(cat $file_config) ]]; then
      _HandleError "Account list is empty" && return 1
    fi
  }
  if [[ $# -eq 0 ]]; then
    _ssh_connect_usage
    return 0
  fi
  while getopts ":a:k:Ksdch" opt; do
    case $opt in
      a ) [[ $OPTARG =~ '^[^@]+@[^@]+$' ]] && echo $OPTARG >> $file_config 2>/dev/null || _HandleError "Input must be user@hostname only"
          [[ $? -eq 0 ]] && _HandleResult "Added $OPTARG"
          break;;
      d )
        check_ssh_connect
        [[ $? -ne 0 ]] && return 1
        declare -A options=()
        while read -r line; do
          options["$line"]=$line
        done < $file_config
        local PS3=$(_HandleCustom ${CYAN} "Choose account:" " ")
        select option in "${options[@]}"; do
          sed -i "/$option/d" $file_config
          [[ $(grep -q $option $file_config) ]] && _HandleError "Failed to delete account $option" && break
          _HandleResult "Account deleted" && break
        done;;
      s )
        check_ssh_connect
        [[ $? -ne 0 ]] && return 1
        _HandleCustom ${CYAN} "Show all account :" "\n" && cat $file_config && break;;
      k )
        [[ ! -d "$HOME/.ssh" ]] && mkdir -p $HOME/.ssh
        [[ ! -f "$HOME/.ssh/authorized_keys" ]] && touch $HOME/.ssh/authorized_keys
        ssh_regex='^(ssh-ed25519|ssh-rsa)\s+[A-Za-z0-9+/]+[=]{0,2}\s+[A-Za-z0-9@.-]+$'
        [[ ! $OPTARG =~ $ssh_regex ]] && echo $OPTARG >> $HOME/.ssh/authorized_keys || _HandleError "SSH Key is not valid"
        [[ $? -eq 0 ]] && _HandleResult "Added key $OPTARG"
        break;;
      K )
        local choosed=("rsa" "ed25519" "Cancel")
        local PS3=$(_HandleCustom ${CYAN} "Choose cryptograph?" "")
        select cryptograph in "${choosed[@]}"; do
          case $cryptograph in
            rsa ) [[ ! -f "$HOME/.ssh/id_rsa.pub" || ! -f "$HOME/.ssh/id_rsa" ]] && \
              ssh-keygen -t rsa -b 4096 -o -a 100 && cat "$HOME/.ssh/id_rsa.pub" || \
              local rsaPub=$(cat $HOME/.ssh/id_rsa.pub) && _HandleCustom ${GREEN} "Key: " "$rsaPub"
              break;;
            ed25519 ) [[ ! -f "$HOME/.ssh/id_ed25519.pub" || ! -f "$HOME/.ssh/id_ed25519" ]] && \
              ssh-keygen -t ed25519 -a 100 && cat $HOME/.ssh/id_ed25519.pub || \
              local edPub=$(cat $HOME/.ssh/id_ed25519.pub) && _HandleCustom ${GREEN} "Key: " "$edPub"
              break;;
            Cancel ) return 1; break;;
          esac
        done;;
      c )
        check_ssh_connect
        [[ $? -ne 0 ]] && return 1
        function check() {
          local port=$1
          if [[ ! $port =~ '^[0-9]+$' ]]; then
            _HandleError "Invalid input!"
            return 1
          fi
          if [[ $port -lt 1 || $port -gt 65535 ]]; then
            _HandleError "Only range 1 - 65535"
            return 1
          fi
          [[ $? -ne 0 ]] && _HandleError "Invalid port" && return 1
        }
        declare -A options=()
        while read -r line; do
          options["$line"]=$line
        done < $file_config
        [[ $(cat $file_config) ]] && options["Cancel"]="Cancel" || return 1
        local PS3=$(_HandleCustom ${CYAN} "Choose account:" "")
        select option in "${options[@]}"; do
          [[ $option == "Cancel" ]] && return 0
          if [[ -z $option || ! $option ]]; then
            _HandleError "Invalid input!"
            continue
          else
            local account_ssh=${options["$option"]}
            break
          fi
        done
        echo -n "${CYAN}Custom Port${RESET} [22]: "
        read custom_port
        if [[ -n $custom_port ]]; then
          check $custom_port
          [[ $? -ne 0 ]] && return 1 && break
        fi
        echo -n "${CYAN}Dynamic Port${RESET} [default]: "
        read local_port
        if [[ -n $local_port ]]; then
          check $local_port
          [[ $? -ne 0 ]] && return 1 && break
        fi
        [[ -z $custom_port ]] && local port="22" || local port="$custom_port"
        [[ -z $local_port ]] && local socks="" || local socks="-D 127.0.0.1:$local_port"
        local chiper="Ciphers=chacha20-poly1305@openssh.com"
        local keax="KexAlgorithms=curve25519-sha256@libssh.org"
        local macs="MACs=hmac-sha2-256-etm@openssh.com"
        local hka="HostKeyAlgorithms=ssh-ed25519"
        ssh $account_ssh -p $port $socks -o $chiper -o $keax -o $macs -o $hka 2>/dev/null
        [[ $? -ne 0 ]] && _HandleError "Unable connect to server"
        break;;
      h ) ssh_connect_usage && return 0;;
      \? ) _HandleError "Invalid option: -$OPTARG"; return 1;;
      : ) _HandleError "Option -$OPTARG requires an ssh account"; return 1;;
    esac
  done
}

function restartDNS(){
  if $_thisTermux; then
    _HandleWarn "$_notSupport" && return 1
  elif $_thisWin; then
    _HandleStart "Restart DNS" && powershell.exe /c "&{ ipconfig /flushdns }" && return 0
  else
    for ___SYSTEMS___ in "ubuntu" "rhel" "fedora" "centos" "opensuse"; do
      [[ $(_found systemd-resolve) && "$_sysName" == "$___SYSTEMS___[@]" ]] && sudo systemd-resolve --flush-caches && return 0
      break
    done
  fi
}

function speeds(){
  if $_thisTermux; then
    [[ ! $(_found speedtest-go) ]] &&
      _checkingPackage -i speedtest-go -p speedtest-go && speedtest-go || speedtest-go
  else
    [[ ! $(_found speedtest) ]] &&
      _checkingPackage -i speedtest-cli -p speedtest && speedtest || speedtest
  fi
} 

function fileBrowser(){
  [[ ! $(_found curl) ]] && _checkingPackage -i curl -p curl
  [[ ! $(_found bash) ]] && _checkingPackage -i bash -p bash
  if [[ ! $(_found filebrowser) ]]; then
    _HandleStart "Install filebrowser"
    local getFileBrowser=$(curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash)
    [[ $? -eq 0 && $(_found filebrowser) ]] && _HandleResult "Success installing filebrowser" && return 0 || _HandleError $getFileBrowser && return 1
  fi
  function _file_browser_usage(){
    echo "Usage: fileBrowser [options]"
    echo ""
    echo "Options :"
    echo "------------------------------------------------"
    echo "    -a IP             Set the IP address to listen [Default: 0.0.0.0]"
    echo "    -d DIR            Set the directory to server [Default: '/home/<user>']"
    echo "    -D                Active as daemon (Running on the background)"
    echo "    -h                Show this message"
    echo "    -p NUMBER         Set the port number [Default: 8080]"
    echo "    -s                Stop filebrowser from daemon"
  }
  local daemon=false stop=false
  while getopts ":p:d:a:Dsh" option; do
    case "$option" in
      a)  local addr="$OPTARG" ;;
      p)  local port="$OPTARG" ;;
      d)  local dirs="$OPTARG" ;;
      D)  daemon=true ;;
      s)  stop=true ;;
      h)  _file_browser_usage; return 1;;
      \?) _HandleWarn "Invalid option: -$OPTARG"; return 1;;
      : ) return 1;;
    esac
  done
  [[ -z $addr ]] && addr="0.0.0.0"
  [[ -z $port ]] && port="8080"
  [[ -z $dirs ]] && dirs="$HOME"
  if $stop && $daemon; then
    _HandleError "Cannot running concurrently on options '-s' and '-D'!"
    return 1
  fi
  if $stop; then
    if [[ $(_processCheck filebrowser) ]]; then
      _HandleStart "Stopping filebrowser"
      local execute=$(killall filebrowser)
      [[ $? -eq 0 && ! $(_processCheck filebrowser) ]] && _HandleResult "Program has been stopped" && return 0 ||
        _HandleError "Failed stopping program" && return 1
    else
      _HandleWarn "File Browser is not running. Try using option '-D' instead"
      return 0
    fi
  fi
  if [[ $(_processCheck filebrowser) ]]; then
    _HandleWarn "Program already running"
    return 0
  fi
  if $daemon; then
    _HandleStart "Running as daemon"
    local runProgram=$(filebrowser -d "$HOME/.filebrowser.db" -p "$port" -a "$addr" -r "$dirs" > $HOME/.fileBrowser.log 2>&1 &)
    [[ $? -eq 0 ]] && _HandleResult "Success running on the background" &&
      echo "Open http://${addr}:${port}"
  else
    filebrowser -d "$HOME/.filebrowser.db" -p "$port" -a "$addr" -r "$dirs"
  fi  
}

function cloudTunnel(){
  if ! $_thisTermux; then
    _HandleError "$_notSupport"
    echo "Follow instruction on the Official Cloudflare: https://one.dash.cloudflare.com/"
    return 1
  fi
  if [[ ! $(_found cloudflared) ]]; then
    _HandleWarn "Install cloudflared first. Try running 'installBundles' and follow instructions."
    return 1
  fi
  function _cloudTunnel_usage(){
    echo "Usage: cloudTunnel [options] <token>"
    echo ""
    echo "Options :"
    echo "------------------------------------------------"
    echo "    -b <TOKEN>           Run on boot"
    echo "    -h                   Show this message"
    echo "    -r <TOKEN>           Running once"
    echo "    -S <TOKEN>           Installing service"
    echo "    -s <PROGRAM>         Stopping cloudflared process"
  }
  local running=false 
  local boot=false 
  local service=false
  local end=false
  while getopts ":r:b:S:sh" opt; do
    case $opt in
      r)  running=true
          local token="$OPTARG" ;;
      b)  boot=true
          local token="$OPTARG" ;;
      S)  service=true
          local token="$OPTARG" ;;
      s)  end=true ;;
      h) _cloudTunnel_usage; return 0;;
      \? ) _HandleError "Invalid option: -$OPTARG"; return 1;;
      : ) _HandleError "Option -$OPTARG requires an arguments"; return 1;;
    esac
  done
  if $end && $running || $end && $service; then
    _HandleError "Action denied"
    return 1
  fi
  [[ $# -eq 0 ]] && _cloudTunnel_usage && return 0
  if $running; then
    _HandleStart "Run cloudflared tunnel"
    if [[ $(_processCheck cloudflared) ]]; then
      _HandleWarn "Cloudflared already running"
      return 0
    fi
    local running=$(cloudflared --no-autoupdate tunnel run --token $token > $HOME/.cloudflared.log 2>&1 &)
    [[ $? -eq 0 ]] && _HandleResult "Success running tunnel" && return 0 ||
      _HandleError "Failed running tunnel" && return 1
  elif $end; then
    if [[ $(_processCheck cloudflared) ]]; then
      _HandleStart "Stopping cloudflared"
      local execute=$(killall cloudflared)
      [[ $? -eq 0 && ! $(_processCheck cloudflared) ]] && _HandleResult "Program has been stopped" && return 0 ||
        _HandleError "Failed stopping program" && return 1
    else
      _HandleWarn "Cloudflare is not running"
    fi
  elif $boot; then
    [[ ! -d "$HOME/.termux/boot/" ]] && mkdir -p $HOME/.termux/boot
    _HandleStart "Installing boot service"
    local execute=$(echo -ne "#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\ncloudflared --no-autoupdate tunnel run --token $token" > $HOME/.termux/boot/cloudflared && \
    chmod +x $HOME/.termux/boot/cloudflared)
    [[ $? -eq 0 && -f "$HOME/.termux/boot/cloudflared" ]] && _HandleResult "Success added autostart on boot" && return 0 ||
      _HandleError "Failed running on boot" && return 1
  elif $service; then
    echo "Cooming soon"
    return 0
  fi
}

########################### END NETTOOL ###########################
############################## TOOLS ##############################
function termux_tools(){
  if ! $_thisTermux; then _HandleWarn "$_notSupport" && return 1; fi
  function _termux_tools_usage(){
    echo "Usage: termux_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -b DIR          Backup Termux"
    echo "    -r FILE         Restore Termux"
    echo "    -a FILE_NAME    Create a script on boot"
    echo "    -s              Setup storage"
    echo "    -c              Change repo"
    echo "    -h              Show this message"
    echo "    -R              Install root-repo"
    echo "    -S              Install science-repo"
    echo "    -G              Install game-repo"
    echo "    -X              install X11-repo"
  }
  local BOOT="$HOME/.termux/boot"
  [[ ! -d $BOOT ]] && mkdir -p $BOOT
  while getopts ":b:r:a:scRSGXh" opt; do
    case $opt in
      a ) nano $BOOT/$OPTARG; break;;
      b ) [[ ! -d $OPTARG ]] && _HandleError "Invalid directory" && return 1 && break
          [[ ! $(_found tar) ]] && _checkingPackage -i tar
          _HandleStart "Backup termux"
          local files="$OPTARG/$(date +"%Y-%m-%d_%H:%M").tar.gz"
          local archive=$(tar -zcf $files -C /data/data/com.termux/files ./home ./usr)
          [[ $? -eq 0 && -f $files ]] && _HandleResult "Backup success" || _HandleError "Backup failed"
          break;;
      r ) local checkFiles=$(tar -tf $OPTARG | grep -E '^\.\/(home|usr)\/$')
          [[ ! -f $OPTARG || $? -ne 0 ]] && _HandleError "Invalid file" && return 1 && break
          _HandleStart "Restoring termux data"
          local archive=$(tar -zxf $OPTARG -C /data/data/com.termux/files --recursive-unlink --preserve-permissions)
          [[ $? -eq 0 ]] && _HandleResult "Success restored" || _HandleError "Restore failed"
          break;;
      s ) termux-setup-storage; break;;
      c ) termux-change-repo; break;;
      R ) install root-repo; break;;
      S ) install science-repo; break;;
      G ) install game-repo; break;;
      X ) install x11-repo; break;;
      h ) _termux_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1;;
      : ) _HandleError "Option '-$OPTARG' requires a argument" >&2; return 1;;
    esac
  done
  [[ $# -eq 0 ]] && _termux_tools_usage && return 0
}

function dl_tools(){
  [[ ! $(_found wget) ]] && _checkingPackage -i wget
  local directoryDownloads=""
  if $_thisTermux; then
    local directoryDownloads="/sdcard/Download"
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O $PREFIX/bin/yt-dlp && chmod a+rx $PREFIX/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  elif $_thisWin; then
    local getUser=$(powershell.exe /c "& {[System.Environment]::UserName}")
    local User=$(echo $getUser | tr -d '\r')
    local directoryDownloads="/mnt/c/Users/${User}/Downloads"
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(sudo wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && sudo chmod a+rx /usr/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  elif $_thisLinux; then
    if [[ ! -d "$HOME/Downloads" ]]; then
      mkdir -p "$HOME/Downloads"
      local directoryDownloads="$HOME/Downloads"
    else
      local directoryDownloads="$HOME/Downloads"
    fi
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(sudo wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && sudo chmod a+rx /usr/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  else
    _HandleWarn "$_notSupport" && return 1
  fi

  function _dl_tools_usage(){
    echo "Usage  : dl_tools [option] URL"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -d      Custom directory"
    echo "    -y      Use yt-dl program"
    echo "    -h      Show this message"
  }
  local custom=""
  local youtube=false
  while getopts ":d:yh" opt; do
    case $opt in
      d ) custom=$OPTARG;;
      y ) youtube=true;;
      : ) _HandleError "Option '-$OPTARG' requires a argument" >&2; break;;
    esac
  done
  [[ -n $custom && ! -d $custom ]] && mkdir -p $custom
  if $youtube; then
    if [[ -z $custom ]]; then
      _HandleStart "Downloading..."
      yt-dlp -q --progress -P "$directoryDownloads" "$@"
    elif [[ -n $custom ]]; then
      _HandleStart "Downloading..."
      yt-dlp -q --progress -P "$custom" "$@"
    fi
  else
    if [[ -z $custom ]]; then
      _HandleStart "Downloading..."
      echo $directoryDownloads
      wget -q --show-progress -P "$directoryDownloads" "$@"
    elif [[ -n $custom ]]; then
      _HandleStart "Downloading..."
      wget -q --show-progress -P "$custom" "$@"
    fi
  fi
}

function git_tools(){
  [[ ! $(_found git) ]] && _checkingPackage -i git
  function _git_tools_usage(){
    echo "Usage: git_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -p        Git Pull"
    echo "    -P        Git Push"
    echo "    -r        Soft reset commit"
    echo "    -R        Hard reset commit"
    echo "    -l        Git log commit"
    echo "    -s        Create own git server"
    echo "    -w PATH   Working dir for git server"
    echo "    -h        Show this message"
  }
  while getopts ":P:w:r:R:lpsh" opt; do
    case $opt in
      p ) git pull; break;;
      P ) git add . && git commit -m "$OPTARG" && git push; break;;
      s ) git init --bare && break;;
      r ) git reset --soft $OPTARG && break;;
      R ) git reset --hard $OPTARG && break;;
      l ) git log --oneline && break;;
      w ) [[ ! $OPTARG ]] && _HandleWarn "Cancel action.." && return 1
          [[ ! -d "./branches" || ! -d "./hooks" || ! -d "./info" || ! -d "./object" || ! -d "./refs" ]] && \
            _HandleError "GIT Server directory reqired";break
          [[ ! -f "./hooks/post-receive" ]] && touch ./hooks/post-receive && chmod +x ./hooks/post-receive
          [[ ! -d $OPTARG ]] && mkdir -p $OPTARG
          _HandleStart "Add ${GREEN}post-receive${RESET}"
          local post=$(echo -ne "#!/bin/sh\nGIT_WORK_TREE=$OPTARG git checkout -f" >> ./hooks/post-receive)
          [[ $? -eq 0 ]] && _HandleResult "Action success" || _HandleError "Failed writing ${GREEN}post-receive${RESET}"
          break;;
      h ) _git_tools_usage; break;;
      : ) _HandleError "Option -$OPTARG requires an argument" >&2; break;;
      \? ) _HandleError "Invalid option -$OPTARG" >&2; break;;
    esac
  done
}

function image_tools(){
  [[ ! $(_found convert) ]] && _checkingPackage -i imagemagick -p convert
  if [[ ! $(_found cwebp) ]]; then
    local search=$(search webp 2>/dev/null)
    for pkg in "libwebp-tools" "webp"; do
      if [[ $(echo $search | grep "$pkg") ]]; then
        _HandleWarn "cweb not installed. Installing now!"
        _HandleStart "Installing $pkg"
        local installpkg=$(_checkingPackage -i "$pkg" -p cwebp)
        [[ $? -eq 0 ]] && _HandleResult "Success installing $pkg" && break || \
          _HandleError "Failed installing $pkg" && return 1 && break
      else
        _HandleError "$_notSupport" && return 1 && break
      fi
    done
  fi
  [[ ! $(_found potrace) ]] && _checkingPackage -i potrace
  local imageExtension="3fr arw avif bmp cr2 crw cur dcm dcr dds dng \
    erf exr fax fts g3 g4 gif gv hdr heic heif hrz ico iiq ipl \
    jbg jbig jfi jfif jif jnx jp2 jpe jpeg jpg jps k25 kdc mac \
    map mef mng mrw mtv nef nrw orf otb pal palm pam pbm pcd pct \
    pcx pdb pef pes pfm pgm pgx picon pict pix plasma png pnm ppm \
    psd pwp raf ras rgb rgba rgbo rgf rla rle rw2 sct sfw sgi six \
    sixel sr2 srf sun svg tga tiff tim tm2 uyvy viff vips wbmp webp \
    wmz wpg x3f xbm xc xcf xpm xv xwd yuv"
  local compress=false
  function _image_tools_usage(){
    echo "Usage: image_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -c        Activate compress mode"
    echo "    -s        source file"
    echo "    -t        Target output file"
    echo "                  (not working on compress mode)"
    echo "    -h        Show this message"
  }
  while getopts ":s:t:ch" opt; do
    case $opt in
      s ) local sourceImage=$OPTARG;;
      t ) local target=$OPTARG;;
      c ) local compress=true;;
      h ) _image_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1; break;;
      : ) _HandleError "Option '-$OPTARG' requires" >&2; return 1; break;;
    esac
  done
  [[ $# -eq 0 ]] && _image_tools_usage && return 0
  if [[ $imageExtension =~ (^|[[:space:]])$sourceImage($|[[:space:]]) && ! $compress ]]; then
    [[ ! $target =~ '^(webp|jpg|jpeg|png|svg|ico)$' ]] && _HandleError "Invalid target" && return 1
    local allImage=$(find ./ -maxdepth 1 -type f -name "*.$sourceImage" | awk -F'/' '{printf "\"%s\" ", $NF}' | sed 's/,$//')
    [[ -z $allImage ]] && _HandleError "sourceImage image not exists" && return 1
    for images in $allImage; do
      local output="${images%.*}.$target"
      _HandleStart "Convert $images to $output"
      if [[ ${output##*.} == "ico" ]]; then
        local convert=$(convert -resize x16 -gravity center \
          -crop 16x16+0+0 "$iamges" -flatten -colors 256 \
          -background transparent "$output")
      elif [[ ${output##*.} == "svg" ]]; then
        local convert=$(convert "$images" "${images%.*}.ppm" && potrace \
          -s "${images%.*}.ppm" -o "$output" && rm -f "${images%.*}.ppm")
      else
        local convert=$(convert "$images" "$output")
      fi
      [[ $? -eq 0 && -f $output ]] && _HandleResult "Convert '$images' to '$output' success" && \
        return 0 || _HandleError "Failed converting '$images'" && return 1
      break
    done
  elif [[ ! $imageExtension =~ (^|[[:space:]])$sourceImage($|[[:space:]]) && ! $compress ]]; then
    [[ ! -f $sourceImage ]] && _HandleError "sourceImage image not exists" && return 1
    [[ $target =~ '^(webp|jpg|jpeg|png|svg|ico)$' ]] && local output="${sourceImage%.*}.$target" || \
      local output="$target"
    _HandleStart "Convert $sourceImage to $output"
    if [[ ${output##*.} == "ico" ]]; then
      local convert=$(convert -resize x16 -gravity center \
        -crop 16x16+0+0 "$sourceImage" -flatten -colors 256 \
        -background transparent "$output")
    elif [[ ${output##*.} == "svg" ]]; then
      local convert=$(convert "$sourceImage" "${sourceImage%.*}.ppm" && potrace \
        -s "${sourceImage%.*}.ppm" -o "$output" && rm -f "${images%.*}.ppm")
    else
      local convert=$(convert "$sourceImage" "$output")
    fi
    [[ $? -eq 0 && -f $output ]] && _HandleResult "Convert '$sourceImage' to '$output' success" && \
       return 0 || _HandleError "Failed converting '$sourceImage'" && return 1
  elif [[ $compress ]]; then
    if [[ ! $sourceImage =~ '^(jpg|jpeg|png|gif|bmp|tiff|tif|webp|jp2)$' ]]; then
      [[ ! -f $sourceImage ]] && _HandleError "sourceImage image not exists" && return 1
      local nameImage=${sourceImage%.*}
      local extImage=${sourceImage##*.}
      local watermark="compressed"
      local output="$nameImage-$watermark.$extImage"
      _HandleStart "Compressing $sourceImage"
      local processing=$(convert $sourceImage -compress Zip -quality 60 "$output")
      [[ $? -eq 0 ]] && _HandleResult "Success compressing to '$output'" && return 0 || \
        _HandleError "Failed compressing '$sourceImage'" && return 1
    elif [[ $sourceImage =~ '^(jpg|jpeg|png|gif|bmp|tiff|tif|webp|jp2)$' ]]; then
      find ./ -maxdepth 1 -type f -name "*.$sourceImage" | while IFS= read -r select; do
        [[ -z $select || ! $select ]] && _HandleError "Source image not exists" && return 1
        local nameImage=${select%.*}
        local extImage=${select##*.}
        local watermark="compressed"
        local output="$nameImage-$watermark.$extImage"
        echo -ne "${CYAN}Process:${RESET} Compressing ${GREEN}$select${RESET} to ${GREEN}$output${RESET} ~ "
        local processing=$(convert $select -compress Zip -quality 60 "$output")
        [[ $? -eq 0 && -f $output ]] && echo "${GREEN}OK${RESET}" || \
          echo "${RED}FAILED${RESET}" && return 1
      done
    fi
  fi
}

function document_tools(){
  [[ ! $(_found pandoc) ]] && _checkingPackage -i pandoc
  [[ ! $(_found gs) ]] && _checkingPackage -i ghostscript
  if [[ ! $(_found pdftk) ]]; then
    _checkingPackage -i pdftk
    if [[ $? -ne 0 ]] && [[ $_packageManager == "apk" ]]; then
      _HandleStart "Add compability to repository"
      sudo sh -c 'echo -ne "\nhttps://dl-cdn.alpinelinux.org/alpine/v3.8/main\nhttps://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories'
      _HandleStart "Updating repository"
      local process=$(update 2>/dev/null)
      _checkingPackage -i pdftk
    fi
  fi
  [[ ! $(_found pandoc) || ! $(_found gs) || ! $(_found pdftk) ]] && \
    _HandleError "Need some dependencies, run 'documment_tools' again!" && return 1
  local docExtension=("abw" "aw" "csv" "dbk" "djvu" "doc" "docm" "docx" \
    "dot" "dotm" "dotx" "html" "kwd" "odt" "oxps" "pdf" "rtf" \
    "sxw" "txt" "wps" "xls" "xlsx" "xps")
  function _document_tools_usage(){
    echo "Usage: document_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -c        Convert document mode"
    echo "    -e        Extension"
    echo "    -h        Show this message"
    echo "    -m        Merge PDF mode (all existed pdf)"
    echo "    -o        Target output file"
  }
  local __merge=false __convert=false
  PS3="$(_HandleCustom ${CYAN} "Select:" "")"
  while getopts ":m:f:o:q:h" opt; do
    case $opt in
      m ) local __merge=true && local __input="$OPTARG" ;;
      c ) local __convert=true && local __input="$OPTARG" ;;
      o ) local __output="$OPTARG" ;;
      e ) local __extension="$OPTARG" ;;
      h ) _document_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1; break;;
      : ) _HandleError "Option '-$OPTARG' requires" >&2; return 1; break;;
    esac
  done
  if [[ $# -eq 0 ]]; then _document_tools_usage && return 1; fi
  if [[ "${docExtension[*]}" =~ "\\b($__input)\\b" ]]; then
    if $__merge && $__convert; then _HandleError "Only one option you can do!" && return 1; fi
    if [[ $__merge ]]; then
      local getAllFile=($(find ./ -maxdepth 1 -type f -name "*.${__input}" -exec basename {} \; | tr '\n' ' '))
      [[ ${#getAllFile[@]} == 0 ]] && echo "File does not exist" && return 1
      [[ ! $__output ]] && __output="$(date +"%Y-%m-%d_%H:%M-merged").pdf"
      [[ ${__output##*.} != "pdf" ]] && _HandleError "Only extension PDF can used merge documments" && return 1 && break
      echo -ne "${CYAN}Process:${RESET} Merger to ${GREEN}$__output${RESET} ~ "
      local process=$(pdftk "${getAllFile[@]}" cat output "$__output")
      [[ $? -eq 0 && -f $__output ]] && echo "${GREEN}OK${RESET}" && return 0 || \
        echo "${RED}FAILED${RESET}" && return 1
    elif [[ $__convert ]]; then
      find ./ -maxdepth 1 -name "${__input##*.}" -type f | while read -r select; do
        [[ ! $select ]] && _HandleError "File does not exits" && return 1 && break
        [[ ! $__output ]] && _HandleError "Need output option!" && return 1 && break
        [[ ! "${docExtension[*]}" =~ "\\b($__output)\\b" ]] && local _output="${__output##*.}" || local _output="$__output"
        echo -ne "${CYAN}Process:${RESET} Convert ${GREEN}$select${RESET} to ${GREEN}$_output${RESET} ~ "
        local process=$(pandoc "$select" -o "${select%.*}.${_output##*.}")
        [[ $? -eq 0 && -f $_output ]] && echo "${GREEN}OK${RESET}" && return 0 || \
          echo "${RED}FAILED${RESET}" && return 1
      done
    fi
  else
    if $__merge && $__convert; then _HandleError "Only one option you can do!" && return 1; fi
    [[ ! -f $__input ]] && _HandleError "No such file existed!" && return 1
    if [[ $__merge ]]; then
      _HandleWarn "Only can use multiple documents. Try using 'pdf'!"
      return 0
    elif [[ $__convert ]]; then
      [[ -z $__output ]] && _HandleError "Need output option!" && return 1 && break
      [[ ! "${docExtension[*]}" =~ "\\b($__output)\\b" ]] && local _output="${__output##*.}" || local _output="$__output"
      _HandleStart "Convert $__input to $_output"
      local process=$(pandoc "$__input" -o "${__input%.*}.$_output")
      [[ $? -eq 0 && -f $_output ]] && _HandleResult "Convert '$__input' to '$_output' success" && \
        return 0 || _HandleError "Failed converting '$__input'" && return 1
    fi
  fi
}

function media_tools(){
  [[ ! $(_found ffmpeg) ]] && _checkingPackage -i ffmpeg
  function _media_tools_usage(){
    echo "Usage  : media_tools [OPTION] <format>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -h         Show this help message"
    echo "    -i         Input file"
    echo "    -f         Format extension file for output"
    echo "    -o         Output is optional, use for rename"
    echo "    -q         Set quality [default : medium]"
    echo "    -s         Resize for video [comming soon]"
    echo ""
  }
  local _all_video="3g2 3gp aaf asf av1 avchd avi cavs divx dv f4v \
    flv hevc m2ts m2v m4v mjpeg mkv mod mov mp4 mpeg mpeg-2 mpg mts \
    mxf ogv rm rmvb swf tod ts vob webm wmv wtv xvid"
  local _all_audio="8svx aac ac3 aiff amb amr ape au avr caf cdda cvs \
    cvsd cvu dss dts dvms fap flac fssd gsm gsrt hcom htk ima ircam m4a \
    m4r maud mp2 mp3 nist oga ogg opus paf prc pvf ra sd2 shn sln smp snd \
    sndr sndt sou sph spx tak tta txw vms voc vox vqf w64 wav wma wv wve xa"
  local input="" media="" output="" quality="medium" resize=""
  while getopts ":i:f:o:q:s:h" opt; do
    case $opt in
      i ) input="$OPTARG";;
      f ) format="$OPTARG";;
      o ) output="$OPTARG";;
      q ) quality="$OPTARG";;
      s ) resize="$OPTARG";;
      h ) _media_tools_usage;;
      \? ) _HandleError "Invalid option: -$OPTARG" >&2;;
      : ) _HandleWarn "Option -$OPTARG requires an argument." >&2;;
    esac
  done

  [[ -z $input || -z $format ]] && _HandleError "Missing input and format options." && return 1
  [[ -z $output ]] && output="${input%.*}.${format##*.}"
  local rv="" ext="${input%.*}" _output_ext="${output##*.}" _output_allow_ext="mp3 m4a opus flac"
  [[ $_all_video =~ (^|[[:space:]])$ext($|[[:space:]]) && $_output_allow_ext =~ (^|[[:space:]])$_output_ext($|[[:space:]]) ]] && rv="-vn"
  [[ -n "$rv" ]] && local ffmpeg_command="ffmpeg -i '$input' $rv" || \
    local ffmpeg_command="ffmpeg -i '$input'"

  case ${output##*.} in
    mp3 ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 9 '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 7 '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 5 '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 2 '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 0 '$output'" && break;;
      esac;;
    m4a ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a aac -b:a 64k '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a aac -b:a 96k '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a aac -b:a 128k '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a aac -b:a 192k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a aac -b:a 256k '$output'" && break;;
      esac;;
    opus ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 32k '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 64k '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 96k '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 128k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 192k '$output'" && break;;
      esac;;
    flac ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 0 '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 4 '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 8 '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 12 '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 16 '$output'" && break;;
      esac;;
    mp4 | mkv | flv | avi) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libx264 -crf 32 -c:a aac -b:a 96k '$output'" && break;;
        low) sh -c "$ffmpeg_command -c:v libx264 -crf 28 -c:a aac -b:a 128k '$output'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libx264 -crf 23 -c:a aac -b:a 192k '$output'" && break;;
        high) sh -c "$ffmpeg_command -c:v libx264 -crf 18 -c:a aac -b:a 256k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libx264 -crf 14 -c:a aac -b:a 320k '$output'" && break;;
      esac;;
    hevc) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libx265 -crf 35 -c:a aac -b:a 96k '${output##*.}.mp4'" && break;;
        low) sh -c "$ffmpeg_command -c:v libx265 -crf 28 -c:a aac -b:a 128k '${output##*.}.mp4'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libx265 -crf 23 -c:a aac -b:a 192k '${output##*.}.mp4'" && break;;
        high) sh -c "$ffmpeg_command -c:v libx265 -crf 18 -c:a aac -b:a 256k '${output##*.}.mp4'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libx265 -crf 14 -c:a aac -b:a 320k '${output##*.}.mp4'" && break;;
      esac;;
    webm) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libvpx -crf 35 -b:v 100K -c:a libvorbis -b:a 64K '$output'" && break;;
        low) sh -c "$ffmpeg_command -c:v libvpx -crf 28 -b:v 500K -c:a libvorbis -b:a 128K '$output'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libvpx -crf 23 -b:v 1M -c:a libvorbis -b:a 192K '$output'" && break;;
        high) sh -c "$ffmpeg_command -c:v libvpx -crf 18 -b:v 2M -c:a libvorbis -b:a 256K '$output'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libvpx -crf 14 -b:v 4M -c:a libvorbis -b:a 320K '$output'" && break;;
      esac;;
    *) _HandleError "Invalid audio output format: '$output'" && break
  esac
}

############################ END TOOLS ############################
########################## TOOLS BUNDLEs ##########################
function installBundles(){
  function install_bundles_docker(){
    if $_thisTermux || $_thisWin; then _HandleWarn "$_notSupport" && return 1; fi
    function ___INSTALL__DOCKER__DU___(){
      _HandleStart "Install dependency"
      local stepone=$(update && installnc ca-certificates curl gnupg2 software-properties-common)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Install GPG Docker"
      local steptwo=$(curl -fsSL https://download.docker.com/linux/$1/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg)
      [[ $? -ne 0 ]] && _HandleError "Failed install GPG" && return 1
      _HandleStart "Add repo to system"
      local stepthree=$(echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
            https://download.docker.com/linux/$1 $(lsb_release -cs) stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repo to system" && return 1
      _HandleStart "Install Docker"
      local stepfour=$(update && installnc docker-ce docker-ce-cli containerd.io && \
        sudo usermod -aG docker $USER)
      [[ $? -ne 0 ]] && _HandleError "Failed install Docker" && return 1 || _HandleResult "Docker successfulty installed" && return 1
    }
    function ___CHECK__DOCKER___(){
      [[ $(_found docker) ]] && _HandleResult "Already installed" && return 0
    }
    if [[ $_sysName == "ubuntu" || $_sysName == "debian" ]]; then
      ___CHECK__DOCKER___
      ___INSTALL__DOCKER__DU___ "$_sysName"
      return 0
    elif [[ $_sysName == "centos" ]]; then
      ___CHECK__DOCKER___
      _HandleStart "Install dependency"
      local stepone=$(installnc yum-utils)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Add repo to system"
      local steptwo=$(sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repo to system" && return 1
      _HandleStart "Install docker"
      local stepthree=$(installnc docker-ce docker-ce-cli containerd.io && \
        sudo usermod -aG docker $USER)
      [[ $? -ne 0 ]] && _HandleError "Failed install Docker" && return 1 || \
        _HandleResult "Docker successfulty installed" && return 0
    elif [[ $_sysName == "fedora" ]]; then
      _HandleStart "Install dependency"
      local stepone=$(installnc dnf-plugins-core)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Add repo to system"
      local steptwo=$(sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repo to system" && return 1
      _HandleStart "Install docker"
      local stepthree=$(installnc docker-ce docker-ce-cli containerd.io && \
        sudo usermod -aG docker $USER)
      [[ $? -ne 0 ]] && _HandleError "Failed install Docker" && return 1 || \
        _HandleResult "Docker successfulty installed" && return 0
    else
      _HandleWarn "$_notSupport" && return 1
    fi
  }
  function install_bundles_kubernetes_adm(){
    if $_thisTermux || $_thisWin; then _HandleWarn "$_notSupport" && return 1; fi
    [[ $(_found kubeadm) ]] && _HandleResult "Already installed" && return 0
    if [[ $_sysName == "ubuntu" || $_sysName == "debian" ]]; then
      _HandleStart "Install dependency"
      local stepone=$(update && installnc apt-transport-https ca-certificates curl)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Add kubernetes repository"
      local steptwo=$(curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
        sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" && update)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repository" && return 1
      _HandleStart "Install kubernetes master"
      local stepthree=$(installnc kubeadm kubelet kubectl)
      [[ $? -ne 0 ]] && _HandleError "Failed install kubernetes master" && return 1
      _HandleStart "Hold package from update"
      local stepfour=$(holdpackage kubeadm kubelet kubectl)
      [[ $? -ne 0 ]] && _HandleError "Failed hold package" && return 1 || \
        _HandleResult "Success installing kubernetes master" && return 0
    elif [[ $_sysName == "centos" || $_sysName == "rhel" || $_sysName == "redhat" || $_sysName == "fedora" ]]; then
      _HandleStart "Adding repository"
      local stepone=$(sudo sh -c 'echo -e "[kubernetes]\nname=Kubernetes\nbaseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" \
        > /etc/yum.repos.d/kubernetes.repo' && update)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repository" && return 1
      _HandleStart "Install kubernetes master"
      local steptwo=$(installnc kubeadm kubelet kubectl)
      [[ $? -ne 0 ]] && _HandleError "Failed install" && return 1
      _HandleStart "Activate kubelet startup on boot"
      local stepthree=$(sudo systemctl enable --now kubelet)
      [[ $? -ne 0 ]] && _HandleError "Failed enable kubelet startup" && return 1 || \
        _HandleResult "Success installing kubernetes master" && return 0
    elif [[ $_sysName == "arch" || $_sysName == "manjaro" ]]; then
      _HandleStart "Install kubernetes master"
      local stepone=$(aurinc kubernetes-bin)
      [[ $? -eq 0 ]] && _HandleResult "Success installing kubernetes master" && return 0 || \
        _HandleError "Failed installing kubernetes master" && return 1
    elif [[ $_sysName == "amzn" ]]; then
      _HandleStart "Install dependency"
      local stepone=$(amazon-linux-extras install epel)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Install kubernetes master"
      local steptwo=$(sudo yum install -y kubeadm kubelet kubectl)
      [[ $? -ne 0 ]] && _HandleError "Failed install kubernetes master" && return 1
      _HandleStart "Activate kubelet startup on boot"
      local stepthree=$(sudo systemctl enable --now kubelet)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repository" && return 1
      _HandleResult "Success installing kubernetes master" && return 0
    else
      _HandleWarn "$_notSupport"
    fi
  }
  function install_bundles_minikube(){
    if $_thisTermux || $_thisWin; then _HandleWarn "$_notSupport" && return 1; fi
    [[ $(_found kubectl) ]] && _HandleResult "Already installed" && return 0
    if [[ $_sysName == "ubuntu" || $_sysName == "debian" ]]; then
      _HandleStart "Install minikube"
      local steps=$(curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
      sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d && \
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
      update && install kubectl)
      [[ $? -eq 0 ]] && _HandleResult "Success installing minikube" && return 0 || \
        _HandleError "Failed installing minikube" && return 1
    elif [[ $_sysName == "amzn" || $_sysName == "fedora" || \
      $_sysName == "centos" || $_sysName == "redhat" || \
      $_sysName == "rhel" || $_sysName == "centos" ]]; then
      _HandleStart "Install minikube"
      local stepone=$(sudo sh -c 'echo -e "[kubernetes]\nname=Kubernetes\nbaseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" \
        > /etc/yum.repos.d/kubernetes.repo' && update && sudo yum install -y kubectl)
      [[ $? -eq 0 ]] && _HandleResult "Success installing minikube" && return 0 || \
        _HandleError "Failed installing minikube" && return 1
    else
      _HandleWarn "$_notSupport"
      return 1
    fi
  }
  function install_bundles_cloudflared(){
    [[ $(_found cloudflared) ]] && _HandleResult "Already installed" && return 0
    if [[ $(search cloudflared &>/dev/null | grep "cloudflared") ]]; then
      _checkingPackage -i cloudflared
    else
      local url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-"
      function installing_cloudflared_package(){
        _HandleStart "Installing cloudflared"
        if [[ $PREFIX ]]; then
          local run=$(wget -O $PREFIX/bin/cloudflared $url$1 && chmod +x $PREFIX/bin/cloudflared)
        elif [[ -d "/usr/bin/" ]]; then
          local run=$(sudo wget -O /usr/bin/cloudflared $url$1 && chmod +x /usr/bin/cloudflared)
        elif [[ -d "/bin/" ]]; then
          local run=$(sudo wget -O /bin/cloudflared $url$1 && chmod +x /bin/cloudflared)
        else
          _HandleWarn "$_notSupport" && return 1
        fi
        [[ $? -eq 0 && $(_found cloudflared) ]] && _HandleResult "Success installing cloudflared" && return 0 || \
          _HandleError "Failed installing cloudflared" && return 1
      }
      case $_sysArch in
        x86_64 ) installing_cloudflared_package amd64; break;;
        i686 ) installing_cloudflared_package 386; break;;
        armv7l ) installing_cloudflared_package arm; break;;
        aarch64 ) installing_cloudflared_package arm64; break;;
        * ) _HandleWarn "$_notSupport"; break;;
      esac
    fi
  }
  function install_bundles_snap(){
    if $_thisTermux; then _HandleWarn "$_notSupport" && return 1; fi
    [[ ! $(_found sudo) ]] && _checkingPackage -i sudo
    [[ $(_found usermod) ]] && sudo usermod -G wheel $USER
    if [[ ! $(_found snap) ]]; then
      _HandleStart "Installing snap to system"
      if [[ $_sysName == "ubuntu" || $_sysName == "debian" ]]; then
        update && installnc snapd
      elif [[ $_sysName == "fedora" ]]; then
        installnc snapd
      elif [[ $_sysName == "centos" || $_sysName == "redhat" || $_sysName == "rhel" ]]; then
        installnc epel-release && installnc snapd
      elif [[ $_sysName == "opensuse" ]]; then
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_15.0 snappy
        sudo zypper --gpg-auto-import-keys refresh
        sudo zypper dup --from snappy
        installnc snapd
      elif [[ $_sysName == "manjaro" ]]; then
        installnc snapd
      elif [[ $_sysName == "arch" ]]; then
        cd $HOME && git clone https://aur.archlinux.org/snapd.git && cd snapd && makepkg -si && cd $HOME
      else
        _HandleWarn "Not listed, will be update!"
      fi
    fi
  }
  function install_bundles_aur(){
    if $_thisTermux; then _HandleWarn "$_notSupport" && return 1; fi
    if [[ ! $(_found yay) ]]; then
      [[ ! $(_found git) ]] && _checkingPackage -i git
      installnc base-devel
      cd /opt
      git clone https://aur.archlinux.org/yay.git
      sudo chown -R $USER:$USER ./yay.git
      cd yay.git && makepkg -si && cd $HOME
    else
      _HandleResult "Already installed"
    fi
  }
  PS3=$(_HandleCustom ${CYAN} "Install:" "")
  select opt in "Snap" "AUR" "Docker" "Minikube" "Kubernetes Master" "Cloudflared" "Cancel"; do
    case $opt in
      "AUR" ) install_bundles_aur; break;;
      "Snap" ) install_bundles_snap; break;;
      "Docker" ) install_bundles_docker; break;;
      "Minikube" ) install_bundles_minikube; break;;
      "Kubernetes Master" ) install_bundles_kubernetes_adm; break;;
      "Cloudflared" ) install_bundles_cloudflared; break;;
      "Cancel" ) break;;
      * ) _HandleWarn "Selected is invalid!"; continue;;
    esac
  done
}

######################## END TOOLS BUNDLEs ########################
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

function sysctl(){
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
    echo "Usage: sysctl <options> service"
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
    [[ $actionSV =~ $thisAction ]] && $_sysService $actionSV $service || _HandleWarn "$_notSupport"
  elif $_thisWin; then
    local thisAction='^(start|restart|stop|status|enable|disable)$'
    [[ $action =~ $thisAction ]] && sudo $_sysService $service $action || _HandleWarn "$_notSupport"
  else
    local thisAction='^(start|restart|stop|status|enable|disable)$'
    local updown='^(up|down)$'
    if [[ $_sysService == "systemctl" ]]; then
      [[ $action =~ $thisAction ]] && sudo $_sysService $action $service && return 0 ||
        _HandleWarn "$_notSupport" && return 1
    elif [[ $_sysService == "service" ]]; then
      [[ $action == $thisAction ]] && sudo $_sysService $service $action && return 0 ||
        _HandleWarn "$_notSupport" && return 1
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
  [[ ! $(_found exa) ]] && _checkingPackage -i exa -p exa && exa --icons --group-directories-first $* || exa --icons --group-directories-first $*
}

function aliasHelp(){
  function __PACKAGE_MANAGER__(){
    echo "    install         Install package"
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
    echo "    sysctl          System control"
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

alias i="install"
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