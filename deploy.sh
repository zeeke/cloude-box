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

ADC_FILE="${GOOGLE_APPLICATION_CREDENTIALS:-$HOME/.config/gcloud/application_default_credentials.json}"
ADC_ARG=""
if [ -f "$ADC_FILE" ]; then
  ADC_ARG="--from-file=application_default_credentials.json=$ADC_FILE"
  echo "GCP credentials loaded from $ADC_FILE"
else
  echo "No GCP credentials found at $ADC_FILE — skipping"
fi

kubectl create secret generic claude-box-secrets \
  -n claude-box \
  --from-env-file="$ENV_FILE" \
  $ADC_ARG \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Ready. Run: kubectl exec -it claude-box-0 -n claude-box -- claude"
