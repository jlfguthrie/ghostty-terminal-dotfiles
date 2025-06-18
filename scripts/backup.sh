#!/bin/bash

# Backup Script for Dotfiles Configuration
# Creates a timestamped backup of current configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-manual-backup-$(date +%Y%m%d-%H%M%S)"

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
create_backup_dir() {
    print_status "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Backup a file with error handling
backup_file_safe() {
    local source_file="$1"
    local backup_name="$2"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ -f "$source_file" ]; then
        print_status "Backing up: $source_file"
        cp "$source_file" "$backup_path" 2>/dev/null && \
            print_success "✓ Backed up: $backup_name" || \
            print_warning "✗ Failed to backup: $backup_name"
    elif [ -L "$source_file" ]; then
        print_status "Backing up symlink: $source_file"
        cp -P "$source_file" "$backup_path" 2>/dev/null && \
            print_success "✓ Backed up symlink: $backup_name" || \
            print_warning "✗ Failed to backup symlink: $backup_name"
    else
        print_warning "File not found: $source_file"
    fi
}

# Backup a directory recursively
backup_directory_safe() {
    local source_dir="$1"
    local backup_name="$2"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ -d "$source_dir" ]; then
        print_status "Backing up directory: $source_dir"
        cp -r "$source_dir" "$backup_path" 2>/dev/null && \
            print_success "✓ Backed up directory: $backup_name" || \
            print_warning "✗ Failed to backup directory: $backup_name"
    else
        print_warning "Directory not found: $source_dir"
    fi
}

# Main backup function
backup_configurations() {
    print_status "Starting configuration backup..."
    
    # Shell configurations
    backup_file_safe "$HOME/.zshrc" "zshrc"
    backup_file_safe "$HOME/.bashrc" "bashrc"
    backup_file_safe "$HOME/.bash_profile" "bash_profile"
    backup_file_safe "$HOME/.profile" "profile"
    backup_file_safe "$HOME/.p10k.zsh" "p10k.zsh"
    
    # Ghostty configuration
    backup_file_safe "$HOME/.config/ghostty/config" "ghostty-config"
    backup_directory_safe "$HOME/.config/ghostty" "ghostty-dir"
    
    # VS Code settings
    backup_file_safe "$HOME/Library/Application Support/Code/User/settings.json" "vscode-settings.json"
    backup_file_safe "$HOME/Library/Application Support/Code/User/keybindings.json" "vscode-keybindings.json"
    backup_directory_safe "$HOME/Library/Application Support/Code/User/snippets" "vscode-snippets"
    
    # Git configuration
    backup_file_safe "$HOME/.gitconfig" "gitconfig"
    backup_file_safe "$HOME/.gitignore_global" "gitignore_global"
    
    # SSH configuration
    backup_file_safe "$HOME/.ssh/config" "ssh-config"
    
    # Development tool configurations
    backup_file_safe "$HOME/.vimrc" "vimrc"
    backup_file_safe "$HOME/.nvimrc" "nvimrc"
    backup_directory_safe "$HOME/.config/nvim" "nvim-config"
    
    # Package manager files
    backup_file_safe "$HOME/.npmrc" "npmrc"
    backup_file_safe "$HOME/.yarnrc" "yarnrc"
    backup_file_safe "$HOME/.cargo/config" "cargo-config"
    
    # Other common configuration files
    backup_file_safe "$HOME/.tmux.conf" "tmux.conf"
    backup_file_safe "$HOME/.screenrc" "screenrc"
    backup_file_safe "$HOME/.inputrc" "inputrc"
    
    # Create a manifest of what was backed up
    print_status "Creating backup manifest..."
    cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
Dotfiles Backup Created: $(date)
Backup Directory: $BACKUP_DIR
Source System: $(uname -a)
User: $(whoami)

Files and directories backed up:
$(find "$BACKUP_DIR" -type f -not -name "MANIFEST.txt" | sort)

To restore a file:
1. Copy the backed up file to its original location
2. Example: cp "$BACKUP_DIR/zshrc" "$HOME/.zshrc"

To restore all configurations:
1. Run the install script with --restore flag (if available)
2. Or manually copy files back to their original locations

Original dotfiles repository: $SCRIPT_DIR
EOF
    
    print_success "Backup manifest created: $BACKUP_DIR/MANIFEST.txt"
}

# Create restoration script
create_restore_script() {
    print_status "Creating restoration script..."
    
    cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

# Automatic Restoration Script
# Generated during backup process

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restoring configurations from: $BACKUP_DIR"
echo "WARNING: This will overwrite current configurations!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restoration cancelled."
    exit 1
fi

# Restore shell configurations
[ -f "$BACKUP_DIR/zshrc" ] && cp "$BACKUP_DIR/zshrc" "$HOME/.zshrc"
[ -f "$BACKUP_DIR/bashrc" ] && cp "$BACKUP_DIR/bashrc" "$HOME/.bashrc"
[ -f "$BACKUP_DIR/p10k.zsh" ] && cp "$BACKUP_DIR/p10k.zsh" "$HOME/.p10k.zsh"

# Restore Ghostty configuration
[ -f "$BACKUP_DIR/ghostty-config" ] && {
    mkdir -p "$HOME/.config/ghostty"
    cp "$BACKUP_DIR/ghostty-config" "$HOME/.config/ghostty/config"
}

# Restore VS Code settings
[ -f "$BACKUP_DIR/vscode-settings.json" ] && {
    mkdir -p "$HOME/Library/Application Support/Code/User"
    cp "$BACKUP_DIR/vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
}

# Restore Git configuration
[ -f "$BACKUP_DIR/gitconfig" ] && cp "$BACKUP_DIR/gitconfig" "$HOME/.gitconfig"

echo "Restoration complete! You may need to restart your terminal."
EOF

    chmod +x "$BACKUP_DIR/restore.sh"
    print_success "Restoration script created: $BACKUP_DIR/restore.sh"
}

# Main function
main() {
    echo -e "${BLUE}"
    echo "======================================"
    echo "  Dotfiles Configuration Backup"
    echo "======================================"
    echo -e "${NC}"
    
    create_backup_dir
    backup_configurations
    create_restore_script
    
    echo -e "${GREEN}"
    echo "======================================"
    echo "  Backup Complete!"
    echo "======================================"
    echo -e "${NC}"
    
    print_success "Backup created at: $BACKUP_DIR"
    print_status "Files backed up: $(find "$BACKUP_DIR" -type f | wc -l | tr -d ' ')"
    print_status "Total size: $(du -sh "$BACKUP_DIR" | cut -f1)"
    
    echo ""
    print_status "To restore configurations:"
    echo "  1. Run: $BACKUP_DIR/restore.sh"
    echo "  2. Or manually copy files from: $BACKUP_DIR"
    echo "  3. Check the manifest: $BACKUP_DIR/MANIFEST.txt"
    echo ""
    
    print_warning "Keep this backup safe! It contains your current configurations."
}

# Run main function
main "$@"
