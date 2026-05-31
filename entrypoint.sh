#!/bin/bash
set -e

echo "[hollowpoint] Starting up..."

# Git config
if [ -n "$GIT_AUTHOR_NAME" ]; then
  git config --global user.name "$GIT_AUTHOR_NAME"
  echo "[hollowpoint] Git user.name set to: $GIT_AUTHOR_NAME"
fi

if [ -n "$GIT_AUTHOR_EMAIL" ]; then
  git config --global user.email "$GIT_AUTHOR_EMAIL"
  echo "[hollowpoint] Git user.email set to: $GIT_AUTHOR_EMAIL"
fi

# Wire GitHub token into git HTTPS
if [ -n "$GITHUB_TOKEN" ]; then
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
  echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null && \
    echo "[hollowpoint] GitHub CLI authenticated" || \
    echo "[hollowpoint] GitHub CLI auth failed — token may be invalid"
else
  echo "[hollowpoint] WARN: GITHUB_TOKEN not set — git push/pull and gh CLI will not work"
fi

# Ollama API key check
if [ -z "$OLLAMA_API_KEY" ]; then
  echo "[hollowpoint] WARN: OLLAMA_API_KEY not set — Ollama Cloud models will not work"
fi

# Start Ollama server in background
echo "[hollowpoint] Starting Ollama server..."
ollama serve > /var/log/ollama.log 2>&1 &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "[hollowpoint] Waiting for Ollama to be ready..."
for i in $(seq 1 15); do
  if ollama list > /dev/null 2>&1; then
    echo "[hollowpoint] Ollama ready"
    break
  fi
  if [ $i -eq 15 ]; then
    echo "[hollowpoint] WARN: Ollama did not become ready in time — check /var/log/ollama.log"
  fi
  sleep 1
done

echo "[hollowpoint] Ready. Exec in with: docker exec -it claude-code bash"
echo "[hollowpoint] Then run: ollama launch claude"

# Keep container alive
exec tail -f /dev/null
