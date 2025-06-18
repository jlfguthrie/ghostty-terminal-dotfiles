# Zsh Configuration for Ghostty Terminal - June 2025
# Optimized to work WITH Ghostty's built-in features, not against them
# Focus on shell-specific enhancements that complement Ghostty's capabilities

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - Using Powerlevel10k for advanced prompt features
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins - Carefully chosen to complement Ghostty's features
plugins=(
  git
  brew
  macos
  vscode
  docker
  kubectl
  terraform
  aws
  npm
  yarn
  node
  python
  golang
  rust
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# CUSTOM PROMPT CONFIGURATION
# ============================================================================
# A custom prompt with a VS Code/Copilot aesthetic.
# This overrides the ZSH_THEME setting.
ZSH_THEME=""
autoload -U colors && colors

# Right-side prompt (RPROMPT) - Time
RPROMPT='%F{244}at %F{cyan}%T%f'

# Main prompt (PROMPT)
# Line 1: user@host in path
# Line 2: ❯
PROMPT='%F{cyan}%n%f@%F{magenta}%m%f %F{244}in%f %F{green}%~%f'
PROMPT+=$'\n%F{blue}❯%f '

# ============================================================================
# GHOSTTY INTEGRATION - Enhanced for 2025
# ============================================================================

# Set TERM for optimal Ghostty experience (fallback to xterm-256color if ghostty not available)
if [ "$TERM_PROGRAM" = "Ghostty" ]; then
    export TERM="ghostty"
else
    export TERM="xterm-256color"
fi
export COLORTERM="truecolor"

# Enhanced Ghostty shell integration
# Ghostty automatically injects shell integration, but we add manual fallback
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    # Verify automatic integration is working
    if ! type ghostty_prompt_mark &>/dev/null; then
        # Fallback to manual integration if auto-injection failed
        builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" 2>/dev/null || true
    fi

    # Enhanced terminal title for better VS Code integration
    autoload -Uz add-zsh-hook

    function ghostty_set_title() {
        # Set both tab title and window title
        print -Pn "\e]0;%n@%m: %~\a"
        print -Pn "\e]1;%~\a"
    }

    add-zsh-hook precmd ghostty_set_title

    # Mark command boundaries for better semantic selection
    function ghostty_preexec() {
        # Mark the start of command execution
        print -Pn "\e]133;C\a"
    }

    add-zsh-hook preexec ghostty_preexec
fi

# ============================================================================
# DEVELOPMENT ENVIRONMENT SETUP - Enhanced for 2025
# ============================================================================

# Language version managers with performance optimizations
export NVM_DIR="$HOME/.nvm"
# Lazy load NVM for faster shell startup
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}

# Python with pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Go development
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# Rust development
export CARGO_HOME="$HOME/.cargo"
export PATH="$HOME/.cargo/bin:$PATH"

# Bun (fast JavaScript runtime)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# VS Code command line tools
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# Ghostty terminal command line tools
export PATH="/Applications/Ghostty.app/Contents/MacOS:$PATH"

# ============================================================================
# MODERN COMMAND REPLACEMENTS - 2025 Edition
# ============================================================================

# Enhanced file operations
if command -v eza &> /dev/null; then
    alias ls='eza --icons --git --group-directories-first'
    alias ll='eza -la --icons --git --time-style=long-iso --group-directories-first'
    alias la='eza -la --icons --git --group-directories-first'
    alias tree='eza --tree --icons --git'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls -G --color=auto'
    alias ll='ls -la'
    alias la='ls -la'
fi

# Enhanced text processing
command -v bat &> /dev/null && alias cat='bat --style=auto --theme=auto'
command -v batcat &> /dev/null && alias cat='batcat --style=auto --theme=auto'

# Enhanced searching and navigation
command -v fd &> /dev/null && alias find='fd'
command -v rg &> /dev/null && alias grep='rg --smart-case'
command -v fzf &> /dev/null && {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'
}

# Enhanced system monitoring
command -v procs &> /dev/null && alias ps='procs'
command -v dust &> /dev/null && alias du='dust'
command -v bottom &> /dev/null && alias top='btm'
command -v duf &> /dev/null && alias df='duf'

# Enhanced git tools
command -v delta &> /dev/null && {
    export GIT_PAGER='delta'
    alias gdiff='git diff | delta'
}

# Enhanced JSON/YAML processing
command -v jq &> /dev/null && alias json_format='jq'
command -v yq &> /dev/null && alias yaml_format='yq'

# ============================================================================
# GIT ENHANCEMENTS - Optimized for Ghostty's semantic selection
# ============================================================================

# Git aliases that work perfectly with Ghostty's cmd+click selection
alias gs='git status --short --branch'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpo='git push origin'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glo='git log --oneline --graph --decorate --all -10'
alias glol='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gcd='git checkout develop'
alias gm='git merge'
alias gr='git rebase'
alias gri='git rebase -i'
alias gst='git stash'
alias gstp='git stash pop'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'

# Advanced git functions
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Quick commit with automatic message
gquick() {
    git add -A && git commit -m "${1:-Quick update}"
}

# Create and push new branch
gnew() {
    if [ -z "$1" ]; then
        echo "Usage: gnew <branch-name>"
        return 1
    fi
    git checkout -b "$1" && git push -u origin "$1"
}

# ============================================================================
# VS CODE INTEGRATION - Enhanced for 2025
# ============================================================================

# VS Code shortcuts optimized for Ghostty workflow
alias c.='code .'
alias cr='code -r .'
alias ci='code --insiders'
alias cw='code --wait'

# Enhanced project management
cproj() {
    local project_dir="$HOME/dev"
    if [ -n "$1" ]; then
        if [ -d "$project_dir/$1" ]; then
            cd "$project_dir/$1" && code .
        else
            echo "Project '$1' not found in $project_dir"
            return 1
        fi
    else
        echo "Available projects:"
        eza -1 "$project_dir/" 2>/dev/null || ls -1 "$project_dir/"
    fi
}

# Open git repository in VS Code with branch info
cgit() {
    local repo_url=$(git remote get-url origin 2>/dev/null)
    local branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$repo_url" ]; then
        echo "Opening repository (branch: ${branch:-unknown}) in VS Code..."
        code .
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Quick VS Code workspace management
cworkspace() {
    if [ -f "*.code-workspace" ]; then
        code *.code-workspace
    else
        code .
    fi
}

# ============================================================================
# DEVELOPMENT UTILITIES - Enhanced for 2025
# ============================================================================

# Quick HTTP server with enhanced options
serve() {
    local port=${1:-8000}
    local dir=${2:-.}
    echo "🚀 Starting HTTP server on port $port in directory: $dir"
    echo "📍 URL: http://localhost:$port"
    if command -v python3 &> /dev/null; then
        cd "$dir" && python3 -m http.server "$port"
    elif command -v python &> /dev/null; then
        cd "$dir" && python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python not found"
        return 1
    fi
}

# Enhanced JSON processing with error handling
json_pretty() {
    if [ -t 0 ]; then
        if [ -n "$1" ]; then
            echo "$1" | jq . 2>/dev/null || echo "$1" | python3 -m json.tool
        else
            echo "Usage: json_pretty '<json_string>' or echo 'json' | json_pretty"
        fi
    else
        jq . 2>/dev/null || python3 -m json.tool
    fi
}

# Process management with enhanced feedback
killp() {
    if [ -z "$1" ]; then
        echo "Usage: killp <process_name>"
        echo "Available processes:"
        ps aux | grep -v grep | awk '{print $11}' | sort | uniq
        return 1
    fi

    local pids=$(ps aux | grep -i "$1" | grep -v grep | awk '{print $2}')
    if [ -n "$pids" ]; then
        echo "Killing processes matching '$1':"
        ps aux | grep -i "$1" | grep -v grep
        echo "$pids" | xargs kill -9
        echo "✅ Processes killed"
    else
        echo "❌ No processes found matching '$1'"
    fi
}

# Enhanced directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1" && echo "📁 Created and entered: $(pwd)"
}

# Quick project initialization
initproj() {
    local name=${1:-$(basename $(pwd))}
    local type=${2:-node}

    case $type in
        node|js|javascript)
            npm init -y
            echo "node_modules/" > .gitignore
            echo "*.log" >> .gitignore
            ;;
        python|py)
            python3 -m venv venv
            echo "venv/" > .gitignore
            echo "__pycache__/" >> .gitignore
            echo "*.pyc" >> .gitignore
            ;;
        go)
            go mod init "$name"
            echo "# $name\n\nA Go project." > README.md
            ;;
        rust)
            cargo init .
            ;;
        *)
            echo "Supported types: node, python, go, rust"
            return 1
            ;;
    esac

    git init
    echo "# $name" > README.md
    git add .
    git commit -m "Initial commit"
    echo "✅ Project '$name' initialized as $type project"
}

# Enhanced archive extraction
extract() {
    if [ -f "$1" ]; then
        echo "📦 Extracting $1..."
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.xz)        xz -d "$1"       ;;
            *.lzma)      lzma -d "$1"     ;;
            *)           echo "❌ '$1' cannot be extracted via extract()" ;;
        esac
        echo "✅ Extraction complete"
    else
        echo "❌ '$1' is not a valid file"
    fi
}

# ============================================================================
# DOCKER & KUBERNETES HELPERS - Enhanced for 2025
# ============================================================================

# Docker shortcuts with better feedback
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"'
alias dv='docker volume ls'
alias dn='docker network ls'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -f'
alias dcleanall='docker system prune -a -f'

# Docker compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs'
alias dcr='docker-compose restart'

# Advanced docker functions
dsh() {
    local container=${1:-$(docker ps --format "{{.Names}}" | head -1)}
    if [ -n "$container" ]; then
        echo "🐚 Entering container: $container"
        docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
    else
        echo "❌ No running containers found"
    fi
}

dlogs() {
    local container=${1:-$(docker ps --format "{{.Names}}" | head -1)}
    if [ -n "$container" ]; then
        docker logs -f "$container"
    else
        echo "❌ No running containers found"
    fi
}

# Kubernetes shortcuts with better formatting
alias k='kubectl'
alias kgp='kubectl get pods -o wide'
alias kgs='kubectl get services -o wide'
alias kgd='kubectl get deployments -o wide'
alias kgn='kubectl get nodes -o wide'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
alias kctx='kubectl config current-context'
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'

# Enhanced kubernetes functions
kshell() {
    local pod=${1:-$(kubectl get pods -o name | head -1 | cut -d/ -f2)}
    if [ -n "$pod" ]; then
        echo "🐚 Entering pod: $pod"
        kubectl exec -it "$pod" -- /bin/bash || kubectl exec -it "$pod" -- /bin/sh
    else
        echo "❌ No pods found"
    fi
}

# ============================================================================
# ENVIRONMENT VARIABLES - Optimized for 2025
# ============================================================================

# Editor preferences - VS Code as primary
export EDITOR='code --wait'
export VISUAL='code --wait'
export GIT_EDITOR='code --wait'

# Terminal and color support
export TERM='ghostty'
export COLORTERM='truecolor'

# Optimize for Ghostty's capabilities
export MANPAGER="bat --language man --style plain"
export PAGER="bat --style plain"

# Development
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# History configuration - Enhanced
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST

# Enhanced completion system
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Faster completion loading
autoload -Uz compinit
compinit -C  # Use fast loading by default

# ============================================================================
# POWERLEVEL10K INSTANT PROMPT
# ============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# FZF INTEGRATION - Enhanced for Ghostty
# ============================================================================

# Enhanced FZF setup if available
if command -v fzf &> /dev/null; then
    # Key bindings
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # Custom functions using fzf
    fcd() {
        local dir
        dir=$(fd --type d 2> /dev/null | fzf --preview 'eza --tree --level=2 {}' || find . -type d 2> /dev/null | fzf) && cd "$dir"
    }

    fcode() {
        local file
        file=$(fd --type f 2> /dev/null | fzf --preview 'bat --color=always {}' || find . -type f 2> /dev/null | fzf) && code "$file"
    }

    # Git integration with fzf
    fgco() {
        local branch
        branch=$(git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf) && git checkout "$branch"
    }

    # Process killer with fzf
    fkill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        if [ "x$pid" != "x" ]; then
            echo $pid | xargs kill -${1:-9}
        fi
    }
fi

# ============================================================================
# LOAD EXTERNAL CONFIGURATIONS
# ============================================================================

# Load aliases from separate file
[[ -f "$ZSH_CUSTOM/aliases.sh" ]] && source "$ZSH_CUSTOM/aliases.sh"
[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"

# Load local customizations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load any work-specific configurations
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work

# ============================================================================
# FINAL SETUP
# ============================================================================

# Show Ghostty integration status
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    echo "✅ Ghostty shell integration active"
    echo "💡 Use cmd+up/down to navigate prompts, cmd+click to select command output"
else
    echo "ℹ️  Running outside Ghostty - some features may be limited"
fi
