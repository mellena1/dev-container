# Dev Container

A Docker-based development environment with all my tools pre-configured, including OpenCode running in web mode.

## What's Included

- **Base**: Alpine Linux (minimal, fast)
- **Shell**: Zsh with dotfiles managed via stow
- **Editor**: Neovim with my custom configuration
- **Tools**: Go (latest), Bun, Git, Tmux, GitHub CLI (gh), fzf
- **OpenCode**: Running in web mode on port 4096

## Quick Start

```bash
# Build
docker build -t dev-environment:latest .

# Run
docker run -it -p 4096:4096 dev-environment:latest
```

Access OpenCode at http://localhost:4096

## With Projects

```bash
docker run -it -p 4096:4096 \
  -v ~/projects:/home/dev/projects \
  dev-environment:latest
```

## With SSH Keys

```bash
docker run -it -p 4096:4096 \
  -v ~/.ssh:/home/dev/.ssh \
  dev-environment:latest
```

