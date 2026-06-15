FROM fedora:42

RUN dnf install -y \
    curl \
    git \
    ca-certificates \
    ripgrep \
    gh \
    golang \
    tmux \
    procps-ng \
    iproute \
    net-tools \
    bind-utils \
    && dnf clean all

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/root/.local/bin:$PATH"
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
ENV CLAUDE_CODE_SKIP_INITIAL_SETUP=1

WORKDIR /workspace

ENTRYPOINT ["tmux", "new-session", "-A", "-s", "claude", "claude", "--dangerously-skip-permissions"]
