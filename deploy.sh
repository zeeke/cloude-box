#!/bin/sh
set -e

REPO_URL="https://raw.githubusercontent.com/zeeke/cloude-box/main/deploy/claude-box.yaml"

SECRET_ARGS=""
for var in ANTHROPIC_API_KEY GH_TOKEN CLOUD_ML_REGION ANTHROPIC_VERTEX_PROJECT_ID CLAUDE_CODE_OAUTH_TOKEN; do
  eval val=\$$var
  if [ -n "$val" ]; then
    SECRET_ARGS="$SECRET_ARGS --from-literal=$var=$val"
  fi
done

if [ -z "$SECRET_ARGS" ]; then
  echo "No environment variables set. Export at least one of: ANTHROPIC_API_KEY, GH_TOKEN, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID" >&2
  exit 1
fi

kubectl create secret generic claude-box-secrets \
  $SECRET_ARGS \
  --dry-run=client -o yaml | kubectl apply -f -

curl -fsSL "$REPO_URL" | kubectl apply -f -

echo "Ready. Run: kubectl exec -it claude-box -- claude"
