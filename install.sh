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

# 1. System Diagnostics
print_diagnostics() {
    echo -e "${NORD_POLAR_NIGHT}========================================="
    echo -e "       SYSTEM DIAGNOSTICS & DETAILS      "
    echo -e "=========================================${NC}"

    # Get OS Name and Version
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "OS Distro:      ${NORD_FROST_BLUE}${NAME} ${VERSION:-}${NC}"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo -e "OS Distro:      ${NORD_FROST_BLUE}${DISTRIB_DESCRIPTION:-}${NC}"
    else
        echo -e "OS Distro:      ${NORD_FROST_BLUE}$(uname -s) $(uname -r)${NC}"
    fi

    # Kernel Info
    echo -e "Kernel Version: ${NORD_FROST_BLUE}$(uname -r)${NC}"

    # CPU Cores
    local cores
    if command -v nproc >/dev/null 2>&1; then
        cores=$(nproc)
    elif command -v getconf >/dev/null 2>&1; then
        cores=$(getconf _NPROCESSORS_ONLN)
    else
        cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "Unknown")
    fi
    echo -e "CPU Cores:      ${NORD_FROST_BLUE}${cores}${NC}"

    # RAM Info
    local ram="Unknown"
    if [ -f /proc/meminfo ]; then
        local mem_kb
        mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        ram="$((mem_kb / 1024 / 1024)) GB"
    elif command -v free >/dev/null 2>&1; then
        ram=$(free -h | awk '/^Mem:/ {print $2}')
    elif command -v sysctl >/dev/null 2>&1; then
        local mem_bytes
        mem_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
        if [ "$mem_bytes" -gt 0 ]; then
            ram="$((mem_bytes / 1024 / 1024 / 1024)) GB"
        fi
    fi
    echo -e "System Memory:  ${NORD_FROST_BLUE}${ram}${NC}"

    # Local IP Address
    local local_ip="Unknown"
    if command -v hostname >/dev/null 2>&1; then
        local_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || hostname)
    elif command -v ip >/dev/null 2>&1; then
        local_ip=$(ip route get 1 2>/dev/null | awk '{print $7;exit}' || echo "Unknown")
    elif command -v ifconfig >/dev/null 2>&1; then
        local_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
    echo -e "Local IP:       ${NORD_FROST_BLUE}${local_ip}${NC}"

    # External IP (with 2s timeout to avoid hanging)
    local ext_ip="Offline/Unknown"
    if command -v curl >/dev/null 2>&1; then
        ext_ip=$(curl -s --max-time 2 https://api.ipify.org || curl -s --max-time 2 https://ifconfig.me || echo "Offline/Timeout")
    elif command -v wget >/dev/null 2>&1; then
        ext_ip=$(wget -T 2 -O - https://api.ipify.org 2>/dev/null || echo "Offline/Timeout")
    fi
    echo -e "External IP:    ${NORD_FROST_BLUE}${ext_ip}${NC}"

    # Detected Package Manager
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    echo -e "Package Mgr:    ${NORD_FROST_BLUE}${pkg_manager}${NC}"
    echo -e "${NORD_POLAR_NIGHT}=========================================${NC}\n"
}

# 2. Package Manager Detection
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

# 3. Automatic Dependency Installation
install_packages() {
    local pm
    pm=$(detect_package_manager)
    local pkgs=("$@")

    if [ "${#pkgs[@]}" -eq 0 ]; then
        return 0
    fi

    log_info "Automatically installing missing packages: ${pkgs[*]}"

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
            log_error "No supported package manager found. Please install manually: ${pkgs[*]}"
            exit 1
            ;;
    esac
}

# Map generic tool names to system-specific package names if necessary
install_tool_if_missing() {
    local tool=$1
    local cmd=$2

    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_info "$tool is not installed."
        # Package naming overrides
        local pkg=$tool
        local pm
        pm=$(detect_package_manager)

        if [ "$tool" = "neovim" ]; then
            if [ "$pm" = "apt" ]; then pkg="neovim"; fi
        elif [ "$tool" = "eza" ]; then
            # Eza is sometimes not in older apt repositories
            if [ "$pm" = "apt" ]; then
                log_warn "eza might need custom PPA on debian/ubuntu. Attempting standard install..."
            fi
        elif [ "$tool" = "fd" ]; then
            if [ "$pm" = "apt" ]; then pkg="fd-find"; fi
        fi

        install_packages "$pkg"

        # Post-install symlink for fd-find on Debian/Ubuntu
        if [ "$tool" = "fd" ] && [ "$pm" = "apt" ]; then
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
        fi
    else
        log_success "$tool is already installed."
    fi
}

# 4. TUI Checklist with Whiptail/Dialog and pure Bash Fallback
select_components() {
    local choices=()
    
    # Check if whiptail is available
    if command -v whiptail >/dev/null 2>&1; then
        local selected
        selected=$(whiptail --title "Nord Light Dotfiles Installer" \
            --checklist "Use Spacebar to select/deselect components, then press Enter:" 16 70 5 \
            "shells" "Zsh, Bash configurations & Starship Prompt" ON \
            "tmux" "Tmux config, TPM & pane navigator" ON \
            "neovim" "Modern Neovim (lazy.nvim, LSP, Treesitter, Nord theme)" ON \
            "utilities" "Modern CLI tools (bat, fzf, ripgrep, eza, zoxide, fd)" ON \
            3>&1 1>&2 2>&3)
        
        # Parse space-separated string into array
        for choice in $selected; do
            # Remove quotes
            choice="${choice//\"/}"
            choices+=("$choice")
        done

    # Fallback to dialog
    elif command -v dialog >/dev/null 2>&1; then
        local temp_file
        temp_file=$(mktemp)
        dialog --title "Nord Light Dotfiles Installer" \
            --checklist "Use Spacebar to select/deselect components:" 16 70 5 \
            "shells" "Zsh, Bash configurations & Starship Prompt" ON \
            "tmux" "Tmux config, TPM & pane navigator" ON \
            "neovim" "Modern Neovim (lazy.nvim, LSP, Treesitter, Nord theme)" ON \
            "utilities" "Modern CLI tools (bat, fzf, ripgrep, eza, zoxide, fd)" ON \
            2> "$temp_file"
        
        local selected
        selected=$(cat "$temp_file")
        rm -f "$temp_file"
        for choice in $selected; do
            choice="${choice//\"/}"
            choices+=("$choice")
        done

    # Fallback to pure Bash interactive menu
    else
        log_warn "Neither 'whiptail' nor 'dialog' found. Falling back to CLI interactive menu."
        local options=("Bash + Zsh + Starship Prompt" "Tmux + TPM + Navigators" "Neovim (LSP/Treesitter/Nord Light)" "CLI Utilities (bat/fzf/rg/eza/zoxide)" "CONFIRM AND INSTALL")
        local selections=(true true true true) # default to all ON

        while true; do
            clear
            print_diagnostics
            echo "Select components to toggle (press number, then Enter. Enter 5 to confirm):"
            for i in "${!options[@]}"; do
                if [ "$i" -eq 4 ]; then
                    echo -e "  $((i+1)) )  ${NORD_FROST_BLUE}${options[$i]}${NC}"
                else
                    local status="[ ]"
                    if [ "${selections[$i]}" = true ]; then
                        status="[X]"
                    fi
                    echo "  $((i+1)) )  $status ${options[$i]}"
                fi
            done

            read -r -p "Toggle choice [1-5]: " choice
            if [[ "$choice" =~ ^[1-4]$ ]]; then
                local idx=$((choice-1))
                if [ "${selections[$idx]}" = true ]; then
                    selections[$idx]=false
                else
                    selections[$idx]=true
                fi
            elif [ "$choice" -eq 5 ]; then
                break
            else
                log_error "Invalid selection."
                sleep 1
            fi
        done

        # Map selections back to component names
        if [ "${selections[0]}" = true ]; then choices+=("shells"); fi
        if [ "${selections[1]}" = true ]; then choices+=("tmux"); fi
        if [ "${selections[2]}" = true ]; then choices+=("neovim"); fi
        if [ "${selections[3]}" = true ]; then choices+=("utilities"); fi
    fi

    echo "${choices[@]}"
}

# 5. Safe Backup & stow execution
safe_stow() {
    local folder=$1
    log_info "Preparing to symlink configuration group: '$folder'..."

    # Ensure stow is installed
    install_tool_if_missing "stow" "stow"

    # Identify targets to backup before running stow
    # Stow will symlink everything inside the folder to the target parent (usually $HOME)
    # We inspect the target path of each element inside the dotfiles folder.
    find "$folder" -mindepth 1 -maxdepth 1 | while read -r item; do
        local rel_path
        rel_path=$(basename "$item")
        local target="$HOME/$rel_path"

        # Special logic for config directory (we want to stow individual config dirs, not the whole config folder)
        if [ "$folder" = "config" ]; then
             # inside config is .config/
             # let's find things inside config/.config/
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
             # Stow config
             stow -R -d "$DOTFILES_DIR" -t "$HOME" "config"
             return 0
        fi

        # If target exists and is NOT a symlink pointing to our dotfiles directory, back it up
        if [ -e "$target" ] || [ -L "$target" ]; then
            # Verify if it already points to the correct location
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

    # Ask the user what components they want to install
    local selected_components
    selected_components=$(select_components)

    if [ -z "$selected_components" ]; then
        log_warn "No components selected. Exiting."
        exit 0
    fi

    log_info "Selected components: $selected_components"

    # Process selections
    for component in $selected_components; do
        case "$component" in
            shells)
                log_info "Configuring Shells (bash + zsh) and Starship Prompt..."
                install_tool_if_missing "zsh" "zsh"
                install_tool_if_missing "curl" "curl"
                
                # Check for Starship installation
                if ! command -v starship >/dev/null 2>&1; then
                    log_info "Installing Starship Prompt..."
                    curl -sS https://starship.rs/install.sh | sh -s -- -y
                fi
                
                safe_stow "bash"
                safe_stow "zsh"
                safe_stow "shared"
                safe_stow "config" # Includes .config/starship.toml
                ;;

            tmux)
                log_info "Configuring Tmux..."
                install_tool_if_missing "tmux" "tmux"
                
                # Install TPM (Tmux Plugin Manager) if missing
                if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
                    log_info "Installing Tmux Plugin Manager (TPM)..."
                    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
                fi
                
                safe_stow "tmux"
                ;;

            neovim)
                log_info "Configuring Neovim..."
                install_tool_if_missing "neovim" "nvim"
                install_tool_if_missing "git" "git"
                install_tool_if_missing "curl" "curl"
                
                # Neovim configs are located in config/.config/nvim/ (handled in stowing of config)
                safe_stow "config"
                ;;

            utilities)
                log_info "Installing and configuring Modern CLI Utilities..."
                install_tool_if_missing "bat" "bat"
                install_tool_if_missing "fzf" "fzf"
                install_tool_if_missing "ripgrep" "rg"
                install_tool_if_missing "eza" "eza"
                install_tool_if_missing "zoxide" "zoxide"
                install_tool_if_missing "fd" "fd"
                
                safe_stow "shared" # Includes .fzf_nord_light
                safe_stow "config" # Includes .config/bat/config
                ;;
        esac
    done

    log_success "Dotfiles configuration completed successfully!"
    if [ -d "$BACKUP_DIR" ]; then
        log_info "Original configurations backed up to: $BACKUP_DIR"
    fi
}

main "$@"
