# claude-box

Containerized [Claude Code](https://claude.ai/code) with `--dangerously-skip-permissions` enabled.

## Usage

Pull the image:

```bash
docker pull quay.io/apanatto/claude-box
```

### Print mode

Pass a prompt, get output, container exits:

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  quay.io/apanatto/claude-box \
  -p "explain quicksort"
```

### Workspace mode

Mount your code and work interactively:

```bash
docker run --rm -it \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -v $(pwd):/workspace \
  quay.io/apanatto/claude-box
```

### Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes | Your Anthropic API key |
| `ANTHROPIC_MODEL` | No | Override the default model |

All additional Claude Code flags can be passed as arguments after the image name.

## Deploy to Kubernetes

Create a `.env` file with your credentials:

```bash
ANTHROPIC_API_KEY=sk-ant-...
GH_TOKEN=ghp_...
CLOUD_ML_REGION=us-east5
ANTHROPIC_VERTEX_PROJECT_ID=my-project-id
CLAUDE_CODE_OAUTH_TOKEN=oauth-...
```

Then deploy:

```bash
curl -fsSL https://raw.githubusercontent.com/zeeke/cloude-box/main/deploy.sh | sh
```

Connect to the box:

```bash
kubectl exec -it claude-box -- claude
```

## CI Setup

The GitHub Actions workflow builds and pushes to `quay.io/apanatto/claude-box` on every push to `main`.

Required repository secrets:

- `QUAY_USERNAME` — Quay.io robot account username
- `QUAY_PASSWORD` — Quay.io robot account token

## Building locally

```bash
docker build -t claude-box .
```
