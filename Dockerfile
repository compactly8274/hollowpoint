FROM node:22-slim

LABEL org.opencontainers.image.title="hollowpoint"
LABEL org.opencontainers.image.description="Claude Code + Ollama Cloud — self-contained agentic coding container"
LABEL org.opencontainers.image.source="https://github.com/YOUR_GITHUB_USER/hollowpoint"

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y -qq \
      git \
      curl \
      zstd \
      ca-certificates \
      gnupg \
      ripgrep \
      fd-find \
      tmux && \
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update -qq && \
    apt-get install -y -qq gh && \
    # fd is packaged as fdfind on Debian
    ln -s /usr/bin/fdfind /usr/local/bin/fd && \
    # Ollama (always latest)
    curl -fsSL https://ollama.com/install.sh | sh && \
    # Claude Code (always latest)
    npm install -g @anthropic-ai/claude-code --quiet && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY tmux.conf /root/.tmux.conf

RUN printf '\n# Persist bash history in the mounted config dir\nexport HISTFILE=/root/.claude/.bash_history\nexport HISTSIZE=10000\nexport HISTFILESIZE=10000\n\n# Auto-attach to persistent tmux session on exec\n[ -z "$TMUX" ] && { tmux attach-session -t main 2>/dev/null || tmux new-session -s main; }\n' >> /root/.bashrc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
