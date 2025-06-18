#!/bin/bash

# Version Checker for Ghostty Terminal Dotfiles
# Ensures all components are using the latest versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_version() {
    echo -e "${GREEN}✓${NC} $1: ${YELLOW}$2${NC}"
}

echo -e "${BLUE}"
echo "======================================"
echo "  Ghostty Terminal Dotfiles"
echo "  Version & Health Check"
echo "======================================"
echo -e "${NC}"

print_status "Checking core system components..."

# Check macOS version
if [[ "$OSTYPE" == "darwin"* ]]; then
    macos_version=$(sw_vers -productVersion)
    print_version "macOS" "$macos_version"
else
    print_warning "Not running on macOS - some features may be limited"
fi

# Check Zsh
if command -v zsh &> /dev/null; then
    zsh_version=$(zsh --version | awk '{print $2}')
    print_version "Zsh" "$zsh_version"
    
    # Check if using our enhanced zsh config
    if [ -f "$HOME/.zshrc" ] && grep -q "Ghostty Terminal" "$HOME/.zshrc"; then
        print_success "Enhanced Zsh configuration detected"
    else
        print_warning "Standard Zsh configuration - consider running ./install.sh"
    fi
else
    print_error "Zsh not found"
fi

# Check Ghostty
print_status "Checking Ghostty terminal..."
if [ -d "/Applications/Ghostty.app" ]; then
    # Try to get Ghostty version from app bundle
    ghostty_version=$(defaults read /Applications/Ghostty.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "Unknown")
    print_version "Ghostty" "$ghostty_version"
    
    # Check shell integration
    if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
        print_success "Ghostty shell integration active"
        print_version "Resources Dir" "$GHOSTTY_RESOURCES_DIR"
    else
        print_warning "Ghostty shell integration not detected (run from Ghostty terminal)"
    fi
    
    # Check configuration
    if [ -f "$HOME/.config/ghostty/config" ]; then
        print_success "Ghostty configuration found"
    else
        print_warning "Ghostty configuration not found - run ./install.sh"
    fi
else
    print_error "Ghostty not found - download from https://ghostty.org"
fi

# Check VS Code
print_status "Checking VS Code..."
if command -v code &> /dev/null; then
    vscode_version=$(code --version | head -1)
    print_version "VS Code" "$vscode_version"
    
    # Check if VS Code CLI is properly installed
    print_success "VS Code CLI available"
    
    # Check settings
    if [ -f "$HOME/Library/Application Support/Code/User/settings.json" ]; then
        if grep -q "Ghostty" "$HOME/Library/Application Support/Code/User/settings.json"; then
            print_success "Ghostty-optimized VS Code settings detected"
        else
            print_warning "Standard VS Code settings - consider running ./install.sh"
        fi
    fi
else
    print_warning "VS Code CLI not available - install from https://code.visualstudio.com"
fi

# Check Git
if command -v git &> /dev/null; then
    git_version=$(git --version | awk '{print $3}')
    print_version "Git" "$git_version"
    
    # Check git configuration
    git_name=$(git config --global user.name 2>/dev/null || echo "Not set")
    git_email=$(git config --global user.email 2>/dev/null || echo "Not set")
    if [ "$git_name" != "Not set" ] && [ "$git_email" != "Not set" ]; then
        print_success "Git configured: $git_name <$git_email>"
    else
        print_warning "Git not configured - run: git config --global user.name/user.email"
    fi
else
    print_error "Git not found"
fi

# Check Homebrew
print_status "Checking Homebrew and modern tools..."
if command -v brew &> /dev/null; then
    brew_version=$(brew --version | head -1 | awk '{print $2}')
    print_version "Homebrew" "$brew_version"
    
    # Check modern tools
    tools=(
        "eza:eza"
        "bat:bat" 
        "fd:fd"
        "ripgrep:rg"
        "fzf:fzf"
        "git-delta:delta"
        "jq:jq"
        "gh:gh"
        "httpie:http"
        "tldr:tldr"
    )
    
    print_status "Checking modern command-line tools..."
    for tool_pair in "${tools[@]}"; do
        package_name="${tool_pair%%:*}"
        command_name="${tool_pair##*:}"
        
        if command -v "$command_name" &> /dev/null; then
            version=$($command_name --version 2>/dev/null | head -1 | awk '{print $NF}' | sed 's/v//')
            print_version "$package_name" "$version"
        else
            print_warning "$package_name not installed - run: brew install $package_name"
        fi
    done
else
    print_warning "Homebrew not found - install from https://brew.sh"
fi

# Check language version managers
print_status "Checking language version managers..."

# Node.js / NVM
if [ -d "$HOME/.nvm" ]; then
    print_success "NVM installed"
    if command -v node &> /dev/null; then
        node_version=$(node --version)
        print_version "Node.js" "$node_version"
    fi
else
    print_warning "NVM not found - install from https://github.com/nvm-sh/nvm"
fi

# Python / pyenv
if command -v pyenv &> /dev/null; then
    pyenv_version=$(pyenv --version | awk '{print $2}')
    print_version "pyenv" "$pyenv_version"
    
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version | awk '{print $2}')
        print_version "Python" "$python_version"
    fi
else
    print_warning "pyenv not found - install from https://github.com/pyenv/pyenv"
fi

# Go
if command -v go &> /dev/null; then
    go_version=$(go version | awk '{print $3}' | sed 's/go//')
    print_version "Go" "$go_version"
else
    print_warning "Go not found - install with: brew install go"
fi

# Rust
if command -v rustc &> /dev/null; then
    rust_version=$(rustc --version | awk '{print $2}')
    print_version "Rust" "$rust_version"
else
    print_warning "Rust not found - install from https://rustup.rs"
fi

# Check Oh My Zsh and Powerlevel10k
print_status "Checking Zsh enhancements..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh My Zsh installed"
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k theme installed"
    else
        print_warning "Powerlevel10k not found - run ./install.sh"
    fi
    
    # Check plugins
    plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    if [ -d "$plugins_dir/zsh-autosuggestions" ]; then
        print_success "zsh-autosuggestions installed"
    else
        print_warning "zsh-autosuggestions not found"
    fi
else
    print_warning "Oh My Zsh not found - run ./install.sh"
fi

# Performance check
print_status "Performance check..."
if command -v zsh &> /dev/null; then
    startup_time=$(time zsh -i -c exit 2>&1 | grep real | awk '{print $2}')
    if [ -n "$startup_time" ]; then
        print_version "Zsh startup time" "$startup_time"
    fi
fi

# Summary
echo -e "${BLUE}"
echo "======================================"
echo "  Health Check Complete"
echo "======================================"
echo -e "${NC}"

# Recommendations
print_status "Recommendations:"
echo "  1. Keep Ghostty updated from https://ghostty.org"
echo "  2. Run 'brew upgrade' regularly for latest tools"
echo "  3. Update VS Code extensions monthly"
echo "  4. Check ./scripts/update-tools.sh for automated updates"
echo "  5. Backup configurations with ./scripts/backup.sh"

# Check for updates available
print_status "Checking for available updates..."
if command -v brew &> /dev/null; then
    outdated=$(brew outdated)
    if [ -n "$outdated" ]; then
        print_warning "Homebrew packages have updates available:"
        echo "$outdated"
        echo "Run: brew upgrade"
    else
        print_success "All Homebrew packages are up to date"
    fi
fi

echo ""
print_success "Version check complete! 🚀"
