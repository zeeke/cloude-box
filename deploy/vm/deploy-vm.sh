#!/bin/sh
set -e

REPO_URL="https://raw.githubusercontent.com/zeeke/cloude-box/main/deploy/vm/claude-box-vm.yaml"
ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "File not found: $ENV_FILE" >&2
  echo "Usage: $0 [path/to/.env]" >&2
  exit 1
fi

if ! kubectl api-resources --api-group=kubevirt.io 2>/dev/null | grep -q VirtualMachine; then
  echo "OpenShift Virtualization not found. Installing..."
  kubectl create namespace openshift-cnv 2>/dev/null || true
  kubectl apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: kubevirt-hyperconverged-group
  namespace: openshift-cnv
spec:
  targetNamespaces:
  - openshift-cnv
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec:
  channel: stable
  name: kubevirt-hyperconverged
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  echo "Waiting for operator to become ready..."
  kubectl wait --for=condition=CatalogSourcesUnhealthy=false subscription/kubevirt-hyperconverged -n openshift-cnv --timeout=300s 2>/dev/null || true
  sleep 30
  kubectl apply -f - <<'EOF'
apiVersion: hco.kubevirt.io/v1beta1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec: {}
EOF
  echo "Waiting for HyperConverged to be ready..."
  kubectl wait --for=condition=Available hyperconverged/kubevirt-hyperconverged -n openshift-cnv --timeout=600s
  echo "OpenShift Virtualization installed."
fi

curl -fsSL "$REPO_URL" | kubectl apply -f -

kubectl create secret generic claude-box-secrets \
  -n claude-box-vm \
  --from-env-file="$ENV_FILE" \
  --dry-run=client -o yaml | kubectl apply -f -

ADC_FILE="${GOOGLE_APPLICATION_CREDENTIALS:-$HOME/.config/gcloud/application_default_credentials.json}"
if [ -f "$ADC_FILE" ]; then
  kubectl patch secret claude-box-secrets \
    -n claude-box-vm \
    --type merge \
    -p "{\"data\":{\"application_default_credentials.json\":\"$(base64 -w0 "$ADC_FILE")\"}}"
  echo "GCP credentials loaded from $ADC_FILE"
else
  echo "No GCP credentials found at $ADC_FILE — skipping"
fi

echo "Ready. Connect with: virtctl -n claude-box-vm ssh claude@claude-box-vm-0"
