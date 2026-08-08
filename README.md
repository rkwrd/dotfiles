# dotfiles

A modular, clean, and elegant personal dotfiles configuration tailored specifically for the **Nord Light** color palette (light gray/snowstorm background with polar night slate text, accented by frost blues and pastel auroras).

Designed for minimal setup time, high performance, and fault tolerance across various personal and professional Linux and macOS environments.

---

## 🎨 Aesthetic & Themes
This configuration is optimized for a terminal emulator using a **Light Theme** (specifically targeting the Nord Light background color `#eceff4` or `#e5e9f0`). 

*   **Shell Prompt (Starship):** Customized with high-contrast slate colors (`#2e3440`) and soft Frost backgrounds.
*   **Tmux Status Line:** Styled natively with light gray borders, a clean blue active tab indicator (`#81a1c1`), and status widgets showing system time and host.
*   **Neovim:** Explicitly configured with `background = "light"` and the `nord.nvim` colorscheme, yielding a beautiful, low-strain light interface.
*   **fzf / bat:** Styled using the Nord palette exports for interactive searches.

---

## 🚀 Installation & Bootstrapping

The repository comes with a robust, interactive installation script (`install.sh`) powered by **GNU Stow**. 

### Quick Start
To clone the repository and run the setup:
```bash
git clone git@github.com:rkwrd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
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
│   ├── .fzf_nord_light    # Nord Light styling palette for fzf
│   └── .ripgreprc         # Sane defaults for ripgrep (ignore git, smart-case)
├── tmux/
│   └── .tmux.conf         # Tmux configs, navigator splits, and Nord status line
└── config/
    └── .config/
        ├── starship.toml  # Starship prompt configuration (Nord Light)
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

### 1. Shells (Bash & Zsh)
*   **Shared Aliases:** Maps standard utilities to modern Rust/Go-based alternatives (`ls` ➔ `eza`, `cat` ➔ `bat`, `find` ➔ `fd`, `grep` ➔ `rg`).
*   **Zsh Performance:** Stripped of heavy frameworks (like Oh My Zsh) to keep shell load times near-instant, sourcing plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) directly from system folders.
*   **Starship Prompt:** Shows current directory, Git status, runtime durations, and runtime versions with clean, high-contrast indicators.

### 2. Tmux Configuration
*   **Key Rebindings:** Rebinds the prefix key to `Ctrl-a` and splits windows horizontally with `|` and vertically with `-` (preserving the current directory).
*   **Navigation:** Uses `christoomey/vim-tmux-navigator` to enable seamless pane switching between tmux splits and Neovim windows using standard `Ctrl+h/j/k/l` bindings.
*   **Session Management:** Auto-saves and restores active tmux sessions using `tmux-resurrect` and `tmux-continuum`.

### 3. Neovim Configuration
A lightweight, modern Lua configuration that rivals pre-packaged distributions while remaining easy to inspect and customize.
*   **Plugin Manager:** `lazy.nvim` handles asynchronous lazy-loading.
*   **LSP Config:** Leverages `mason.nvim` and `nvim-lspconfig` for self-updating language servers and direct keymaps.
*   **Completion:** `nvim-cmp` and `LuaSnip` provide quick dropdown popups.
*   **Navigation & Searches:** `telescope.nvim` acts as the fuzzy finder for files, text grep, and buffers.
*   **Filesystem Management:** `oil.nvim` enables editing files and folders as text lines directly inside a Vim buffer (rename/delete by modifying text).

### 4. Command Line Utilities
*   **`bat`:** Custom syntax-highlighting for code viewing.
*   **`fzf`:** Styled to match the light theme background, with full file preview support powered by `bat`.
*   **`ripgrep`:** Configured to search hidden files by default but ignore version control directories and respect your local `.gitignore`.
