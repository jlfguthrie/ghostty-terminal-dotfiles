#!/bin/zsh
# shellcheck shell=bash
# Aliases for Ghostty + Zsh Configuration - 2025 Edition
# Separated for better organization and maintainability

# ============================================================================
# SYSTEM ALIASES (macOS optimized)
# ============================================================================

# Enhanced directory listing with modern tools
if command -v eza &>/dev/null; then
  alias ls='eza --icons --git --group-directories-first'
  alias la='eza -la --icons --git --group-directories-first'
  alias ll='eza -la --icons --git --time-style=long-iso --group-directories-first'
  alias tree='eza --tree --icons --git'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls -G --color=auto'
  alias la='ls -la'
  alias ll='ls -la'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick access to common directories
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
alias dev='cd ~/dev'
alias projects='cd ~/Projects'

# System shortcuts
alias reload='source ~/.zshrc && echo "✅ Zsh configuration reloaded"'
alias path='echo $PATH | tr ":" "\n"'
alias ports='netstat -tulanp'
alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'
alias publicip='curl -s https://ipinfo.io/ip'
alias localip='ipconfig getifaddr en0'

# macOS specific
alias flush='dscacheutil -flushcache && killall -HUP mDNSResponder && echo "✅ DNS cache flushed"'
alias show='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias cleanup='sudo periodic daily weekly monthly'

# ============================================================================
# GHOSTTY SPECIFIC ALIASES - Leveraging 2025 features
# ============================================================================

# Ghostty configuration management
alias ghostty-config='code ~/.config/ghostty/config'
alias ghostty-reload='printf "\033[_Greload-config\033\\"'
alias ghostty-themes='ghostty +list-themes'
alias ghostty-keys='ghostty +list-keybinds'

# Terminal management leveraging Ghostty's features
alias clear-scrollback='printf "\033[3J"'
alias reset-terminal='printf "\033c"'
alias term-title='printf "\033]0;%s\007"'

# Quick theme switching (if using dynamic themes)
alias theme-dark='printf "\033]1337;SetProfile=Dark\007"'
alias theme-light='printf "\033]1337;SetProfile=Light\007"'

# ============================================================================
# DEVELOPMENT WORKFLOW ALIASES - 2025 Edition
# ============================================================================

# NOTE: Many common aliases (e.g., for git, docker, kubectl) are now provided
# by Oh My Zsh plugins to avoid conflicts and improve maintainability.
# See the `plugins` array in ~/.zshrc for the full list.

# Quick navigation
alias c.='code .'
alias cr='code -r .'

# Enhanced project management
cproj() {
  local project_name=${1:-$(basename "$(pwd)")}
  local template=${2:-basic}

  echo "🚀 Creating new project: $project_name using $template template"

  case $template in
  basic)
    mkdir "$project_name" && cd "$project_name"
    echo "# $project_name" >README.md
    ;;
  node)
    mkdir "$project_name" && cd "$project_name"
    npm init -y
    printf "node_modules/\n*.log\n.env\n" >.gitignore
    echo "console.log('Hello, $project_name!');" >index.js
    ;;
  python)
    mkdir "$project_name" && cd "$project_name"
    python3 -m venv venv
    printf "venv/\n__pycache__/\n*.pyc\n.env\n" >.gitignore
    echo "print('Hello, $project_name!')" >main.py
    printf "# %s\n\nA Python project.\n" "$project_name" >README.md
    ;;
  go)
    mkdir "$project_name" && cd "$project_name"
    go mod init "$project_name"
    printf "# %s\n\nA Go project.\n" "$project_name" >README.md
    cat >main.go <<EOF
package main

import "fmt"

func main() {
    fmt.Println("Hello, $project_name!")
}
EOF
    ;;
  rust)
    cargo new "$project_name" --bin
    ;;
  next)
    npx create-next-app@latest "$project_name" --typescript --tailwind --eslint
    ;;
  *)
    echo "Supported templates: basic, node, python, go, rust, next"
    return 1
    ;;
  esac

  echo "✅ Project '$project_name' created successfully"
}

# ============================================================================
# DEVELOPMENT UTILITIES - Modern additions
# ============================================================================

# Package management shortcuts
alias ni='npm install'
alias nid='npm install --save-dev'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nr='npm run'
alias nls='npm list --depth=0'

# ============================================================================
# AI INTEGRATION - Ollama
# ============================================================================

# Ghostty AI Integration with Ollama

# ai: Get a command and execute it immediately
function ai() {
  # Get the suggested command from the Python script
  local suggestion
  suggestion=$("/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/.venv/bin/python" "/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/ai/ghostty_ai.py" "$@")

  # Execute the suggested command
  eval "$suggestion"
}

# aik: Get a command and ask for confirmation before executing
function aik() {
  # Get the suggested command from the Python script
  local suggestion
  suggestion=$("/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/.venv/bin/python" "/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/ai/ghostty_ai.py" "$@")

  # Display the suggested command to the user
  echo "Suggested command: \`$suggestion\`"

  # Ask for confirmation
  read -r "REPLY?Execute this command? [y/N] "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$suggestion"
  fi
}

# aie: Get a command and allow editing before executing
function aie() {
  # Get the suggested command from the Python script
  local suggestion
  suggestion=$("/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/.venv/bin/python" "/Users/jlfguthrie/dev/scripts/ghostty-terminal-dotfiles/ai/ghostty_ai.py" "$@")

  # Allow user to edit the command
  echo "Suggested command: \`$suggestion\`"
  vared -p "Edit command: " -c suggestion

  # Execute the (potentially modified) command
  eval "$suggestion"
}

# Python development
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source .venv/bin/activate'
alias pyserver='python3 -m http.server'

# Docker shortcuts with better formatting
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"'
alias dv='docker volume ls'
alias dn='docker network ls'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -f'
alias dcleanall='docker system prune -a -f'

# Docker Compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs'
alias dcr='docker-compose restart'

# Kubernetes shortcuts
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

# ============================================================================
# UTILITY FUNCTIONS - Enhanced for 2025
# ============================================================================

# Quick HTTP server with enhanced options
serve() {
  local port=${1:-8000}
  local dir=${2:-.}
  echo "🚀 Starting HTTP server on port $port in directory: $dir"
  echo "📍 URL: http://localhost:$port"
  if command -v python3 &>/dev/null; then
    cd "$dir" && python3 -m http.server "$port"
  elif command -v python &>/dev/null; then
    cd "$dir" && python -m SimpleHTTPServer "$port"
  else
    echo "❌ Python not found"
    return 1
  fi
}

# Enhanced JSON processing with error handling
json() {
  if [ -t 0 ]; then
    if [ -n "$1" ]; then
      echo "$1" | jq . 2>/dev/null || echo "$1" | python3 -m json.tool
    else
      echo "Usage: json '<json_string>' or echo 'json' | json"
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
    ps -eo comm= | sort -u | head -20
    return 1
  fi

  # Use pgrep for better process matching
  local pids
  pids=$(pgrep -if "$1")
  if [ -n "$pids" ]; then
    echo "Killing processes matching '$1':"
    pgrep -ifl "$1"
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

# Quick project initialization with templates
initproj() {
  local name=${1:-$(basename "$(pwd)")}
  local type=${2:-node}

  echo "🚀 Initializing $type project: $name"

  case $type in
  node | js | javascript)
    npm init -y
    printf "node_modules/\n*.log\n.env\n" >.gitignore
    echo "console.log('Hello, $name!');" >index.js
    ;;
  python | py)
    python3 -m venv venv
    printf "venv/\n__pycache__/\n*.pyc\n.env\n" >.gitignore
    echo "print('Hello, $name!')" >main.py
    printf "# %s\n\nA Python project.\n" "$name" >README.md
    ;;
  go)
    go mod init "$name"
    printf "# %s\n\nA Go project.\n" "$name" >README.md
    cat >main.go <<EOF
package main

import "fmt"

func main() {
    fmt.Println("Hello, $name!")
}
EOF
    ;;
  rust)
    cargo init .
    ;;
  next | nextjs)
    npx create-next-app@latest . --typescript --tailwind --eslint
    ;;
  *)
    echo "Supported types: node, python, go, rust, next"
    return 1
    ;;
  esac

  # Initialize git repository
  git init
  git add .
  git commit -m "Initial commit: $type project setup"
  echo "✅ Project '$name' initialized as $type project"
}

# Enhanced archive extraction with progress
extract() {
  if [ -f "$1" ]; then
    echo "📦 Extracting $1..."
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *.xz) xz -d "$1" ;;
    *.lzma) lzma -d "$1" ;;
    *) echo "❌ '$1' cannot be extracted via extract()" ;;
    esac
    echo "✅ Extraction complete"
  else
    echo "❌ '$1' is not a valid file"
  fi
}

# Git repository cloning with automatic directory change
gclone() {
  if [ -z "$1" ]; then
    echo "Usage: gclone <repository_url> [directory_name]"
    return 1
  fi

  local repo_url="$1"
  local dir_name="${2:-$(basename "$repo_url" .git)}"

  echo "🔄 Cloning $repo_url..."
  git clone "$repo_url" "$dir_name" && cd "$dir_name" || exit
  echo "✅ Repository cloned and entered: $(pwd)"
}

# Quick commit with automatic message generation
gquick() {
  local message="${1:-Quick update: $(date +'%Y-%m-%d %H:%M')}"
  git add -A && git commit -m "$message" && echo "✅ Quick commit: $message"
}

# Create and push new branch with upstream tracking
gnew() {
  if [ -z "$1" ]; then
    echo "Usage: gnew <branch-name>"
    return 1
  fi

  echo "🌿 Creating and pushing new branch: $1"
  git checkout -b "$1" && git push -u origin "$1"
  echo "✅ Branch '$1' created and pushed with upstream tracking"
}

# Enhanced weather function
get_weather() {
  local location=${1:-}
  curl -s "wttr.in/$location?format=3"
}

# System information display
get_sysinfo() {
  echo "🖥️  System Information"
  echo "===================="
  echo "OS: $(uname -s) $(uname -r)"
  echo "Shell: $SHELL"
  echo "Terminal: $TERM"
  echo "User: $(whoami)"
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
  echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
  if command -v free &>/dev/null; then
    echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
  fi
  echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5" used)"}')"
}

# ============================================================================
# FZF ENHANCED FUNCTIONS (if available)
# ============================================================================

if command -v fzf &>/dev/null; then
  # Enhanced directory navigation with preview
  fcd() {
    local dir
    dir=$(fd --type d 2>/dev/null | fzf --preview 'eza --tree --level=2 {} 2>/dev/null || ls -la {}' --preview-window=right:50%:wrap) && cd "$dir" || exit
  }

  # Enhanced file editing with preview
  fcode() {
    local file
    file=$(fd --type f 2>/dev/null | fzf --preview 'bat --color=always {} 2>/dev/null || cat {}' --preview-window=right:60%:wrap) && code "$file"
  }

  # Git branch switching with fzf
  fgco() {
    local branch
    branch=$(git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf --preview 'git log --oneline --graph --color=always {} | head -10') && git checkout "$branch"
  }

  # Process killer with fzf and preview
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
      echo "$pid" | xargs kill -"${1:-9}"
      echo "✅ Killed process(es): $pid"
    fi
  }

  # Docker container management
  fdocker() {
    local container action
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 | awk '{print $1}')
    if [ -n "$container" ]; then
      echo "Selected container: $container"
      echo "Available actions: exec, logs, stop, restart"
      read -r "action?Choose action: "
      case $action in
      exec) docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh ;;
      logs) docker logs -f "$container" ;;
      stop) docker stop "$container" && echo "✅ Container stopped" ;;
      restart) docker restart "$container" && echo "✅ Container restarted" ;;
      *) echo "❌ Invalid action" ;;
      esac
    fi
  }
fi

# ============================================================================
# PRODUCTIVITY SHORTCUTS
# ============================================================================

# Quick note taking
note() {
  local note_file="$HOME/quick-notes.md"
  if [ "$1" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >>"$note_file"
    echo "✅ Note added to $note_file"
  else
    code "$note_file"
  fi
}

# Quick timer function
timer() {
  local seconds=${1:-300} # Default 5 minutes
  echo "⏱️  Timer set for $seconds seconds"
  sleep "$seconds" && echo "⏰ Time's up!" && osascript -e 'display notification "Timer finished!" with title "Terminal Timer"'
}

# Password generator
genpass() {
  local length=${1:-16}
  openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# QR code generator (requires qrencode)
qr() {
  if command -v qrencode &>/dev/null; then
    echo "$1" | qrencode -t ansiutf8
  else
    echo "❌ qrencode not installed. Install with: brew install qrencode"
  fi
}

# ============================================================================
# ALIASES FOR COMMON TYPOS
# ============================================================================

alias claer='clear'
alias clera='clear'
alias clea='clear'
alias celar='clear'
alias sl='ls'
alias mdkir='mkdir'
alias mkdri='mkdir'
alias cd..='cd ..'
alias ..cd='cd ..'
alias gti='git'
alias gut='git'
alias got='git'
alias car='cat'
alias cta='cat'

# ============================================================================
# ENVIRONMENT-SPECIFIC ALIASES
# ============================================================================

# Load work-specific aliases if available
# shellcheck source=/dev/null
[[ -f ~/.aliases.work ]] && source ~/.aliases.work

# Load local machine-specific aliases if available
# shellcheck source=/dev/null
[[ -f ~/.aliases.local ]] && source ~/.aliases.local

echo "✅ Enhanced aliases loaded for Ghostty + Zsh (2025 Edition)"
git-sync() {
  git fetch --all && git pull
}

# npm/yarn shortcuts
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install --global'
alias nrs='npm run start'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrd='npm run dev'

# Docker compose
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcl='docker-compose logs'

# ============================================================================
# QUICK NAVIGATION
# ============================================================================

# Project directories
alias dev='cd ~/dev'
alias projects='cd ~/dev/projects'
alias scripts='cd ~/dev/scripts'
alias dotfiles='cd ~/dev/scripts/dotfiles-config'

# Quick access to common configuration files
alias zshconfig='code ~/.zshrc'
alias vimconfig='code ~/.vimrc'
alias p10kconfig='code ~/.p10k.zsh'

# ============================================================================
# UTILITY FUNCTIONS AS ALIASES
# ============================================================================

# Weather (using wttr.in)
alias weather='curl -4 wttr.in'

# Public IP
alias myip='curl -4 ifconfig.me && echo'
alias localip='ipconfig getifaddr en0'

# Speed test
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Memory usage
alias meminfo='free -h'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Disk usage
alias diskusage='df -h'
alias foldersize='du -sh'

# ============================================================================
# PRODUCTIVITY ALIASES
# ============================================================================

# Quick edit common files
alias hosts='sudo code /etc/hosts'
alias ssh-config='code ~/.ssh/config'

# Archive/extract shortcuts
alias tarzip='tar -czf'
alias tarunzip='tar -xzf'

# Process management
psg() {
  pgrep -afi "$@"
}
alias killall-node='killall node'
alias killall-chrome='killall "Google Chrome"'

# Network
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# ============================================================================
# GHOSTTY + VS CODE INTEGRATION
# ============================================================================

# Open current directory in different VS Code instances
alias code-here='code .'
alias code-new='code -n .'
alias code-wait='code --wait'

# Git repository shortcuts with VS Code
alias code-repo='code $(git rev-parse --show-toplevel)'
alias diff-staged='code --diff'

# ============================================================================
# MODERN TOOL INTEGRATION
# ============================================================================

# Only create these aliases if the tools are installed
if command -v bat &>/dev/null; then
  bathelp() {
    bat --plain --language=help
  }
  help() {
    "$@" --help 2>&1 | bathelp
  }
fi

if command -v fd &>/dev/null; then
  alias fdh='fd --hidden'
  alias fde='fd --extension'
fi

if command -v rg &>/dev/null; then
  alias rgi='rg --ignore-case'
  alias rgf='rg --files'
  alias rgt='rg --type'
fi

# ============================================================================
# SAFE OPERATIONS
# ============================================================================

# Safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Backup before editing important files
alias edit-hosts='sudo cp /etc/hosts /etc/hosts.backup && sudo code /etc/hosts'
alias edit-ssh='cp ~/.ssh/config ~/.ssh/config.backup && code ~/.ssh/config'

# ============================================================================
# DOCKER DEVELOPMENT
# ============================================================================

# Docker cleanup
alias docker-clean-containers='docker rm $(docker ps -a -q)'
alias docker-clean-images='docker rmi $(docker images -q)'
alias docker-clean-volumes='docker volume prune -f'
alias docker-clean-all='docker system prune -a --volumes -f'

# Docker development shortcuts
alias drun='docker run --rm -it'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'

# ============================================================================
# KUBERNETES DEVELOPMENT
# ============================================================================

# Kubectl shortcuts
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kget='kubectl get'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# Pod shortcuts
alias kpods='kubectl get pods --all-namespaces'
alias kpod='kubectl get pod'
alias klog='kubectl logs'
alias kexec='kubectl exec -it'

# ============================================================================
# PERFORMANCE MONITORING
# ============================================================================

# System monitoring
alias cpu='top -o cpu'
alias mem='top -o mem'
alias disk='df -h'

# Network monitoring
alias bandwidth='nload'
alias connections='lsof -i'
alias listening='lsof -i -P | grep LISTEN'

# ============================================================================
# BACKUP AND SYNC
# ============================================================================

# Quick backup of current directory
alias backup-here='tar -czf "backup-$(basename $(pwd))-$(date +%Y%m%d-%H%M%S).tar.gz" .'

# Sync dotfiles
alias sync-dotfiles='cd ~/dev/scripts/dotfiles-config && ./scripts/sync.sh'
