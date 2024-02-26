########################## TOOLS BUNDLEs ##########################
function installBundles(){
  function install_bundles_docker(){
    if $_thisTermux || $_thisWin; then _HandleWarn "$_notSupport" && return 1; fi
    function ___INSTALL__DOCKER__DU___(){
      _HandleStart "Install dependency"
      local stepone=$(update && installnc ca-certificates curl gnupg2 software-properties-common 2>/dev/null)
      [[ $? -ne 0 ]] && _HandleError "Failed install dependency" && return 1
      _HandleStart "Install GPG Docker"
      local steptwo=$(curl -fsSL https://download.docker.com/linux/$1/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg)
      [[ $? -ne 0 ]] && _HandleError "Failed install GPG" && return 1
      _HandleStart "Add repo to system"
      if [[ $(lsb_release -cs) == "n/a" ]]; then
        local _typeCheck=$(grep 'VERSION=' /etc/os-release | grep -o -P '(?<=\().+?(?=\))')
      else
        local _typeCheck=$(lsb_release -cs)
      fi
      if [[ $_typeCheck == "debian" ]]; then
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
      fi
      local stepthree=$(echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
            https://download.docker.com/linux/$1 $_typeCheck stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null)
      [[ $? -ne 0 ]] && _HandleError "Failed adding repo to system" && return 1
      _HandleStart "Install Docker"
      local stepfour=$(update && installnc docker-ce docker-ce-cli containerd.io 2>/dev/null && \
        sudo usermod -aG docker $USER)
      [[ $? -ne 0 && $(_found docker) ]] && _HandleError "Failed install Docker" && return 1 || _HandleResult "Docker successfulty installed" && return 1
    }
    function ___CHECK__DOCKER___(){
      [[ $(_found docker) ]] && _HandleResult "Already installed" && return 0
    }
    if [[ $_sysName == "ubuntu" || $_sysName == "debian" ]]; then
      ___CHECK__DOCKER___
      ___INSTALL__DOCKER__DU___ "$_sysName"
      return 0
    elif [[ $_sysName == "alpine" ]]; then
      ___CHECK__DOCKER___
      _HandleStart "Install docker"
      local stepone=$(install docker docker-cli-compose)
      [[ $? -ne 0 ]] && _HandleError "Failed install docker" && return 1
      _HandleStart "Add user to docker group"
      local steptwo=$(sudo addgroup $USER docker)
      [[ $? -ne 0 ]] && _HandleError "Failed add to group" && return 1
      _HandleStart "Start services"
      local stepthree=$(sudo rc-update add docker default && sudo service docker start)
      [[ $? -ne 0 ]] && _HandleError "Failed run service" && return 1
      [[ $? -ne 0 && $(_found docker) ]] && _HandleResult "Docker successfully installed" && return 0 ||
        _HandleError "Failed install docker" && return 1
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
      local stepone=$(update && installnc apt-transport-https ca-certificates curl 2>/dev/null)
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
          local run=$(sudo wget -O /usr/bin/cloudflared $url$1 && sudo chmod +x /usr/bin/cloudflared)
        elif [[ -d "/bin/" ]]; then
          local run=$(sudo wget -O /bin/cloudflared $url$1 && sudo chmod +x /bin/cloudflared)
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
        update && installnc snapd 2>/dev/null
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