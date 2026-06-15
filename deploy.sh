#!/bin/sh
set -e

REPO_URL="https://raw.githubusercontent.com/zeeke/cloude-box/main/deploy/claude-box.yaml"
ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "File not found: $ENV_FILE" >&2
  echo "Usage: $0 [path/to/.env]" >&2
  exit 1
fi

curl -fsSL "$REPO_URL" | kubectl apply -f -

kubectl create secret generic claude-box-secrets \
  -n claude-box \
  --from-env-file="$ENV_FILE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Ready. Run: kubectl exec -it claude-box-0 -n claude-box -- claude"
