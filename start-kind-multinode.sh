#/bin/bash

# Exit on error
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CLUSTER_NAME=lenovo
KIND_HOST="192.168.2.151"

# Run like DASHBOARD=1 foo.sh if you want the dashboard
DASHBOARD=${DASHBOARD:-""}

source ${DIR}/common.sh

header_text "Stopping existing proxy sessions"
killall kubectl || true

header_text "Deleting current cluster"
kind delete cluster --name=${CLUSTER_NAME}

header_text "Creating a new cluster with name=${CLUSTER_NAME}, contextName=kind-${CLUSTER_NAME}"
kind create cluster --config=${DIR}/kind-exposed-multinode.yaml --name=${CLUSTER_NAME}

if [ -n "$DASHBOARD" ]; then
  header_text "Installing dashboard"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

  header_text "Creating resources for dashboard"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
  
  cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

  header_text "Starting proxy in the background"
  nohup kubectl proxy --address="${KIND_HOST}" --accept-hosts='.*' &>/dev/null &
fi

header_text "Printing cluster information"
kubectl cluster-info --context kind-${CLUSTER_NAME}

header_text "Extracting KUBECONFIG into ${DIR}/kind.kubeconfig"
kubectl config view --minify --flatten --context=kind-${CLUSTER_NAME} > ${DIR}/kind.kubeconfig

if [ -n "$DASHBOARD" ]; then
  header_text "Printing bearer token for dashboard"
  kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
  echo ""
fi
