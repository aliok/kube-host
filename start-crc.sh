#/bin/bash

# Exit on error
set -e

# This needs increasing the timeout in /etc/sudoers
echo "Need sudo"
sudo echo "Ok"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source ${DIR}/common.sh

header_text "Deleting current cluster"
crc delete || true
crc cleanup

header_text "Configuring CRC"
crc config set cpus 6 
crc config set memory 24000
crc config set kubeadmin-password admin
crc config set enable-cluster-monitoring true
crc setup

header_text "Creating a new cluster"
crc start --pull-secret-file=${DIR}/crc-pull-secret.txt

header_text "Printing cluster information"
kubectl cluster-info --context crc-admin

header_text "Extracting KUBECONFIG into ${DIR}/crc.kubeconfig"
kubectl config view --minify --flatten --context=crc-admin > ${DIR}/crc.kubeconfig

header_text "Setting up HAProxy"
export CRC_IP=$(crc ip)
sudo tee /etc/haproxy/haproxy.cfg &>/dev/null <<EOF
global
    # debug

defaults
    log global
    mode http
    timeout connect 5000
    timeout client 500000
    timeout server 500000

frontend apps
    bind 0.0.0.0:80
    option tcplog
    mode tcp
    default_backend apps

frontend apps_ssl
    bind 0.0.0.0:443
    option tcplog
    mode tcp
    default_backend apps_ssl

backend apps
    mode tcp
    balance roundrobin
    server webserver1 $CRC_IP:80 check

backend apps_ssl
    mode tcp
    balance roundrobin
    option ssl-hello-chk
    server webserver1 $CRC_IP:443 check

frontend api
    bind 0.0.0.0:6443
    option tcplog
    mode tcp
    default_backend api

backend api
    mode tcp
    balance roundrobin
    option ssl-hello-chk
    server webserver1 $CRC_IP:6443 check
EOF

header_text "Restarting haproxy"
sudo systemctl restart haproxy

