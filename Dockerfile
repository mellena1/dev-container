FROM ubuntu:24.04

# Install essential tools as root
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    zsh \
    tmux \
    ca-certificates \
    gnupg \
    build-essential \
    unzip \
    stow \
    make \
    bash \
    fzf \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Neovim PPA and install latest version
RUN add-apt-repository -y ppa:neovim-ppa/unstable && \
    apt-get update && \
    apt-get install -y neovim && \
    rm -rf /var/lib/apt/lists/*

# Install Go (latest version from go.dev)
RUN bash -c 'GO_VERSION=$(curl -s "https://go.dev/VERSION?m=text" | head -n1) && \
    wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    echo "Installed Go version: ${GO_VERSION}"'

# Install GitHub CLI (gh) from binary
RUN GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name"' | awk -F'"' '{print $4}') && \
    wget -q "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION#v}_linux_amd64.tar.gz" -O /tmp/gh.tar.gz && \
    tar -xzf /tmp/gh.tar.gz -C /tmp && \
    mv /tmp/gh_${GH_VERSION#v}_linux_amd64/bin/gh /usr/local/bin/ && \
    rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION#v}_linux_amd64 && \
    echo "Installed GitHub CLI version: ${GH_VERSION}"

# Create dev user (no sudo)
RUN groupadd -g 1001 dev && \
    useradd -m -u 1001 -g dev -s /bin/zsh dev

# Create Go directories for dev user
RUN mkdir -p /home/dev/go/{bin,src,pkg} && \
    chown -R dev:dev /home/dev/go

# Set up .local folder
RUN mkdir -p /home/dev/.local/share && \
    chown -R dev:dev /home/dev/.local

# Install bun and OpenCode as dev user
USER dev
WORKDIR /home/dev

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Create node symlink for OpenCode compatibility
RUN ln -sf /home/dev/.bun/bin/bun /home/dev/.bun/bin/node

# Install OpenCode via Bun (using full path since PATH not updated yet)
RUN /home/dev/.bun/bin/bun install -g opencode-ai

# Set environment variables for dev user
ENV PATH="/usr/local/go/bin:/home/dev/.bun/bin:${PATH}"
ENV GOPATH="/home/dev/go"
ENV GOBIN="$GOPATH/bin"
# Force opencode to use glibc binary (not musl)
ENV OPENCODE_BIN_PATH="/home/dev/.bun/install/global/node_modules/opencode-linux-x64/bin/opencode"

# Clone dotfiles from public repository and use stow to create symlinks
RUN git clone https://github.com/mellena1/dotfiles.git /home/dev/.dotfiles && \
    cd /home/dev/.dotfiles && \
    make && \
    rm -rf /home/dev/.dotfiles/.git

# Run zshrc to install oh-my-zsh, plugins, themes during build
RUN zsh -c "source ~/.zshrc"

# Copy entrypoint script
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to dev user
USER dev

# Expose OpenCode web port
EXPOSE 4096

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
