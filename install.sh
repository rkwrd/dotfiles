#!/usr/bin/env bash

# Sane Bash settings: exit on error, exit on unset variables, exit if any pipe fails
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Reset terminal colors
NC='\033[0m'
# Nord Light Colors for standard output
NORD_POLAR_NIGHT='\033[38;2;46;52;64m' # #2e3440 (Dark Slate)
NORD_SNOW_STORM='\033[38;2;229;233;240m' # #e5e9f0 (Light Gray)
NORD_FROST_BLUE='\033[38;2;136;192;208m' # #88c0d0 (Frost Cyan)
NORD_AURORA_GREEN='\033[38;2;163;190;140m' # #a3be8c (Green)
NORD_AURORA_YELLOW='\033[38;2;235;203;139m' # #ebcb8b (Yellow)
NORD_AURORA_RED='\033[38;2;191;97;106m' # #bf616a (Red)

# Helper function to print styled headers
log_info() {
    echo -e "${NORD_FROST_BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${NORD_AURORA_GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${NORD_AURORA_YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${NORD_AURORA_RED}[ERROR]${NC} $1" >&2
}

# 1. Package Manager Detection
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew"
    else
        echo "none"
    fi
}

# 2. Comprehensive System Diagnostics
print_diagnostics() {
    echo -e "${NORD_POLAR_NIGHT}================================================================="
    echo -e "                 COMPREHENSIVE SYSTEM DIAGNOSTICS                "
    echo -e "=================================================================${NC}"

    # Hostname & User
    echo -e "Hostname:        ${NORD_FROST_BLUE}$(hostname)${NC}"
    echo -e "Current User:    ${NORD_FROST_BLUE}$(whoami) (UID: $(id -u))${NC}"
    echo -e "Current Shell:   ${NORD_FROST_BLUE}${SHELL:-$(ps -p $$ -o comm=)}${NC}"

    # Get OS Name and Version
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "OS Distribution: ${NORD_FROST_BLUE}${NAME} ${VERSION:-}${NC}"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo -e "OS Distribution: ${NORD_FROST_BLUE}${DISTRIB_DESCRIPTION:-}${NC}"
    else
        echo -e "OS Distribution: ${NORD_FROST_BLUE}$(uname -s) $(uname -r)${NC}"
    fi

    # Kernel & Virtualization
    echo -e "Kernel Version:  ${NORD_FROST_BLUE}$(uname -r)${NC}"
    local virt="Physical / Bare Metal"
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        virt=$(systemd-detect-virt || echo "Unknown Hypervisor")
    fi
    echo -e "Virtualization:  ${NORD_FROST_BLUE}${virt}${NC}"

    # CPU Information
    local cpu_model="Unknown"
    if command -v lscpu >/dev/null 2>&1; then
        cpu_model=$(lscpu | grep 'Model name:' | cut -d: -f2 | xargs || echo "Unknown")
    elif [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs || echo "Unknown")
    fi
    echo -e "CPU Model:       ${NORD_FROST_BLUE}${cpu_model}${NC}"

    local cores
    if command -v nproc >/dev/null 2>&1; then
        cores=$(nproc)
    else
        cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "Unknown")
    fi
    echo -e "CPU Cores:       ${NORD_FROST_BLUE}${cores}${NC}"

    # Memory Info
    local ram="Unknown"
    if command -v free >/dev/null 2>&1; then
        ram=$(free -h | awk '/^Mem:/ {print $3 " / " $2}')
    elif [ -f /proc/meminfo ]; then
        local total_mem free_mem
        total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        free_mem=$(grep MemFree /proc/meminfo | awk '{print $2}')
        ram="$(((total_mem - free_mem) / 1024 / 1024)) GB / $((total_mem / 1024 / 1024)) GB"
    fi
    echo -e "System Memory:  ${NORD_FROST_BLUE}${ram}${NC}"

    # Disk Space
    local disk_home="Unknown"
    local disk_root="Unknown"
    if command -v df >/dev/null 2>&1; then
        disk_home=$(df -h ~ | tail -n 1 | awk '{print $4 " free of " $2}')
        disk_root=$(df -h / | tail -n 1 | awk '{print $4 " free of " $2}')
    fi
    echo -e "Disk Space (~):  ${NORD_FROST_BLUE}${disk_home}${NC}"
    echo -e "Disk Space (/):  ${NORD_FROST_BLUE}${disk_root}${NC}"

    # System Uptime
    local uptime_str="Unknown"
    if command -v uptime >/dev/null 2>&1; then
        uptime_str=$(uptime -p || uptime)
    fi
    echo -e "System Uptime:   ${NORD_FROST_BLUE}${uptime_str}${NC}"

    # Network Details
    local local_ip="Unknown"
    if command -v hostname >/dev/null 2>&1; then
        local_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || hostname)
    fi
    echo -e "Local IP:       ${NORD_FROST_BLUE}${local_ip}${NC}"

    local ext_ip="Offline/Unknown"
    if command -v curl >/dev/null 2>&1; then
        ext_ip=$(curl -s --max-time 2 https://api.ipify.org || curl -s --max-time 2 https://ifconfig.me || echo "Offline/Timeout")
    fi
    echo -e "External IP:    ${NORD_FROST_BLUE}${ext_ip}${NC}"

    # Detected Package Manager
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    echo -e "Package Manager: ${NORD_FROST_BLUE}${pkg_manager}${NC}"
    echo -e "${NORD_POLAR_NIGHT}=================================================================${NC}\n"
}

# 3. Dependency Installation
install_packages() {
    local pm
    pm=$(detect_package_manager)
    local pkgs=("$@")

    if [ "${#pkgs[@]}" -eq 0 ]; then
        return 0
    fi

    log_info "Running package installation for: ${pkgs[*]}"

    # Run updating and installing
    case "$pm" in
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y "${pkgs[@]}"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "${pkgs[@]}"
            ;;
        dnf)
            sudo dnf install -y "${pkgs[@]}"
            ;;
        yum)
            sudo yum install -y "${pkgs[@]}"
            ;;
        zypper)
            sudo zypper install -y "${pkgs[@]}"
            ;;
        brew)
            brew install "${pkgs[@]}"
            ;;
        *)
            log_error "No package manager available to install packages. Please manually install: ${pkgs[*]}"
            exit 1
            ;;
    esac
}

install_neovim_modern() {
    local arch
    arch=$(uname -m)
    local os
    os=$(uname -s)

    if [ "$os" = "Linux" ] && [ "$arch" = "x86_64" ]; then
        log_info "Installing modern Neovim (stable release) for Linux x86_64..."
        mkdir -p "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/lib"
        local temp_dir
        temp_dir=$(mktemp -d)
        curl -sSL -o "$temp_dir/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        tar -xzf "$temp_dir/nvim.tar.gz" -C "$temp_dir"
        cp -r "$temp_dir"/nvim-linux-x86_64/* "$HOME/.local/"
        rm -rf "$temp_dir"
        log_success "Modern Neovim installed to ~/.local/bin/nvim"
    else
        # Fall back to package manager
        local pm
        pm=$(detect_package_manager)
        if [ "$pm" != "none" ]; then
            log_info "Installing Neovim via package manager..."
            install_packages "neovim"
        else
            log_error "Unsupported platform for auto-installing modern Neovim. Please install manually."
            exit 1
        fi
    fi
}

install_tool_if_missing() {
    local tool=$1
    local cmd=$2

    local need_install=false
    if ! command -v "$cmd" >/dev/null 2>&1; then
        need_install=true
    elif [ "$tool" = "neovim" ]; then
        # Version check for Neovim (requires >= 0.8.0)
        local version_str
        version_str=$(nvim --version | head -n 1 | awk '{print $2}')
        version_str="${version_str#v}"
        local major minor
        major=$(echo "$version_str" | cut -d. -f1)
        minor=$(echo "$version_str" | cut -d. -f2)
        if [ "$major" -eq 0 ] && [ "$minor" -lt 8 ]; then
            log_warn "Detected Neovim version $version_str is too old (requires >= 0.8.0 for lazy.nvim)."
            need_install=true
        fi
    fi

    if [ "$need_install" = true ]; then
        log_info "$tool is not installed (or needs updating)."
        local pkg=$tool
        local pm
        pm=$(detect_package_manager)

        if [ "$tool" = "neovim" ]; then
            install_neovim_modern
            # Add local bin to script's PATH to use the new nvim binary in the rest of this install script execution
            export PATH="$HOME/.local/bin:$PATH"
            return 0
        elif [ "$tool" = "eza" ]; then
            if [ "$pm" = "apt" ]; then
                log_warn "eza might not be in standard apt repos. Attempting install..."
            fi
        elif [ "$tool" = "fd" ]; then
            if [ "$pm" = "apt" ]; then pkg="fd-find"; fi
        elif [ "$tool" = "ripgrep" ]; then
            if [ "$pm" = "apt" ]; then pkg="ripgrep"; fi
        elif [ "$tool" = "gh" ]; then
            install_gh_cli
            return 0
        fi

        install_packages "$pkg"

        # Post-install symlink for fd-find on Debian/Ubuntu
        if [ "$tool" = "fd" ] && [ "$pm" = "apt" ]; then
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
        fi
    else
        log_success "$tool is already installed and matches required specifications."
    fi
}

install_gh_cli() {
    local pm
    pm=$(detect_package_manager)
    log_info "Installing GitHub CLI (gh)..."

    case "$pm" in
        apt)
            # Add official GitHub repository for debian/ubuntu
            sudo mkdir -p -m 755 /etc/apt/keyrings
            # Check if curl is available (install if missing)
            if ! command -v curl >/dev/null 2>&1; then
                sudo apt-get update -qq && sudo apt-get install -y curl
            fi
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq
            sudo apt-get install -y gh
            ;;
        pacman)
            sudo pacman -S --noconfirm github-cli
            ;;
        dnf|yum)
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo || true
            sudo dnf install -y gh || sudo yum install -y gh
            ;;
        zypper)
            sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo || true
            sudo zypper ref
            sudo zypper install -y gh
            ;;
        brew)
            brew install gh
            ;;
        *)
            log_error "Cannot auto-install gh CLI. Please install manually."
            ;;
    esac
}

# 4. Interactive Configuration Selections (Open/Collapse Menu TUI)
# Global component flags (defaults to all enabled)
sel_bash=true
sel_zsh=true
sel_starship=true
sel_tmux_config=true
sel_tpm=true
sel_neovim_config=true
sel_lazy_plugins=true
sel_bat=true
sel_fzf=true
sel_ripgrep=true
sel_eza=true
sel_zoxide=true
sel_fd=true
sel_git=true
sel_gh=true

# Helper to format status text for main menu
get_group_status() {
    local group=$1
    case "$group" in
        shells)
            if [ "$sel_bash" = true ] && [ "$sel_zsh" = true ] && [ "$sel_starship" = true ]; then
                echo "All Enabled"
            elif [ "$sel_bash" = false ] && [ "$sel_zsh" = false ] && [ "$sel_starship" = false ]; then
                echo "All Disabled"
            else
                echo "Partially Enabled"
            fi
            ;;
        tmux)
            if [ "$sel_tmux_config" = true ] && [ "$sel_tpm" = true ]; then
                echo "All Enabled"
            elif [ "$sel_tmux_config" = false ] && [ "$sel_tpm" = false ]; then
                echo "All Disabled"
            else
                echo "Partially Enabled"
            fi
            ;;
        neovim)
            if [ "$sel_neovim_config" = true ] && [ "$sel_lazy_plugins" = true ]; then
                echo "All Enabled"
            elif [ "$sel_neovim_config" = false ] && [ "$sel_lazy_plugins" = false ]; then
                echo "All Disabled"
            else
                echo "Partially Enabled"
            fi
            ;;
        utilities)
            local count=0
            [ "$sel_bat" = true ] && ((count++))
            [ "$sel_fzf" = true ] && ((count++))
            [ "$sel_ripgrep" = true ] && ((count++))
            [ "$sel_eza" = true ] && ((count++))
            [ "$sel_zoxide" = true ] && ((count++))
            [ "$sel_fd" = true ] && ((count++))

            if [ "$count" -eq 6 ]; then
                echo "All Enabled"
            elif [ "$count" -eq 0 ]; then
                echo "All Disabled"
            else
                echo "$count/6 Enabled"
            fi
            ;;
        git)
            if [ "$sel_git" = true ] && [ "$sel_gh" = true ]; then
                echo "All Enabled"
            elif [ "$sel_git" = false ] && [ "$sel_gh" = false ]; then
                echo "All Disabled"
            else
                echo "Partially Enabled"
            fi
            ;;
    esac
}

configure_components_whiptail() {
    while true; do
        local menu_choices
        menu_choices=$(whiptail --title "Dotfiles Configuration Groups" --menu \
            "Choose a group to expand and customize its components, or choose Install:" 18 78 7 \
            "1. Shells & Prompt" "($(get_group_status shells))" \
            "2. Tmux & Sessions" "($(get_group_status tmux))" \
            "3. Neovim IDE" "($(get_group_status neovim))" \
            "4. Modern CLI Tools" "($(get_group_status utilities))" \
            "5. Git & GitHub CLI" "($(get_group_status git))" \
            "6. [ PROCEED WITH INSTALLATION ]" "Apply configs and install" \
            "7. [ EXIT ]" "Exit setup" 3>&1 1>&2 2>&3)

        case "$menu_choices" in
            "1. Shells & Prompt")
                local sub_shells
                sub_shells=$(whiptail --title "Customize Shells & Prompt" --checklist \
                    "Select components to enable:" 15 70 3 \
                    "bash" "Bash configuration (.bashrc, .bash_profile)" "$( [ "$sel_bash" = true ] && echo ON || echo OFF )" \
                    "zsh" "Zsh configuration (.zshrc, .zprofile)" "$( [ "$sel_zsh" = true ] && echo ON || echo OFF )" \
                    "starship" "Starship prompt & configurations" "$( [ "$sel_starship" = true ] && echo ON || echo OFF )" \
                    3>&1 1>&2 2>&3) || continue
                
                sel_bash=false; sel_zsh=false; sel_starship=false
                for item in $sub_shells; do
                    item="${item//\"/}"
                    [ "$item" = "bash" ] && sel_bash=true
                    [ "$item" = "zsh" ] && sel_zsh=true
                    [ "$item" = "starship" ] && sel_starship=true
                done
                ;;
            "2. Tmux & Sessions")
                local sub_tmux
                sub_tmux=$(whiptail --title "Customize Tmux & Sessions" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "tmux_config" "Tmux core config (.tmux.conf)" "$( [ "$sel_tmux_config" = true ] && echo ON || echo OFF )" \
                    "tpm" "Tmux Plugin Manager & session resurrection" "$( [ "$sel_tpm" = true ] && echo ON || echo OFF )" \
                    3>&1 1>&2 2>&3) || continue

                sel_tmux_config=false; sel_tpm=false
                for item in $sub_tmux; do
                    item="${item//\"/}"
                    [ "$item" = "tmux_config" ] && sel_tmux_config=true
                    [ "$item" = "tpm" ] && sel_tpm=true
                done
                ;;
            "3. Neovim IDE")
                local sub_nvim
                sub_nvim=$(whiptail --title "Customize Neovim IDE" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "nvim_config" "Neovim basic config (init.lua, options, maps)" "$( [ "$sel_neovim_config" = true ] && echo ON || echo OFF )" \
                    "lazy_plugins" "lazy.nvim plugins (LSP, cmp, Telescope, Nord Dark)" "$( [ "$sel_lazy_plugins" = true ] && echo ON || echo OFF )" \
                    3>&1 1>&2 2>&3) || continue

                sel_neovim_config=false; sel_lazy_plugins=false
                for item in $sub_nvim; do
                    item="${item//\"/}"
                    [ "$item" = "nvim_config" ] && sel_neovim_config=true
                    [ "$item" = "lazy_plugins" ] && sel_lazy_plugins=true
                done
                ;;
            "4. Modern CLI Tools")
                local sub_utils
                sub_utils=$(whiptail --title "Customize Modern CLI Tools" --checklist \
                    "Select components to enable:" 18 70 6 \
                    "bat" "bat syntax highlighting cat clone" "$( [ "$sel_bat" = true ] && echo ON || echo OFF )" \
                    "fzf" "fzf fuzzy finder + Nord Dark theme" "$( [ "$sel_fzf" = true ] && echo ON || echo OFF )" \
                    "ripgrep" "ripgrep fast grep utility" "$( [ "$sel_ripgrep" = true ] && echo ON || echo OFF )" \
                    "eza" "eza modern ls file lister" "$( [ "$sel_eza" = true ] && echo ON || echo OFF )" \
                    "zoxide" "zoxide quick cd navigation tool" "$( [ "$sel_zoxide" = true ] && echo ON || echo OFF )" \
                    "fd" "fd simple/fast find utility" "$( [ "$sel_fd" = true ] && echo ON || echo OFF )" \
                    3>&1 1>&2 2>&3) || continue

                sel_bat=false; sel_fzf=false; sel_ripgrep=false; sel_eza=false; sel_zoxide=false; sel_fd=false
                for item in $sub_utils; do
                    item="${item//\"/}"
                    [ "$item" = "bat" ] && sel_bat=true
                    [ "$item" = "fzf" ] && sel_fzf=true
                    [ "$item" = "ripgrep" ] && sel_ripgrep=true
                    [ "$item" = "eza" ] && sel_eza=true
                    [ "$item" = "zoxide" ] && sel_zoxide=true
                    [ "$item" = "fd" ] && sel_fd=true
                done
                ;;
            "5. Git & GitHub CLI")
                local sub_git
                sub_git=$(whiptail --title "Customize Git & GitHub CLI" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "git" "git package installation" "$( [ "$sel_git" = true ] && echo ON || echo OFF )" \
                    "gh" "github-cli package installation" "$( [ "$sel_gh" = true ] && echo ON || echo OFF )" \
                    3>&1 1>&2 2>&3) || continue

                sel_git=false; sel_gh=false
                for item in $sub_git; do
                    item="${item//\"/}"
                    [ "$item" = "git" ] && sel_git=true
                    [ "$item" = "gh" ] && sel_gh=true
                done
                ;;
            "6. [ PROCEED WITH INSTALLATION ]")
                break
                ;;
            "7. [ EXIT ]"|*)
                log_warn "Installation cancelled."
                exit 0
                ;;
        esac
    done
}

configure_components_dialog() {
    while true; do
        local temp_file
        temp_file=$(mktemp)
        dialog --title "Dotfiles Configuration Groups" --menu \
            "Choose a group to expand and customize its components, or choose Install:" 18 78 7 \
            "1. Shells & Prompt" "($(get_group_status shells))" \
            "2. Tmux & Sessions" "($(get_group_status tmux))" \
            "3. Neovim IDE" "($(get_group_status neovim))" \
            "4. Modern CLI Tools" "($(get_group_status utilities))" \
            "5. Git & GitHub CLI" "($(get_group_status git))" \
            "6. [ PROCEED WITH INSTALLATION ]" "Apply configs and install" \
            "7. [ EXIT ]" "Exit setup" 2> "$temp_file"
        
        local menu_choices
        menu_choices=$(cat "$temp_file")
        rm -f "$temp_file"

        case "$menu_choices" in
            "1. Shells & Prompt")
                local sub_temp
                sub_temp=$(mktemp)
                dialog --title "Customize Shells & Prompt" --checklist \
                    "Select components to enable:" 15 70 3 \
                    "bash" "Bash configuration (.bashrc, .bash_profile)" "$( [ "$sel_bash" = true ] && echo ON || echo OFF )" \
                    "zsh" "Zsh configuration (.zshrc, .zprofile)" "$( [ "$sel_zsh" = true ] && echo ON || echo OFF )" \
                    "starship" "Starship prompt & configurations" "$( [ "$sel_starship" = true ] && echo ON || echo OFF )" \
                    2> "$sub_temp" || continue
                
                local sub_shells
                sub_shells=$(cat "$sub_temp")
                rm -f "$sub_temp"
                
                sel_bash=false; sel_zsh=false; sel_starship=false
                for item in $sub_shells; do
                    item="${item//\"/}"
                    [ "$item" = "bash" ] && sel_bash=true
                    [ "$item" = "zsh" ] && sel_zsh=true
                    [ "$item" = "starship" ] && sel_starship=true
                done
                ;;
            "2. Tmux & Sessions")
                local sub_temp
                sub_temp=$(mktemp)
                dialog --title "Customize Tmux & Sessions" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "tmux_config" "Tmux core config (.tmux.conf)" "$( [ "$sel_tmux_config" = true ] && echo ON || echo OFF )" \
                    "tpm" "Tmux Plugin Manager & session resurrection" "$( [ "$sel_tpm" = true ] && echo ON || echo OFF )" \
                    2> "$sub_temp" || continue

                local sub_tmux
                sub_tmux=$(cat "$sub_temp")
                rm -f "$sub_temp"

                sel_tmux_config=false; sel_tpm=false
                for item in $sub_tmux; do
                    item="${item//\"/}"
                    [ "$item" = "tmux_config" ] && sel_tmux_config=true
                    [ "$item" = "tpm" ] && sel_tpm=true
                done
                ;;
            "3. Neovim IDE")
                local sub_temp
                sub_temp=$(mktemp)
                dialog --title "Customize Neovim IDE" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "nvim_config" "Neovim basic config (init.lua, options, maps)" "$( [ "$sel_neovim_config" = true ] && echo ON || echo OFF )" \
                    "lazy_plugins" "lazy.nvim plugins (LSP, cmp, Telescope, Nord Dark)" "$( [ "$sel_lazy_plugins" = true ] && echo ON || echo OFF )" \
                    2> "$sub_temp" || continue

                local sub_nvim
                sub_nvim=$(cat "$sub_temp")
                rm -f "$sub_temp"

                sel_neovim_config=false; sel_lazy_plugins=false
                for item in $sub_nvim; do
                    item="${item//\"/}"
                    [ "$item" = "nvim_config" ] && sel_neovim_config=true
                    [ "$item" = "lazy_plugins" ] && sel_lazy_plugins=true
                done
                ;;
            "4. Modern CLI Tools")
                local sub_temp
                sub_temp=$(mktemp)
                dialog --title "Customize Modern CLI Tools" --checklist \
                    "Select components to enable:" 18 70 6 \
                    "bat" "bat syntax highlighting cat clone" "$( [ "$sel_bat" = true ] && echo ON || echo OFF )" \
                    "fzf" "fzf fuzzy finder + Nord Dark theme" "$( [ "$sel_fzf" = true ] && echo ON || echo OFF )" \
                    "ripgrep" "ripgrep fast grep utility" "$( [ "$sel_ripgrep" = true ] && echo ON || echo OFF )" \
                    "eza" "eza modern ls file lister" "$( [ "$sel_eza" = true ] && echo ON || echo OFF )" \
                    "zoxide" "zoxide quick cd navigation tool" "$( [ "$sel_zoxide" = true ] && echo ON || echo OFF )" \
                    "fd" "fd simple/fast find utility" "$( [ "$sel_fd" = true ] && echo ON || echo OFF )" \
                    2> "$sub_temp" || continue

                local sub_utils
                sub_utils=$(cat "$sub_temp")
                rm -f "$sub_temp"

                sel_bat=false; sel_fzf=false; sel_ripgrep=false; sel_eza=false; sel_zoxide=false; sel_fd=false
                for item in $sub_utils; do
                    item="${item//\"/}"
                    [ "$item" = "bat" ] && sel_bat=true
                    [ "$item" = "fzf" ] && sel_fzf=true
                    [ "$item" = "ripgrep" ] && sel_ripgrep=true
                    [ "$item" = "eza" ] && sel_eza=true
                    [ "$item" = "zoxide" ] && sel_zoxide=true
                    [ "$item" = "fd" ] && sel_fd=true
                done
                ;;
            "5. Git & GitHub CLI")
                local sub_temp
                sub_temp=$(mktemp)
                dialog --title "Customize Git & GitHub CLI" --checklist \
                    "Select components to enable:" 15 70 2 \
                    "git" "git package installation" "$( [ "$sel_git" = true ] && echo ON || echo OFF )" \
                    "gh" "github-cli package installation" "$( [ "$sel_gh" = true ] && echo ON || echo OFF )" \
                    2> "$sub_temp" || continue

                local sub_git
                sub_git=$(cat "$sub_temp")
                rm -f "$sub_temp"

                sel_git=false; sel_gh=false
                for item in $sub_git; do
                    item="${item//\"/}"
                    [ "$item" = "git" ] && sel_git=true
                    [ "$item" = "gh" ] && sel_gh=true
                done
                ;;
            "6. [ PROCEED WITH INSTALLATION ]")
                break
                ;;
            "7. [ EXIT ]"|*)
                log_warn "Installation cancelled."
                exit 0
                ;;
        esac
    done
}

configure_components_fallback() {
    while true; do
        clear
        print_diagnostics
        echo -e "Expand and toggle component groups (or confirm to install):"
        echo -e "  1 )  [+] Shells & Prompt       ➔ ($(get_group_status shells))"
        echo -e "  2 )  [+] Tmux & Sessions       ➔ ($(get_group_status tmux))"
        echo -e "  3 )  [+] Neovim IDE            ➔ ($(get_group_status neovim))"
        echo -e "  4 )  [+] Modern CLI Tools      ➔ ($(get_group_status utilities))"
        echo -e "  5 )  [+] Git & GitHub CLI      ➔ ($(get_group_status git))"
        echo -e "  6 )  ${NORD_FROST_BLUE}[ PROCEED WITH INSTALLATION ]${NC}"
        echo -e "  7 )  ${NORD_AURORA_RED}[ EXIT ]${NC}"
        echo ""

        read -r -p "Enter selection [1-7]: " menu_choice
        case "$menu_choice" in
            1)
                while true; do
                    clear
                    echo "Shells Settings:"
                    echo "  1) [$( [ "$sel_bash" = true ] && echo "X" || echo " " )] Bash Config"
                    echo "  2) [$( [ "$sel_zsh" = true ] && echo "X" || echo " " )] Zsh Config"
                    echo "  3) [$( [ "$sel_starship" = true ] && echo "X" || echo " " )] Starship Prompt"
                    echo "  4) Return to Main Menu"
                    read -r -p "Toggle selection [1-4]: " sub_ch
                    [ "$sub_ch" = "1" ] && { [ "$sel_bash" = true ] && sel_bash=false || sel_bash=true; }
                    [ "$sub_ch" = "2" ] && { [ "$sel_zsh" = true ] && sel_zsh=false || sel_zsh=true; }
                    [ "$sub_ch" = "3" ] && { [ "$sel_starship" = true ] && sel_starship=false || sel_starship=true; }
                    [ "$sub_ch" = "4" ] && break
                done
                ;;
            2)
                while true; do
                    clear
                    echo "Tmux Settings:"
                    echo "  1) [$( [ "$sel_tmux_config" = true ] && echo "X" || echo " " )] Tmux Config (.tmux.conf)"
                    echo "  2) [$( [ "$sel_tpm" = true ] && echo "X" || echo " " )] Tmux Plugin Manager (TPM)"
                    echo "  3) Return to Main Menu"
                    read -r -p "Toggle selection [1-3]: " sub_ch
                    [ "$sub_ch" = "1" ] && { [ "$sel_tmux_config" = true ] && sel_tmux_config=false || sel_tmux_config=true; }
                    [ "$sub_ch" = "2" ] && { [ "$sel_tpm" = true ] && sel_tpm=false || sel_tpm=true; }
                    [ "$sub_ch" = "3" ] && break
                done
                ;;
            3)
                while true; do
                    clear
                    echo "Neovim Settings:"
                    echo "  1) [$( [ "$sel_neovim_config" = true ] && echo "X" || echo " " )] Neovim config files"
                    echo "  2) [$( [ "$sel_lazy_plugins" = true ] && echo "X" || echo " " )] lazy.nvim IDE plugins"
                    echo "  3) Return to Main Menu"
                    read -r -p "Toggle selection [1-3]: " sub_ch
                    [ "$sub_ch" = "1" ] && { [ "$sel_neovim_config" = true ] && sel_neovim_config=false || sel_neovim_config=true; }
                    [ "$sub_ch" = "2" ] && { [ "$sel_lazy_plugins" = true ] && sel_lazy_plugins=false || sel_lazy_plugins=true; }
                    [ "$sub_ch" = "3" ] && break
                done
                ;;
            4)
                while true; do
                    clear
                    echo "Modern CLI Utilities:"
                    echo "  1) [$( [ "$sel_bat" = true ] && echo "X" || echo " " )] bat"
                    echo "  2) [$( [ "$sel_fzf" = true ] && echo "X" || echo " " )] fzf"
                    echo "  3) [$( [ "$sel_ripgrep" = true ] && echo "X" || echo " " )] ripgrep"
                    echo "  4) [$( [ "$sel_eza" = true ] && echo "X" || echo " " )] eza"
                    echo "  5) [$( [ "$sel_zoxide" = true ] && echo "X" || echo " " )] zoxide"
                    echo "  6) [$( [ "$sel_fd" = true ] && echo "X" || echo " " )] fd"
                    echo "  7) Return to Main Menu"
                    read -r -p "Toggle selection [1-7]: " sub_ch
                    [ "$sub_ch" = "1" ] && { [ "$sel_bat" = true ] && sel_bat=false || sel_bat=true; }
                    [ "$sub_ch" = "2" ] && { [ "$sel_fzf" = true ] && sel_fzf=false || sel_fzf=true; }
                    [ "$sub_ch" = "3" ] && { [ "$sel_ripgrep" = true ] && sel_ripgrep=false || sel_ripgrep=true; }
                    [ "$sub_ch" = "4" ] && { [ "$sel_eza" = true ] && sel_eza=false || sel_eza=true; }
                    [ "$sub_ch" = "5" ] && { [ "$sel_zoxide" = true ] && sel_zoxide=false || sel_zoxide=true; }
                    [ "$sub_ch" = "6" ] && { [ "$sel_fd" = true ] && sel_fd=false || sel_fd=true; }
                    [ "$sub_ch" = "7" ] && break
                done
                ;;
            5)
                while true; do
                    clear
                    echo "Git & GitHub CLI:"
                    echo "  1) [$( [ "$sel_git" = true ] && echo "X" || echo " " )] Git package"
                    echo "  2) [$( [ "$sel_gh" = true ] && echo "X" || echo " " )] GitHub CLI (gh)"
                    echo "  3) Return to Main Menu"
                    read -r -p "Toggle selection [1-3]: " sub_ch
                    [ "$sub_ch" = "1" ] && { [ "$sel_git" = true ] && sel_git=false || sel_git=true; }
                    [ "$sub_ch" = "2" ] && { [ "$sel_gh" = true ] && sel_gh=false || sel_gh=true; }
                    [ "$sub_ch" = "3" ] && break
                done
                ;;
            6)
                break
                ;;
            7)
                log_warn "Installation cancelled."
                exit 0
                ;;
            *)
                log_error "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

select_components() {
    if command -v whiptail >/dev/null 2>&1; then
        configure_components_whiptail
    elif command -v dialog >/dev/null 2>&1; then
        configure_components_dialog
    else
        configure_components_fallback
    fi
}

# 5. Safe Backup & stow execution
safe_stow() {
    local folder=$1
    log_info "Preparing to symlink configuration group: '$folder'..."

    # Ensure stow is installed
    install_tool_if_missing "stow" "stow"

    # Identify targets to backup before running stow
    find "$folder" -mindepth 1 -maxdepth 1 | while read -r item; do
        local rel_path
        rel_path=$(basename "$item")
        local target="$HOME/$rel_path"

        # Special logic for config directory
        if [ "$folder" = "config" ]; then
             find "config/.config" -mindepth 1 -maxdepth 1 | while read -r subitem; do
                 local sub_rel
                 sub_rel=$(basename "$subitem")
                 local sub_target="$HOME/.config/$sub_rel"
                 if [ -e "$sub_target" ] || [ -L "$sub_target" ]; then
                     local target_link
                     target_link=$(readlink -f "$sub_target" || echo "")
                     if [ "$target_link" != "$(realpath "$subitem")" ]; then
                         log_warn "Existing configuration found at '$sub_target'. Backing up to '$BACKUP_DIR'..."
                         mkdir -p "$BACKUP_DIR/.config"
                         mv "$sub_target" "$BACKUP_DIR/.config/"
                     fi
                 fi
             done
             stow -R -d "$DOTFILES_DIR" -t "$HOME" "config"
             return 0
        fi

        # Standard file stow backups
        if [ -e "$target" ] || [ -L "$target" ]; then
            local target_link
            target_link=$(readlink -f "$target" || echo "")
            if [ "$target_link" != "$item" ]; then
                log_warn "Existing configuration found at '$target'. Backing up to '$BACKUP_DIR'..."
                mkdir -p "$BACKUP_DIR"
                mv "$target" "$BACKUP_DIR/"
            fi
        fi
    done

    # Run Stow
    stow -R -d "$DOTFILES_DIR" -t "$HOME" "$folder"
    log_success "Symlinked folder '$folder' to home directory."
}

# Main Execution Flow
main() {
    clear
    print_diagnostics

    # 1. First-class check: Ensure Git is installed immediately so git clone commands do not fail
    log_info "Checking core environment tools..."
    install_tool_if_missing "git" "git"
    install_tool_if_missing "curl" "curl"

    # 2. Get user selections using our open/collapse menu
    select_components

    # 3. Apply Git & GitHub CLI selections first
    if [ "$sel_git" = true ]; then
        install_tool_if_missing "git" "git"
    fi
    if [ "$sel_gh" = true ]; then
        install_tool_if_missing "gh" "gh"
    fi

    # 4. Apply Shell Configs
    if [ "$sel_bash" = true ] || [ "$sel_zsh" = true ] || [ "$sel_starship" = true ]; then
        # Install Zsh if selected
        if [ "$sel_zsh" = true ]; then
            install_tool_if_missing "zsh" "zsh"
        fi

        # Install Starship if selected
        if [ "$sel_starship" = true ]; then
            if ! command -v starship >/dev/null 2>&1; then
                log_info "Installing Starship Prompt..."
                # Suppress starship script stdout/manual action outputs to prevent confusing the user
                curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null
                log_success "Starship installed."
            fi
        fi

        # Stow directories
        [ "$sel_bash" = true ] && safe_stow "bash"
        [ "$sel_zsh" = true ] && safe_stow "zsh"
        
        # Always stow shared files and config directory if shells are activated
        safe_stow "shared"
        safe_stow "config"
    fi

    # 5. Apply Tmux Configs
    if [ "$sel_tmux_config" = true ] || [ "$sel_tpm" = true ]; then
        if [ "$sel_tmux_config" = true ]; then
            install_tool_if_missing "tmux" "tmux"
            safe_stow "tmux"
        fi

        if [ "$sel_tpm" = true ]; then
            # Core git check is completed at main start, so this clone is safe
            if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
                log_info "Installing Tmux Plugin Manager (TPM)..."
                git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1
                log_success "TPM installed."
            fi

            # Headless installation of Tmux plugins
            log_info "Downloading and installing Tmux plugins via TPM..."
            tmux start-server \; new-session -d \; run-shell "$HOME/.tmux/plugins/tpm/bin/install_plugins" \; kill-server >/dev/null 2>&1 || true
            log_success "Tmux plugins installed."
        fi

        # Reload configuration on active tmux server if running
        if [ "$sel_tmux_config" = true ] && pgrep tmux >/dev/null 2>&1; then
            log_info "Reloading active Tmux server configuration..."
            tmux source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true
        fi
    fi

    # 6. Apply Neovim Configs
    if [ "$sel_neovim_config" = true ] || [ "$sel_lazy_plugins" = true ]; then
        install_tool_if_missing "neovim" "nvim"
        # Always stow config since nvim configurations are inside config/.config/nvim
        safe_stow "config"

        if [ "$sel_lazy_plugins" = true ]; then
            log_info "Bootstrapping Neovim plugins via lazy.nvim (this may take a few moments)..."
            # Headless Neovim plugin download/sync
            nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || true
            log_success "Neovim plugins bootstrapped successfully."
        fi
    fi

    # 7. Apply Modern CLI utilities
    if [ "$sel_bat" = true ] || [ "$sel_fzf" = true ] || [ "$sel_ripgrep" = true ] || [ "$sel_eza" = true ] || [ "$sel_zoxide" = true ] || [ "$sel_fd" = true ]; then
        [ "$sel_bat" = true ] && install_tool_if_missing "bat" "bat"
        [ "$sel_fzf" = true ] && install_tool_if_missing "fzf" "fzf"
        [ "$sel_ripgrep" = true ] && install_tool_if_missing "ripgrep" "rg"
        [ "$sel_eza" = true ] && install_tool_if_missing "eza" "eza"
        [ "$sel_zoxide" = true ] && install_tool_if_missing "zoxide" "zoxide"
        [ "$sel_fd" = true ] && install_tool_if_missing "fd" "fd"

        safe_stow "shared" # Includes fzf Nord Dark setups and ripgreprc
        safe_stow "config" # Includes bat config
    fi

    # 8. Set Zsh as default shell if Zsh config is selected and shell is not Zsh
    if [ "$sel_zsh" = true ] && [ "${SHELL##*/}" != "zsh" ]; then
        local zsh_path
        zsh_path=$(command -v zsh || echo "")
        if [ -n "$zsh_path" ]; then
            log_info "Setting default shell to Zsh..."
            # Automated default shell switch
            if sudo -n true 2>/dev/null; then
                sudo chsh -s "$zsh_path" "$USER"
                log_success "Default shell set to Zsh."
            else
                log_warn "Sudo rights are required to set Zsh as default shell automatically. Please run: chsh -s $zsh_path"
            fi
        fi
    fi

    echo ""
    log_success "Dotfiles configuration completed successfully! No manual steps are required."
    if [ -d "$BACKUP_DIR" ]; then
        log_info "Your original system configurations were backed up to: $BACKUP_DIR"
    fi

    # 9. Auto-reload current terminal shell with the fresh configuration
    if [ -t 0 ]; then
        log_info "Activating your new shell session now..."
        if [ "$sel_zsh" = true ] && command -v zsh >/dev/null 2>&1; then
            exec zsh -l
        elif [ "$sel_bash" = true ] && command -v bash >/dev/null 2>&1; then
            exec bash -l
        fi
    fi
}

main "$@"
