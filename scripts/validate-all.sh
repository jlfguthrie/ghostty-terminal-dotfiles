#!/bin/bash
# Validate all configuration files in the ghostty-terminal-dotfiles project

set -e

echo "🔍 Validating configurations..."

# Validate shell scripts syntax
echo "Checking shell scripts..."
bash -n install.sh
bash -n scripts/*.sh
echo "✅ Shell scripts syntax OK"

# Validate VS Code settings (JSONC format)
echo "Checking VS Code settings..."
python3 -c "
import json
import re
with open('vscode/settings.json', 'r') as f:
    content = f.read()
# Remove single-line comments
content_no_comments = re.sub(r'//.*', '', content)
json.loads(content_no_comments)
"
echo "✅ VS Code settings OK"

# Validate Ghostty configuration
echo "Checking Ghostty config..."
if command -v ghostty >/dev/null 2>&1; then
  ghostty +validate-config --config-file=./ghostty/config >/dev/null
elif [ -x "/Applications/Ghostty.app/Contents/MacOS/ghostty" ]; then
  /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file=./ghostty/config >/dev/null
else
  echo "⚠️  Ghostty not found - skipping config validation"
  exit 0
fi
echo "✅ Ghostty config OK"

echo "🎉 All validations passed!"
