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
                tmux \
                git \
                curl \
                wget \
                ripgrep \
                fd-find \
                build-essential \
                python3-pip \
                nodejs \
                npm \
                ninja-build \
                gettext \
                cmake \
                unzip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y \
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
                npm \
                ninja-build \
                gettext \
                cmake \
                unzip
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm \
                tmux \
                git \
                curl \
                wget \
                ripgrep \
                fd \
                base-devel \
                python-pip \
                nodejs \
                npm \
                ninja \
                cmake \
                unzip
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $OS${NC}"
            exit 1
            ;;
    esac
}

# Build Neovim from source
build_neovim() {
    echo -e "${YELLOW}Building Neovim from source...${NC}"

    # Check if nvim is already installed and up to date
    if command -v nvim &> /dev/null; then
        CURRENT_VERSION=$(nvim --version | head -n1 | awk '{print $2}')
        echo -e "${GREEN}Neovim $CURRENT_VERSION is already installed${NC}"

        read -p "Do you want to rebuild/update Neovim? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping Neovim build."
            return
        fi
    fi

    NVIM_BUILD_DIR="$HOME/.local/src/neovim"

    # Clone or update Neovim repository
    if [ -d "$NVIM_BUILD_DIR" ]; then
        echo -e "${YELLOW}Updating Neovim repository...${NC}"
        cd "$NVIM_BUILD_DIR"
        git fetch --all
        git checkout stable
        git pull
    else
        echo -e "${YELLOW}Cloning Neovim repository...${NC}"
        mkdir -p "$HOME/.local/src"
        git clone https://github.com/neovim/neovim.git "$NVIM_BUILD_DIR"
        cd "$NVIM_BUILD_DIR"
        git checkout stable
    fi

    # Clean previous build
    make distclean 2>/dev/null || true

    # Build and install
    echo -e "${YELLOW}Building Neovim (this may take a few minutes)...${NC}"
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install

    # Verify installation
    if command -v nvim &> /dev/null; then
        NVIM_VERSION=$(nvim --version | head -n1)
        echo -e "${GREEN}✓ Neovim installed successfully: $NVIM_VERSION${NC}"
    else
        echo -e "${RED}✗ Neovim installation failed${NC}"
        exit 1
    fi

    cd - > /dev/null
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

    # Install lazy.nvim plugin manager
    LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$LAZY_PATH" ]; then
        echo -e "${YELLOW}Installing lazy.nvim plugin manager...${NC}"
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
        echo -e "${GREEN}✓ lazy.nvim installed${NC}"
    else
        echo -e "${GREEN}✓ lazy.nvim already installed${NC}"
    fi

    # Check if lazy.nvim exists in the config
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        echo -e "${YELLOW}Installing plugins (this may take a minute)...${NC}"
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
        echo -e "${GREEN}✓ Plugins installed${NC}"
        echo -e "${YELLOW}Note: Open nvim and restart it once if you see any errors on first run${NC}"
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
    build_neovim
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
