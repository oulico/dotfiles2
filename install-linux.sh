#!/bin/bash

set -e

echo "================================"
echo "Linux Dotfiles Installation"
echo "================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS distribution${NC}"
    exit 1
fi

echo -e "${GREEN}Detected OS: $OS${NC}"

# Install packages based on distribution
install_packages() {
    echo -e "${YELLOW}Installing required packages...${NC}"

    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                neovim \
                tmux \
                git \
                curl \
                wget \
                ripgrep \
                fd-find \
                build-essential \
                python3-pip \
                nodejs \
                npm
            ;;
        fedora|rhel|centos)
            sudo dnf install -y \
                neovim \
                tmux \
                git \
                curl \
                wget \
                ripgrep \
                fd-find \
                gcc \
                gcc-c++ \
                make \
                python3-pip \
                nodejs \
                npm
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm \
                neovim \
                tmux \
                git \
                curl \
                wget \
                ripgrep \
                fd \
                base-devel \
                python-pip \
                nodejs \
                npm
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $OS${NC}"
            exit 1
            ;;
    esac
}

# Backup existing configs
backup_configs() {
    echo -e "${YELLOW}Backing up existing configurations...${NC}"

    BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$BACKUP_DIR/"
    [ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$BACKUP_DIR/"
    [ -f "$HOME/.vimrc" ] && mv "$HOME/.vimrc" "$BACKUP_DIR/"

    echo -e "${GREEN}Backup created at: $BACKUP_DIR${NC}"
}

# Create symlinks
create_symlinks() {
    echo -e "${YELLOW}Creating symlinks...${NC}"

    DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Neovim
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo -e "${GREEN}✓ Linked nvim config${NC}"

    # Tmux
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo -e "${GREEN}✓ Linked tmux config${NC}"

    # Vimrc
    ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    echo -e "${GREEN}✓ Linked vimrc${NC}"
}

# Install Neovim plugins
install_nvim_plugins() {
    echo -e "${YELLOW}Installing Neovim plugins...${NC}"

    # Check if lazy.nvim exists in the config
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        echo -e "${GREEN}Neovim will install plugins on first run.${NC}"
        echo -e "${YELLOW}Please open nvim and wait for plugins to install, then restart nvim.${NC}"
    else
        echo -e "${YELLOW}⚠ init.lua not found, skipping plugin installation${NC}"
    fi
}

# Main installation
main() {
    echo ""
    read -p "Do you want to proceed with installation? (y/n) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    install_packages
    backup_configs
    create_symlinks
    install_nvim_plugins

    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Installation completed!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal"
    echo "2. Run 'nvim' to check if everything works"
    echo "3. Run 'tmux' to test tmux configuration"
    echo ""
}

main
