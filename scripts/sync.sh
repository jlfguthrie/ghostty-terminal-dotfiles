#!/bin/bash

# Sync script to keep dotfiles repository updated
# Copies current configurations to repository and commits changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

# Copy current configurations to repository
sync_configs() {
    print_status "Syncing configurations to repository..."
    
    # Sync zsh configuration
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$SCRIPT_DIR/zsh/.zshrc"
        print_success "Synced .zshrc"
    else
        print_warning ".zshrc not found"
    fi
    
    # Sync Ghostty configuration
    if [ -f "$HOME/.config/ghostty/config" ]; then
        cp "$HOME/.config/ghostty/config" "$SCRIPT_DIR/ghostty/config"
        print_success "Synced Ghostty config"
    else
        print_warning "Ghostty config not found"
    fi
}

# Check for changes and commit
commit_changes() {
    cd "$SCRIPT_DIR"
    
    if [ -n "$(git status --porcelain)" ]; then
        print_status "Changes detected, committing to repository..."
        
        git add .
        
        # Generate commit message with timestamp
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local commit_msg="Update configurations - $timestamp"
        
        # If user provided commit message, use it
        if [ $# -gt 0 ]; then
            commit_msg="$*"
        fi
        
        git commit -m "$commit_msg"
        
        print_success "Changes committed: $commit_msg"
        
        # Ask if user wants to push
        read -p "Push changes to remote repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            print_success "Changes pushed to remote repository"
        else
            print_status "Changes committed locally. Push manually when ready."
        fi
    else
        print_status "No changes detected"
    fi
}

# Main function
main() {
    echo -e "${BLUE}"
    echo "======================================"
    echo "  Dotfiles Sync Script"
    echo "======================================"
    echo -e "${NC}"
    
    sync_configs
    commit_changes "$@"
    
    print_success "Sync complete!"
}

# Run main function with all arguments
main "$@"
