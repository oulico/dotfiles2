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

### Neovim plugins not loading or errors on first run

If you see errors like `module 'harpoon.mark' not found` or `attempt to index field 'keymap' (a nil value)`, the plugins haven't been installed yet.

**Solution:**
1. Open Neovim: `nvim`
2. Wait for lazy.nvim to automatically install plugins (you'll see a progress window)
3. After installation completes, quit nvim (`:q`)
4. Open nvim again - everything should work now

**Alternative manual method:**
```bash
nvim +'Lazy sync' +qa
# Then open nvim normally
nvim
```

### Permission denied when running install scripts

```bash
chmod +x ~/dotfiles/install-*.sh
```

### Tmux not sourcing config

```bash
tmux source ~/.tmux.conf
# Or restart tmux
tmux kill-server && tmux
```

### Neovim version too old

Some features require Neovim 0.8+. Check your version:
```bash
nvim --version
```

If it's too old, install the latest version from the official repository.

## License

Feel free to use and modify as needed.
