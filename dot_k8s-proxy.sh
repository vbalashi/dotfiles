[ -n "$BASH_VERSION" ] || return 0

unalias kubectl 2>/dev/null; unset -f kubectl 2>/dev/null
unalias helm 2>/dev/null; unset -f helm 2>/dev/null

kubectl() {
  http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 \
  no_proxy=localhost,127.0.0.1 command kubectl "$@"
}
alias k=kubectl

helm() {
  http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 \
  no_proxy=localhost,127.0.0.1 command helm "$@"
}
alias h=helm

source <(command kubectl completion bash)
complete -o default -F __start_kubectl kubectl
complete -o default -F __start_kubectl k

source <(command helm completion bash)
complete -o default -F __start_helm helm
complete -o default -F __start_helm h
