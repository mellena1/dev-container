#!/bin/bash

echo "========================================"
echo "Starting Development Container"
echo "========================================"
echo "User: $(whoami)"
echo "Home: $HOME"
echo "Working Directory: $(pwd)"
echo "========================================"
echo "Go version: $(go version 2>/dev/null || echo 'Not installed')"
echo "Bun version: $(bun --version 2>/dev/null || echo 'Not installed')"
echo "Neovim version: $(nvim --version | head -n1)"
echo "OpenCode version: $(opencode --version 2>/dev/null || echo 'Not installed')"
echo "GitHub CLI version: $(gh --version 2>/dev/null | head -n1 || echo 'Not installed')"
echo "========================================"
echo "Starting OpenCode Web Server..."
echo "Host: 0.0.0.0"
echo "Port: 4096"
echo "========================================"

opencode web --hostname 0.0.0.0 --port 4096
