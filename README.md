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

## CI Setup

The GitHub Actions workflow builds and pushes to `quay.io/apanatto/claude-box` on every push to `main`.

Required repository secrets:

- `QUAY_USERNAME` — Quay.io robot account username
- `QUAY_PASSWORD` — Quay.io robot account token

## Building locally

```bash
docker build -t claude-box .
```
