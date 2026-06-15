FROM fedora:42

RUN dnf install -y \
    curl \
    git \
    ca-certificates \
    ripgrep \
    gh \
    golang \
    && dnf clean all

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/root/.local/bin:$PATH"
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

WORKDIR /workspace

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
