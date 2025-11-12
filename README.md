# Dotfiles

Personal configuration files for Neovim, Tmux, and Vim.

## Contents

- **nvim/** - Neovim configuration
- **.tmux.conf** - Tmux configuration
- **.vimrc** - Vim configuration
- **install-linux.sh** - Installation script for Linux
- **install-macos.sh** - Installation script for macOS

## Quick Start

### Linux

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install-linux.sh
```

### macOS

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install-macos.sh
```

## What the scripts do

1. **Install required packages**
   - Neovim
   - Tmux
   - Git
   - Ripgrep, fd-find (for telescope.nvim)
   - Node.js and Python (for Neovim plugins)

2. **Backup existing configurations**
   - Creates a backup directory with timestamp
   - Moves existing configs to backup

3. **Create symlinks**
   - Links configuration files from dotfiles to home directory
   - Allows easy updates via git

4. **Install Neovim plugins**
   - Automatically installs plugins using lazy.nvim

## Manual Installation

If you prefer to install manually:

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles

# Create symlinks
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.vimrc ~/.vimrc

# Open Neovim to install plugins
nvim
```

## Requirements

### Linux
- Ubuntu/Debian: `apt` package manager
- Fedora/RHEL/CentOS: `dnf` package manager
- Arch/Manjaro: `pacman` package manager

### macOS
- Homebrew (will be installed automatically if not present)

## Updating

To update your configurations:

```bash
cd ~/dotfiles
git pull
```

Since we use symlinks, changes are automatically reflected.

## Customization

Feel free to modify any configuration files to suit your needs. After making changes, commit and push:

```bash
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push
```

## Neovim Plugins

The Neovim configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. To manage plugins:

- `:Lazy` - Open lazy.nvim UI
- `:Lazy sync` - Update plugins
- `:Lazy clean` - Remove unused plugins

## Troubleshooting

### Neovim plugins not loading

```bash
nvim --headless "+Lazy! sync" +qa
```

### Permission denied

```bash
chmod +x ~/dotfiles/install-*.sh
```

### Tmux not sourcing config

```bash
tmux source ~/.tmux.conf
```

## License

Feel free to use and modify as needed.
