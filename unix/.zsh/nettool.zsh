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
      if [[ "$_sysName" == "alpine" ]]; then
        [[ ! $(_found dig) ]] && _checkingPackage -i bind-tools -p dig
      else
        [[ ! $(_found dig) ]] && _checkingPackage -i dnsutils -p dig
      fi
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
    echo "    -b          Backup ssh account"
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
  while getopts ":a:k:bKsdch" opt; do
    case $opt in
      a ) [[ $OPTARG =~ '^[^@]+@[^@]+$' ]] && echo $OPTARG >> $file_config 2>/dev/null || _HandleError "Input must be user@hostname only"
          [[ $? -eq 0 ]] && _HandleResult "Added $OPTARG"
          break;;
      b ) _HandleStart "Backup SSH Account"
          echo "File directory : \$HOME/.sshconnectrc"
          echo "Account Lists: "
          cat $file_config;;
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
        local strictKey="StrictHostKeyChecking=no"
        ssh $account_ssh -p $port $socks -o $chiper -o $keax -o $macs -o $hka -o $strictKey 2>/dev/null
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