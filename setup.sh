#!/bin/bash
# ===========================================================================
# Bootstrap script for dotfiles
# Usage: curl -fsSL <raw-url>/setup.sh | bash
#   or:  ./setup.sh
# ===========================================================================
set -euo pipefail

echo "=== Dotfiles Bootstrap ==="

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------
if [ -f /etc/arch-release ]; then
    OS="arch"
elif [ -f /etc/debian_version ]; then
    OS="debian"
else
    OS="unknown"
fi
echo "Detected OS: $OS"

# ---------------------------------------------------------------------------
# Install base packages (Arch)
# ---------------------------------------------------------------------------
if [ "$OS" = "arch" ]; then
    echo "Installing base packages via pacman..."
    sudo pacman -S --needed --noconfirm \
        git curl base-devel \
        bash-completion \
        zoxide fzf \
        tmux \
        openssh \
        wakeonlan

    # AUR packages via yay (if available)
    if command -v yay >/dev/null 2>&1; then
        echo "Installing AUR packages via yay..."
        yay -S --needed --noconfirm \
            1password-cli \
            adguardvpn-cli-bin \
            devpod-cli-bin 2>/dev/null || true
    fi
fi

# ---------------------------------------------------------------------------
# Install mise (if not present)
# ---------------------------------------------------------------------------
if ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise..."
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# ---------------------------------------------------------------------------
# Install chezmoi (if not present)
# ---------------------------------------------------------------------------
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi via mise..."
    mise use -g chezmoi@latest
fi

# ---------------------------------------------------------------------------
# Initialize and apply dotfiles
# ---------------------------------------------------------------------------
DOTFILES_REPO="${DOTFILES_REPO:-}"

if [ -n "$DOTFILES_REPO" ]; then
    echo "Initializing chezmoi from $DOTFILES_REPO..."
    chezmoi init --apply "$DOTFILES_REPO"
elif [ -d "$HOME/dotfiles" ]; then
    echo "Applying dotfiles from ~/dotfiles..."
    chezmoi init --source "$HOME/dotfiles" --apply
else
    echo "No dotfiles repo specified. Set DOTFILES_REPO or clone to ~/dotfiles first."
    exit 1
fi

# ---------------------------------------------------------------------------
# Install mise tools
# ---------------------------------------------------------------------------
echo "Installing mise tools..."
mise trust "$HOME/.config/mise/config.toml" 2>/dev/null || true
mise install

# ---------------------------------------------------------------------------
# Install tmux plugin manager
# ---------------------------------------------------------------------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo ""
echo "=== Done! ==="
echo "Open a new terminal or run: source ~/.bashrc"
echo "In tmux: prefix + I to install plugins"
