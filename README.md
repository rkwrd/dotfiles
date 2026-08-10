# dotfiles

A modular, clean, and elegant personal dotfiles configuration tailored specifically for the **Nord Dark** color palette (dark polar night background, accented by frost blues and pastel auroras).

Designed for minimal setup time, high performance, and fault tolerance across various personal and professional Linux and macOS environments.

---

## 🎨 Aesthetic & Themes
This configuration is optimized for a terminal emulator using a **Dark Theme** (specifically targeting the Nord Dark background color `#2e3440` or standard dark terminal backgrounds). 

*   **Shell Prompt (Starship):** Customized with Snow Storm colors (`#d8dee9`) and Frost/Aurora accents.
*   **Tmux Status Line:** Styled natively with dark gray borders, a clean blue active tab indicator (`#88c0d0`), and status widgets.
*   **Neovim:** Explicitly configured with `background = "dark"` and the `nord.nvim` colorscheme, yielding a beautiful, low-strain dark interface.
*   **fzf / bat:** Styled using the Nord palette exports for interactive searches.

---

## 🔤 Nerd Fonts Prerequisite

To render glyphs and icons correctly (such as the branch icon in Starship, status bar symbols in Tmux, and file tree icons in Neovim), you need to have a **Nerd Font** installed on your **local machine** (the client running your terminal emulator/SSH client), **not** on the remote server.

### Recommended Fonts
*   **JetBrainsMono Nerd Font** (Clean, highly legible monospace)
*   **FiraCode Nerd Font** (Popular coding ligatures)

### How to Install Locally

#### On macOS (using Homebrew)
```bash
brew install --cask font-jetbrains-mono-nerd-font
# OR
brew install --cask font-fira-code-nerd-font
```

#### On Linux Client
Download and unpack into your local fonts directory:
```bash
mkdir -p ~/.local/share/fonts
curl -fLo "JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv
rm JetBrainsMono.zip
```

> [!IMPORTANT]
> After installation, open your local terminal settings (e.g. iTerm2, Terminal.app, Alacritty) and set the Font to **JetBrainsMono Nerd Font** or **FiraCode Nerd Font**.

---

## 🚀 Installation & Bootstrapping

The repository comes with a robust, interactive installation script (`install.sh`) powered by **GNU Stow**. 

### Quick Start & One-Liner Options

Select the installation method that fits your environment's constraints:

#### Option 1: Git Clone (Standard Setup)
For standard environments with public internet access:
```bash
git clone https://github.com/rkwrd/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

#### Option 2: Curl Tarball (Zero-Git Bootstrap)
For minimal environments where `git` is missing:
```bash
curl -sSL https://github.com/rkwrd/dotfiles/archive/refs/heads/main.tar.gz | tar -xz && mv dotfiles-main ~/dotfiles && cd ~/dotfiles && ./install.sh
```

#### Option 3: Local to Remote VM Transfer (SCP / Cloud VM)
For environments where the remote machine has restricted access or you want to deploy local changes instantly:

*   **For GCP Compute Engine VM:**
    ```bash
    gcloud compute scp --recurse ~/dotfiles dotfiles-test:~/dotfiles --zone=us-central1-a && gcloud compute ssh dotfiles-test --zone=us-central1-a --command="cd ~/dotfiles && ./install.sh"
    ```
*   **For Generic SSH Servers:**
    ```bash
    scp -r ~/dotfiles user@remote-host:~/dotfiles && ssh user@remote-host "cd ~/dotfiles && ./install.sh"
    ```

### Features of the Installer (`install.sh`)
*   **System Diagnostics:** On launch, the script analyzes and prints your distribution details, CPU cores, system RAM, network IP, and local package manager.
*   **Whiptail TUI & Fallback:** Launches a graphical checklist menu if `whiptail` or `dialog` is available. If running in a minimal environment, it falls back to a clean, pure-Bash console selection menu.
*   **Dependency Resolution:** Automatically detects the package manager (`apt`, `pacman`, `dnf`, `yum`, `zypper`, or `brew`) and installs missing core dependencies (`stow`, `git`, `curl`, `tmux`, etc.).
*   **Safe Backup:** Before generating symlinks, it checks your home directory for conflicting configuration files and backs them up into `~/dotfiles_backup_<timestamp>` to prevent data loss.

---

## 📂 Repository Layout

```text
~/dotfiles/
├── install.sh             # Interactive TUI bootstrap script
├── bash/
│   ├── .bashrc            # Bash settings & prompt fallbacks
│   └── .bash_profile      # Sources .bashrc for login shells
├── zsh/
│   ├── .zshrc             # Highly optimized Zsh config with completions
│   └── .zprofile          # Zsh login shell configuration
├── shared/
│   ├── .shell_aliases     # Common CLI aliases & overrides
│   ├── .fzf_nord          # Nord Dark styling palette for fzf
│   └── .ripgreprc         # Sane defaults for ripgrep (ignore git, smart-case)
├── tmux/
│   └── .tmux.conf         # Tmux configs, navigator splits, and Nord status line
└── config/
    └── .config/
        ├── starship.toml  # Starship prompt configuration (Nord Dark)
        ├── alacritty/
        │   └── alacritty.toml # Fast GPU terminal with Nord Dark theme
        ├── i3/
        │   └── config         # i3 window manager (clean pixel borders, gold active border)
        ├── polybar/
        │   └── ...            # Polybar status bars with custom launcher & terminal shortcuts
        ├── rofi/
        │   └── ...            # Rofi application launcher and window switchers
        ├── eza/
        │   └── theme.yml      # Custom icon mappings for universal Nerd Font compatibility
        ├── bat/
        │   └── config     # bat syntax highlighter defaults (Nord theme)
        └── nvim/
            ├── init.lua   # Neovim main entry & lazy.nvim setup
            └── lua/
                └── user/
                    ├── options.lua   # Background light & true-color options
                    ├── keymaps.lua   # Sane mappings & pane switches
                    └── plugins.lua   # lazy.nvim specifications (LSP, cmp, etc.)
```

---

## 🛠️ Tool Customizations

### 1. Window Manager & Desktop (i3, Polybar, Rofi)
*   **i3 Window Manager:** Configured with clean 2px pixel borders (titlebars removed), active window highlighted with a gold/amber border (`#ebcb8b`), and shortcuts for Alacritty, Vicinae, and Rofi.
*   **Polybar:** Configured with modular blocks theme, application launcher as leftmost module, followed by terminal shortcut to Alacritty.
*   **Rofi:** Clean application launcher, window switcher (`Alt+Tab`), and power menu integrations.

### 2. Terminal & Shells
*   **Alacritty:** Configured with GPU-accelerated rendering, 10,000 lines of scrollback history, JetBrainsMono Nerd Font, and the Nord Dark palette.
*   **Shared Aliases:** Maps standard utilities to modern Rust/Go-based alternatives (`ls` ➔ `eza`, `cat` ➔ `bat`, `find` ➔ `fd`, `grep` ➔ `rg`).
*   **Zsh Performance:** Stripped of heavy frameworks (like Oh My Zsh) to keep shell load times near-instant, sourcing plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) directly from system folders.
*   **Starship Prompt:** Shows current directory, Git status, runtime durations, and runtime versions with clean, high-contrast indicators.

### 3. Tmux Configuration
*   **Key Rebindings:** Rebinds the prefix key to `Ctrl-a` and splits windows horizontally with `|` and vertically with `-` (preserving the current directory).
*   **Navigation:** Uses `christoomey/vim-tmux-navigator` to enable seamless pane switching between tmux splits and Neovim windows using standard `Ctrl+h/j/k/l` bindings.
*   **Session Management:** Auto-saves and restores active tmux sessions using `tmux-resurrect` and `tmux-continuum`.

### 4. Neovim Configuration
A lightweight, modern Lua configuration that rivals pre-packaged distributions while remaining easy to inspect and customize.
*   **Plugin Manager:** `lazy.nvim` handles asynchronous lazy-loading.
*   **LSP Config:** Leverages `mason.nvim` and `nvim-lspconfig` for self-updating language servers and direct keymaps.
*   **Completion:** `nvim-cmp` and `LuaSnip` provide quick dropdown popups.
*   **Navigation & Searches:** `telescope.nvim` acts as the fuzzy finder for files, text grep, and buffers.
*   **Filesystem Management:** `oil.nvim` enables editing files and folders as text lines directly inside a Vim buffer (rename/delete by modifying text).

### 5. Command Line Utilities
*   **`bat`:** Custom syntax-highlighting for code viewing.
*   **`fzf`:** Styled to match the dark theme background, with full file preview support powered by `bat`.
*   **`ripgrep`:** Configured to search hidden files by default but ignore version control directories and respect your local `.gitignore`.

