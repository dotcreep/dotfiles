# Ansible
if which ansible &>/dev/null 2&>1; then
    function ansible-version(){
        ansible --version
    }

    function ansible-role-init(){
        if ! [ -z $1 ] ; then
            echo "Ansible Role : $1 Creating...."
            ansible-galaxy init $1
            tree $1
        else
            echo "Usage : ansible-role-init <role name>"
            echo "Example : ansible-role-init role1"
        fi
    }

    alias a='ansible '
    alias aconf='ansible-config '
    alias acon='ansible-console '
    alias aver='ansible-version'
    alias arinit='ansible-role-init'
    alias aplaybook='ansible-playbook '
    alias ainv='ansible-inventory '
    alias adoc='ansible-doc '
    alias agal='ansible-galaxy '
    alias apull='ansible-pull '
    alias aval='ansible-vault'
fi

# Kubernetes
if which kubectl &>/dev/null 2&>1; then
    # This command is used a LOT both below and in daily life
    alias k='kubectl'

    # Execute a kubectl command against all namespaces
    alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

    # Apply a YML file
    alias kaf='kubectl apply -f'

    # Drop into an interactive terminal on a container
    alias keti='kubectl exec -t -i'

    # Manage configuration quickly to switch contexts between local, dev ad staging.
    alias kcuc='kubectl config use-context'
    alias kcsc='kubectl config set-context'
    alias kcdc='kubectl config delete-context'
    alias kccc='kubectl config current-context'

    # List all contexts
    alias kcgc='kubectl config get-contexts'

    # General aliases
    alias kdel='kubectl delete'
    alias kdelf='kubectl delete -f'

    # Pod management.
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods --all-namespaces'
    alias kgpw='kgp --watch'
    alias kgpwide='kgp -o wide'
    alias kep='kubectl edit pods'
    alias kdp='kubectl describe pods'
    alias kdelp='kubectl delete pods'
    alias kgpall='kubectl get pods --all-namespaces -o wide'

    # get pod by label: kgpl "app=myapp" -n myns
    alias kgpl='kgp -l'

    # get pod by namespace: kgpn kube-system"
    alias kgpn='kgp -n'

    # Service management.
    alias kgs='kubectl get svc'
    alias kgsa='kubectl get svc --all-namespaces'
    alias kgsw='kgs --watch'
    alias kgswide='kgs -o wide'
    alias kes='kubectl edit svc'
    alias kds='kubectl describe svc'
    alias kdels='kubectl delete svc'

    # Ingress management
    alias kgi='kubectl get ingress'
    alias kgia='kubectl get ingress --all-namespaces'
    alias kei='kubectl edit ingress'
    alias kdi='kubectl describe ingress'
    alias kdeli='kubectl delete ingress'

    # Namespace management
    alias kgns='kubectl get namespaces'
    alias kens='kubectl edit namespace'
    alias kdns='kubectl describe namespace'
    alias kdelns='kubectl delete namespace'
    alias kcn='kubectl config set-context --current --namespace'

    # ConfigMap management
    alias kgcm='kubectl get configmaps'
    alias kgcma='kubectl get configmaps --all-namespaces'
    alias kecm='kubectl edit configmap'
    alias kdcm='kubectl describe configmap'
    alias kdelcm='kubectl delete configmap'

    # Secret management
    alias kgsec='kubectl get secret'
    alias kgseca='kubectl get secret --all-namespaces'
    alias kdsec='kubectl describe secret'
    alias kdelsec='kubectl delete secret'

    # Deployment management.
    alias kgd='kubectl get deployment'
    alias kgda='kubectl get deployment --all-namespaces'
    alias kgdw='kgd --watch'
    alias kgdwide='kgd -o wide'
    alias ked='kubectl edit deployment'
    alias kdd='kubectl describe deployment'
    alias kdeld='kubectl delete deployment'
    alias ksd='kubectl scale deployment'
    alias krsd='kubectl rollout status deployment'

    function kres(){
      kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
    }

    # Rollout management.
    alias kgrs='kubectl get replicaset'
    alias kdrs='kubectl describe replicaset'
    alias kers='kubectl edit replicaset'
    alias krh='kubectl rollout history'
    alias kru='kubectl rollout undo'

    # Statefulset management.
    alias kgss='kubectl get statefulset'
    alias kgssa='kubectl get statefulset --all-namespaces'
    alias kgssw='kgss --watch'
    alias kgsswide='kgss -o wide'
    alias kess='kubectl edit statefulset'
    alias kdss='kubectl describe statefulset'
    alias kdelss='kubectl delete statefulset'
    alias ksss='kubectl scale statefulset'
    alias krsss='kubectl rollout status statefulset'

    # Port forwarding
    alias kpf="kubectl port-forward"

    # Tools for accessing all information
    alias kga='kubectl get all'
    alias kgaa='kubectl get all --all-namespaces'

    # Logs
    alias kl='kubectl logs'
    alias kl1h='kubectl logs --since 1h'
    alias kl1m='kubectl logs --since 1m'
    alias kl1s='kubectl logs --since 1s'
    alias klf='kubectl logs -f'
    alias klf1h='kubectl logs --since 1h -f'
    alias klf1m='kubectl logs --since 1m -f'
    alias klf1s='kubectl logs --since 1s -f'

    # File copy
    alias kcp='kubectl cp'

    # Node Management
    alias kgno='kubectl get nodes'
    alias keno='kubectl edit node'
    alias kdno='kubectl describe node'
    alias kdelno='kubectl delete node'

    # PVC management.
    alias kgpvc='kubectl get pvc'
    alias kgpvca='kubectl get pvc --all-namespaces'
    alias kgpvcw='kgpvc --watch'
    alias kepvc='kubectl edit pvc'
    alias kdpvc='kubectl describe pvc'
    alias kdelpvc='kubectl delete pvc'

    # Service account management.
    alias kdsa="kubectl describe sa"
    alias kdelsa="kubectl delete sa"

    # DaemonSet management.
    alias kgds='kubectl get daemonset'
    alias kgdsw='kgds --watch'
    alias keds='kubectl edit daemonset'
    alias kdds='kubectl describe daemonset'
    alias kdelds='kubectl delete daemonset'

    # CronJob management.
    alias kgcj='kubectl get cronjob'
    alias kecj='kubectl edit cronjob'
    alias kdcj='kubectl describe cronjob'
    alias kdelcj='kubectl delete cronjob'

    # Job management.
    alias kgj='kubectl get job'
    alias kej='kubectl edit job'
    alias kdj='kubectl describe job'
    alias kdelj='kubectl delete job'
fi


if which docker &>/dev/null 2&>1; then
    alias dcu='docker compose up -d'
    alias dcd='docker compose down'
    alias dbl='docker build'
    alias dcin='docker container inspect'
    alias dcls='docker container ls'
    alias dclsa='docker container ls -a'
    alias dib='docker image build'
    alias dii='docker image inspect'
    alias dils='docker image ls'
    alias dipu='docker image push'
    alias dirm='docker image rm'
    alias dit='docker image tag'
    alias dlo='docker container logs'
    alias dnc='docker network create'
    alias dncn='docker network connect'
    alias dndcn='docker network disconnect'
    alias dni='docker network inspect'
    alias dnls='docker network ls'
    alias dnrm='docker network rm'
    alias dpo='docker container port'
    alias dpu='docker pull'
    alias dr='docker container run'
    alias drit='docker container run -it'
    alias drm='docker container rm'
    alias 'drm!'='docker container rm -f'
    alias dsinit='docker swarm init'
    alias dsjoin='docker swarm join'
    alias dst='docker container start'
    alias drs='docker container restart'
    alias dsta='docker stop $(docker ps -q)'
    alias dstp='docker container stop'
    alias dtop='docker top'
    alias dvi='docker volume inspect'
    alias dvls='docker volume ls'
    alias dvprune='docker volume prune'
    alias dxc='docker container exec'
    alias dxcit='docker container exec -it'
fi

if which terraform &>/dev/null 2&>1; then
    alias tf='terraform'
    alias tfa='terraform apply'
    alias tfc='terraform console'
    alias tfd='terraform destroy'
    alias tff='terraform fmt'
    alias tfi='terraform init'
    alias tfo='terraform output'
    alias tfp='terraform plan'
    alias tfv='terraform validate'
fi