# hollowpoint

A self-contained Docker image that bundles Claude Code and Ollama into a persistent agentic coding container. Designed for TrueNAS Scale with Dockge, but works anywhere Docker runs.

## What’s inside

- **Claude Code** (latest) — Anthropic’s agentic CLI coding tool
- **Ollama** (latest) — model runner with cloud model support
- **GitHub CLI** (`gh`) — push, pull, merge, PR from the terminal
- **Git** — pre-configured with token auth via env vars

The image rebuilds automatically every week via GitHub Actions, so Claude Code and Ollama are always up to date without any manual intervention.

## Quick start

### 1. Pull and run (Dockge / docker-compose)

Copy `docker-compose.yml` into a new Dockge stack and fill in your env vars:

```yaml
services:
  claude-code:
    image: ghcr.io/YOUR_GITHUB_USER/hollowpoint:latest
    container_name: claude-code
    stdin_open: true
    tty: true
    restart: unless-stopped
    environment:
      - OLLAMA_API_KEY=your_ollama_cloud_api_key
      - GITHUB_TOKEN=your_github_pat
      - GIT_AUTHOR_NAME=Your Name
      - GIT_AUTHOR_EMAIL=your@email.com
      - GIT_COMMITTER_NAME=Your Name
      - GIT_COMMITTER_EMAIL=your@email.com
    volumes:
      - /mnt/Data/appdata/claude-code/config:/root/.claude
      - /mnt/Data/appdata/claude-code/projects:/workspace
```

### 2. Connect via SSH / Termius

```bash
docker exec -it claude-code bash
ollama launch claude        # interactive model picker
```

## Environment variables

|Variable             |Required|Description                                  |
|---------------------|--------|---------------------------------------------|
|`OLLAMA_API_KEY`     |Yes     |Ollama Cloud API key from ollama.com/settings|
|`GITHUB_TOKEN`       |No      |GitHub PAT for push/pull/merge/PR            |
|`GIT_AUTHOR_NAME`    |No      |Name stamped on commits                      |
|`GIT_AUTHOR_EMAIL`   |No      |Email stamped on commits                     |
|`GIT_COMMITTER_NAME` |No      |Committer name (usually same as author)      |
|`GIT_COMMITTER_EMAIL`|No      |Committer email (usually same as author)     |

## Volumes

|Path           |Purpose                                                        |
|---------------|---------------------------------------------------------------|
|`/root/.claude`|Claude Code config, MCP servers, session history — persist this|
|`/workspace`   |Your projects — mount repos here                               |

## Ollama Cloud models

Once exec’d in, `ollama launch claude` shows an interactive picker. Recommended models:

|Model                  |Best for                         |
|-----------------------|---------------------------------|
|`kimi-k2.5:cloud`      |General agentic tasks, multimodal|
|`qwen3.5:cloud`        |Balanced coding, fast            |
|`glm-5.1:cloud`        |Best SWE-Bench score             |
|`deepseek-v4-pro:cloud`|Frontier reasoning, large context|

## GitHub CLI usage

```bash
gh repo list
gh pr list --repo org/repo
gh pr create --title "fix: something" --body "..." --base main
gh pr merge 42 --squash
```

## Updating

The image rebuilds every Sunday automatically. To pull the latest on TrueNAS:

```bash
docker pull ghcr.io/YOUR_GITHUB_USER/hollowpoint:latest
# then restart the stack in Dockge
```


## Building locally

```bash
git clone https://github.com/YOUR_GITHUB_USER/hollowpoint
cd hollowpoint
docker build -t hollowpoint .
```