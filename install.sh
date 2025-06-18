#!/bin/bash

# Dotfiles Installation Script
# Safely installs zsh and Ghostty configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
create_backup() {
  print_status "Creating backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
}

# Backup existing files
backup_file() {
  local file_path="$1"
  local backup_name="$2"

  if [ -f "$file_path" ] || [ -L "$file_path" ]; then
    print_status "Backing up $file_path"
    cp "$file_path" "$BACKUP_DIR/$backup_name" 2>/dev/null || true
  fi
}

# Install zsh configuration
install_zsh_config() {
  print_status "Installing zsh configuration..."

  # Backup existing .zshrc
  backup_file "$HOME/.zshrc" "zshrc"

  # Create symlink
  ln -sf "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
  print_success "Zsh configuration installed"
}

# Install Ghostty configuration
install_ghostty_config() {
  print_status "Installing Ghostty configuration..."

  # Create config directory
  mkdir -p "$HOME/.config/ghostty"

  # Backup existing config
  backup_file "$HOME/.config/ghostty/config" "ghostty-config"

  # Create symlink
  ln -sf "$SCRIPT_DIR/ghostty/config" "$HOME/.config/ghostty/config"
  print_success "Ghostty configuration installed"
}

# Install Oh My Zsh if not present
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
  else
    print_status "Oh My Zsh already installed"
  fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [ ! -d "$p10k_dir" ]; then
    print_status "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    print_success "Powerlevel10k theme installed"
  else
    print_status "Powerlevel10k theme already installed"
  fi
}

# Install zsh plugins
install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

  # zsh-autosuggestions
  if [ ! -d "$custom_dir/zsh-autosuggestions" ]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
  else
    print_status "zsh-autosuggestions already installed"
  fi

  # zsh-syntax-highlighting
  if [ ! -d "$custom_dir/zsh-syntax-highlighting" ]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom_dir/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
  else
    print_status "zsh-syntax-highlighting already installed"
  fi

  # zsh-completions
  if [ ! -d "$custom_dir/zsh-completions" ]; then
    print_status "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$custom_dir/zsh-completions"
    print_success "zsh-completions installed"
  else
    print_status "zsh-completions already installed"
  fi
}

# Check if required tools are installed
check_requirements() {
  print_status "Checking requirements..."

  # Check if Ghostty is installed
  if ! command -v ghostty &>/dev/null && [ ! -d "/Applications/Ghostty.app" ]; then
    print_warning "Ghostty terminal not found. Please install it first:"
    print_warning "  Download from: https://ghostty.org/download"
    print_warning "  Or build from source: https://ghostty.org/docs/install/build"
  fi

  # Check if git is installed
  if ! command -v git &>/dev/null; then
    print_error "Git is required but not installed. Please install git first."
    exit 1
  fi

  # Check if curl is installed
  if ! command -v curl &>/dev/null; then
    print_error "Curl is required but not installed. Please install curl first."
    exit 1
  fi

  # Check for Homebrew on macOS
  if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew &>/dev/null; then
    print_warning "Homebrew not found. Some modern tools may not be available."
    print_warning "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  fi
}

# Install modern development tools
install_modern_tools() {
  if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
    print_status "Installing modern development tools..."

    # Modern command replacements and development tools
    local tools=(
      "eza"       # Modern ls replacement
      "bat"       # Modern cat replacement
      "fd"        # Modern find replacement
      "ripgrep"   # Modern grep replacement
      "fzf"       # Fuzzy finder
      "procs"     # Modern ps replacement
      "dust"      # Modern du replacement
      "bottom"    # Modern top replacement
      "git-delta" # Better git diff
      "tldr"      # Simplified man pages
      "jq"        # JSON processor
      "yq"        # YAML processor
      "tree"      # Directory tree viewer
      "htop"      # Better top
      "wget"      # Download utility
      "curl"      # HTTP client
      "httpie"    # Better HTTP client
      "node"      # Node.js runtime
      "npm"       # Node package manager
      "yarn"      # Alternative package manager
      "gh"        # GitHub CLI
      "duf"       # Modern df replacement
      "zoxide"    # Smart cd replacement
      "starship"  # Cross-shell prompt alternative
    )

    for tool in "${tools[@]}"; do
      if ! command -v "$tool" &>/dev/null; then
        print_status "Installing $tool..."
        brew install "$tool" 2>/dev/null || true
      else
        print_status "$tool already installed"
      fi
    done

    print_success "Modern development tools installation complete"
  else
    print_warning "Skipping modern tools installation (requires macOS with Homebrew)"
  fi
}

# Install programming languages and development environments
install_programming_languages() {
  if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
    print_status "Installing programming languages and development environments..."

    # Essential programming languages for 2025 development
    local languages=(
      "go"          # Go programming language
      "python@3.12" # Latest stable Python
      "rust"        # Rust programming language
      "deno"        # Modern JavaScript/TypeScript runtime
      "bun"         # Fast JavaScript runtime and package manager
    )

    for lang in "${languages[@]}"; do
      local cmd_name="${lang%%@*}" # Remove version suffix for command check
      if [[ "$cmd_name" == "python@3.12" ]]; then
        cmd_name="python3"
      fi

      if ! command -v "$cmd_name" &>/dev/null; then
        print_status "Installing $lang..."
        brew install "$lang" 2>/dev/null || true
      else
        print_status "$lang already installed"
      fi
    done

    print_success "Programming languages installation complete"
  else
    print_warning "Skipping programming languages installation (requires macOS with Homebrew)"
  fi
}

# Configure Ghostty for optimal development
configure_ghostty() {
  print_status "Configuring Ghostty for development..."

  # Verify Ghostty resources directory
  if [ -d "/Applications/Ghostty.app" ]; then
    local resources_dir="/Applications/Ghostty.app/Contents/Resources"
    print_status "Ghostty resources found at: $resources_dir"

    # Test shell integration availability
    if [ -f "$resources_dir/shell-integration/zsh/ghostty-integration" ]; then
      print_success "Ghostty shell integration available"
    else
      print_warning "Ghostty shell integration not found"
    fi
  fi
}

# Create VS Code settings for Ghostty integration
configure_vscode() {
  print_status "Configuring VS Code for Ghostty integration..."

  local vscode_settings_dir="$HOME/Library/Application Support/Code/User"
  local settings_file="$vscode_settings_dir/settings.json"

  # Create VS Code settings directory if it doesn't exist
  mkdir -p "$vscode_settings_dir"

  # Backup existing settings
  if [ -f "$settings_file" ]; then
    backup_file "$settings_file" "vscode-settings.json"
    print_status "VS Code settings backed up - will merge with existing configuration"

    # Try to merge settings intelligently
    if command -v jq &>/dev/null; then
      print_status "Merging VS Code settings with existing configuration..."

      # Create temporary merged settings
      local temp_settings="/tmp/vscode-settings-merged.json"
      if jq -s '.[0] * .[1]' "$settings_file" "$SCRIPT_DIR/vscode/settings.json" >"$temp_settings" 2>/dev/null; then
        cp "$temp_settings" "$settings_file"
        rm "$temp_settings"
        print_success "VS Code settings merged successfully"
      else
        print_warning "Could not merge settings automatically - copying new settings"
        cp "$SCRIPT_DIR/vscode/settings.json" "$settings_file"
      fi
    else
      print_warning "jq not available - replacing settings file entirely"
      cp "$SCRIPT_DIR/vscode/settings.json" "$settings_file"
    fi
  else
    # No existing settings, just copy ours
    cp "$SCRIPT_DIR/vscode/settings.json" "$settings_file"
    print_success "VS Code settings configured for Ghostty"
  fi

  # Install recommended VS Code extensions
  install_vscode_extensions
}

# Install recommended VS Code extensions for better Ghostty integration
install_vscode_extensions() {
  if command -v code &>/dev/null; then
    print_status "Installing recommended VS Code extensions..."

    local extensions=(
      "ms-vscode.vscode-json"                       # JSON support
      "esbenp.prettier-vscode"                      # Code formatting
      "ms-python.python"                            # Python support
      "ms-vscode.vscode-typescript-next"            # TypeScript support
      "bradlc.vscode-tailwindcss"                   # Tailwind CSS
      "ms-vscode.vscode-eslint"                     # ESLint
      "golang.go"                                   # Go support
      "rust-lang.rust-analyzer"                     # Rust support
      "ms-kubernetes-tools.vscode-kubernetes-tools" # Kubernetes
      "ms-azuretools.vscode-docker"                 # Docker
      "github.copilot"                              # GitHub Copilot
      "github.copilot-chat"                         # Copilot Chat
      "eamodio.gitlens"                             # GitLens
      "ms-vscode.theme-tomorrowkit"                 # Tomorrow theme
      "pkief.material-icon-theme"                   # Better icons
    )

    for extension in "${extensions[@]}"; do
      print_status "Installing extension: $extension"
      code --install-extension "$extension" &>/dev/null || true
    done

    print_success "VS Code extensions installation complete"
  else
    print_warning "VS Code CLI not available - skipping extension installation"
    print_status "Install VS Code CLI: https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line"
  fi
}

# Main installation function
main() {
  echo -e "${BLUE}"
  echo "======================================"
  echo "  Dotfiles Configuration Installer"
  echo "  Optimized for Ghostty + VS Code"
  echo "======================================"
  echo -e "${NC}"

  check_requirements
  create_backup

  print_status "Starting installation..."

  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  install_modern_tools
  install_programming_languages
  install_zsh_config
  install_ghostty_config
  configure_ghostty
  configure_vscode

  echo -e "${GREEN}"
  echo "======================================"
  echo "  Installation Complete!"
  echo "======================================"
  echo -e "${NC}"

  print_success "All configurations have been installed successfully!"
  print_status "Backup created at: $BACKUP_DIR"

  echo ""
  print_status "Next steps:"
  echo "  1. Restart Ghostty or run: source ~/.zshrc"
  echo "  2. Run: p10k configure (if using Powerlevel10k for the first time)"
  echo "  3. Install VS Code extensions for better integration:"
  echo "     - GitLens"
  echo "     - Better Comments"
  echo "     - Bracket Pair Colorizer"
  echo "     - Auto Rename Tag"
  echo "  4. Set Ghostty as your default terminal in System Settings"
  echo "  5. Test Ghostty shell integration with: cmd+up/down for prompt navigation"
  echo ""

  print_status "Ghostty Features to Explore:"
  echo "  - Alt+click to move cursor to click location"
  echo "  - Triple-click+cmd to select command output"
  echo "  - cmd+shift+, to reload configuration"
  echo "  - Built-in theme switching with light/dark mode"
  echo ""

  print_warning "If you encounter any issues, check the backup directory for your previous configurations."
  print_status "For Ghostty documentation, visit: https://ghostty.org/docs"
}

# Run main function
main "$@"
