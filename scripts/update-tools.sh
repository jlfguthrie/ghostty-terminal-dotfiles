#!/usr/bin/env bash
# update-tools.sh - Automated tool update checker and installer
# Part of Ghostty Terminal Dotfiles - https://github.com/jlfguthrie/ghostty-terminal-dotfiles

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${BLUE}🔄 Ghostty Dotfiles - Tool Update Manager${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get current version
get_version() {
    local tool="$1"
    case "$tool" in
        "ghostty")
            if command_exists ghostty; then
                ghostty --version 2>/dev/null | head -1 || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        "code")
            if command_exists code; then
                code --version 2>/dev/null | head -1 || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        "brew")
            if command_exists brew; then
                brew --version 2>/dev/null | head -1 || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        "git")
            if command_exists git; then
                git --version 2>/dev/null || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        "zsh")
            if command_exists zsh; then
                zsh --version 2>/dev/null || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        "node")
            if command_exists node; then
                node --version 2>/dev/null || echo "unknown"
            else
                echo "not installed"
            fi
            ;;
        *)
            echo "unknown tool"
            ;;
    esac
}

# Check and display current versions
echo -e "${YELLOW}📋 Current Tool Versions:${NC}"
echo "----------------------------------------"

tools=("ghostty" "code" "brew" "git" "zsh" "node")
for tool in "${tools[@]}"; do
    version=$(get_version "$tool")
    if [[ "$version" == "not installed" ]]; then
        echo -e "❌ $tool: ${RED}not installed${NC}"
    elif [[ "$version" == "unknown" ]]; then
        echo -e "❓ $tool: ${YELLOW}version unknown${NC}"
    else
        echo -e "✅ $tool: ${GREEN}$version${NC}"
    fi
done

echo ""

# Check for Homebrew updates
if command_exists brew; then
    echo -e "${YELLOW}🍺 Checking Homebrew updates...${NC}"
    
    # Update Homebrew
    echo "  Updating Homebrew..."
    brew update --quiet
    
    # Check for outdated packages
    outdated=$(brew outdated --quiet)
    if [[ -n "$outdated" ]]; then
        echo -e "  ${YELLOW}Outdated packages found:${NC}"
        echo "$outdated" | sed 's/^/    /'
        
        read -p "  Update outdated packages? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  Upgrading packages..."
            brew upgrade
            echo -e "  ${GREEN}✅ Packages upgraded${NC}"
        else
            echo -e "  ${YELLOW}⏭️  Skipped package upgrades${NC}"
        fi
    else
        echo -e "  ${GREEN}✅ All Homebrew packages are up to date${NC}"
    fi
    echo ""
fi

# Check for VS Code updates
if command_exists code; then
    echo -e "${YELLOW}💻 Checking VS Code extensions...${NC}"
    
    # List outdated extensions
    outdated_ext=$(code --list-extensions --show-versions | grep -v "^$" | head -5 2>/dev/null || echo "")
    
    if [[ -n "$outdated_ext" ]]; then
        echo "  Current extensions (showing first 5):"
        echo "$outdated_ext" | sed 's/^/    /'
        
        read -p "  Update VS Code extensions? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  Updating extensions..."
            code --update-extensions
            echo -e "  ${GREEN}✅ Extensions updated${NC}"
        else
            echo -e "  ${YELLOW}⏭️  Skipped extension updates${NC}"
        fi
    else
        echo -e "  ${GREEN}✅ VS Code extensions check complete${NC}"
    fi
    echo ""
fi

# Check for Ghostty updates
echo -e "${YELLOW}👻 Checking Ghostty...${NC}"
if command_exists ghostty; then
    current_version=$(get_version "ghostty")
    echo "  Current version: $current_version"
    echo "  💡 Check https://github.com/mitchellh/ghostty/releases for latest version"
    echo "  💡 Ghostty auto-updates if installed via official installer"
else
    echo -e "  ${RED}❌ Ghostty not found${NC}"
    echo "  💡 Install from: https://github.com/mitchellh/ghostty"
fi
echo ""

# Check Node.js and npm
if command_exists node && command_exists npm; then
    echo -e "${YELLOW}📦 Checking Node.js packages...${NC}"
    
    # Check for npm updates
    npm_outdated=$(npm outdated -g --depth=0 2>/dev/null | tail -n +2 || echo "")
    
    if [[ -n "$npm_outdated" ]]; then
        echo "  Outdated global packages:"
        echo "$npm_outdated" | sed 's/^/    /'
        
        read -p "  Update global npm packages? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  Updating global packages..."
            npm update -g
            echo -e "  ${GREEN}✅ Global packages updated${NC}"
        else
            echo -e "  ${YELLOW}⏭️  Skipped npm updates${NC}"
        fi
    else
        echo -e "  ${GREEN}✅ Global npm packages are up to date${NC}"
    fi
    echo ""
fi

# Final recommendations
echo -e "${BLUE}💡 Update Recommendations:${NC}"
echo "========================================="
echo "• Run this script monthly to stay current"
echo "• Check Ghostty releases manually for major updates"
echo "• Keep macOS updated for best terminal compatibility"
echo "• Review VS Code extension updates for breaking changes"
echo "• Backup configurations before major updates"
echo ""

# Check if dotfiles repo needs updates
if [[ -d ".git" ]]; then
    echo -e "${YELLOW}🔄 Checking dotfiles repository...${NC}"
    
    # Fetch latest from origin
    git fetch origin --quiet 2>/dev/null || echo "  Could not fetch from origin"
    
    # Check if we're behind
    local_commit=$(git rev-parse HEAD 2>/dev/null || echo "")
    remote_commit=$(git rev-parse @{u} 2>/dev/null || echo "")
    
    if [[ -n "$local_commit" && -n "$remote_commit" && "$local_commit" != "$remote_commit" ]]; then
        echo -e "  ${YELLOW}📥 Updates available for dotfiles repository${NC}"
        echo "  Run: git pull origin main"
    else
        echo -e "  ${GREEN}✅ Dotfiles repository is up to date${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎉 Update check complete!${NC}"
echo -e "${BLUE}Next run: $(date -v+1m +'%Y-%m-%d')${NC}"
