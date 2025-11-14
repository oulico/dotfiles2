#!/bin/bash

set -e

echo "================================"
echo "macOS Dotfiles Installation"
echo "================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script is for macOS only!${NC}"
    exit 1
fi

echo -e "${GREEN}Detected macOS${NC}"

# Install Homebrew if not installed
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}✓ Homebrew already installed${NC}"
    fi
}

# Install packages
install_packages() {
    echo -e "${YELLOW}Installing required packages...${NC}"

    brew update

    # Install packages
    packages=(
        neovim
        tmux
        git
        curl
        wget
        ripgrep
        fd
        node
        python3
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo -e "${GREEN}✓ $package already installed${NC}"
        else
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install "$package"
        fi
    done
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

# Install additional tools (optional)
install_optional_tools() {
    echo ""
    read -p "Do you want to install additional development tools? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing optional tools...${NC}"

        optional_packages=(
            fzf
            lazygit
            bat
            eza
            zoxide
        )

        for package in "${optional_packages[@]}"; do
            if brew list "$package" &>/dev/null; then
                echo -e "${GREEN}✓ $package already installed${NC}"
            else
                echo -e "${YELLOW}Installing $package...${NC}"
                brew install "$package"
            fi
        done
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

    install_homebrew
    install_packages
    backup_configs
    create_symlinks
    install_nvim_plugins
    install_optional_tools

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
    echo "Recommended: Install a Nerd Font for better icons"
    echo "  brew tap homebrew/cask-fonts"
    echo "  brew install --cask font-hack-nerd-font"
    echo ""
}

main
