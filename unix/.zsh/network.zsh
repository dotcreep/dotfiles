if [[ $(command -v nmap) ]]; then
  alias nmap-tcp="nmap -sS -p"
  alias nmap-udp="nmap -sU -p"
  alias nmap-quick="nmap -T4 -F"
  alias nmap-stealth="nmap -sS -sV -T4 -O -A -F --version-light"
  alias nmap-allports="nmap -p-"
  alias nmap-service="nmap -sV"
  alias nmap-os="nmap -O"
  alias nmap-scripts="nmap -sC"
  alias nmap-fragment="nmap -f"
  alias nmap-mtu="nmap --mtu 24"
  alias nmap-idle="nmap -sI"
  alias nmap-ping="nmap -sn"
  alias nmap-arp="nmap -PR"
  alias nmap-output="nmap -oN scan.txt"
  alias nmap-xml="nmap -oX scan.xml"
  alias nmap-aggressive="nmap -T4 -A -v"
  alias nmap-intense="nmap -T4 -A -v --top-ports 1000"
  alias nmap-http="nmap -p 80,8080"
  alias nmap-https="nmap -p 443"
  alias nmap-ssh="nmap -p 22"
  alias nmap-ftp="nmap -p 21"
  alias nmap-dns="nmap -p 53"
  alias nmap-smb="nmap -p 139,445"
  alias nmap-rdp="nmap -p 3389"
  alias nmap-help="nmap --help"
fi