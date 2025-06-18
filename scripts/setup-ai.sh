#!/usr/bin/env bash
# Setup script for Ghostty AI helper

set -e

echo "🚀 Setting up Ghostty AI helper..."

# Check if ollama is installed
if ! command -v ollama &>/dev/null; then
  echo "📦 Installing Ollama..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &>/dev/null; then
      brew install ollama
    else
      echo "❌ Homebrew not found. Please install Ollama manually from https://ollama.ai"
      exit 1
    fi
  else
    echo "❌ Please install Ollama manually from https://ollama.ai"
    exit 1
  fi
fi

# Install Python package
echo "🐍 Installing Python ollama package..."
if command -v pip3 &>/dev/null; then
  echo "Using pip3 with --user flag for safe user-level installation..."
  pip3 install --user --break-system-packages ollama
elif command -v pip &>/dev/null; then
  echo "Using pip with --user flag for safe user-level installation..."
  pip install --user --break-system-packages ollama
else
  echo "❌ No pip found. Please install Python pip first."
  exit 1
fi

# Check if ollama is already running
if ollama list &>/dev/null; then
  echo "✅ Ollama service is already running"
else
  echo "🔄 Starting Ollama service..."
  ollama serve &
  OLLAMA_PID=$!

  # Wait a moment for service to start
  echo "⏳ Waiting for Ollama service to start..."
  sleep 5

  # Verify service started
  if ! ollama list &>/dev/null; then
    echo "❌ Failed to start Ollama service"
    exit 1
  fi
fi

# Check if we already have a suitable fast model
echo "🔍 Checking for available models..."
if ollama list | grep -q "phi3:mini"; then
  echo "✅ phi3:mini model already available"
elif ollama list | grep -q "qwen3:4b"; then
  echo "✅ Found qwen3:4b model - this will work great!"
  echo "� Setting OLLAMA_MODEL=qwen3:4b-q8_0 for optimal performance"
  export OLLAMA_MODEL="qwen3:4b-q8_0"
else
  echo "�� Downloading phi3:mini model (this may take a few minutes)..."
  if ! ollama pull phi3:mini; then
    echo "❌ Failed to download phi3:mini. You can manually download it later with:"
    echo "   ollama pull phi3:mini"
    echo "   or use an existing model by setting OLLAMA_MODEL environment variable"
  fi
fi

echo "✅ Setup complete!"
echo ""
echo "Usage examples:"
echo "  python3 ../ai/ghostty_ai.py list all files modified today"
echo "  python3 ../ai/ghostty_ai.py find large files over 100MB"
echo "  python3 ../ai/ghostty_ai.py show git status with colors"
echo ""
echo "💡 To use a different model, set OLLAMA_MODEL environment variable:"
echo "  export OLLAMA_MODEL='qwen3:8b-q4_k_m'  # Use your existing model"
echo "  export OLLAMA_MODEL='llama3:8b'        # If you want to download a new one"
echo ""
echo "🎯 Your available models:"
ollama list
