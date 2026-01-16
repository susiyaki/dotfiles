#!/usr/bin/env bash
# Setup Whisper model for Speak to AI
# Downloads the required Whisper model if not already present

set -euo pipefail

MODEL_DIR="$HOME/.local/share/speak-to-ai/models"
MODEL_NAME="ggml-medium-q5_0.bin"
MODEL_PATH="$MODEL_DIR/$MODEL_NAME"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL_NAME"

echo "=== Whisper Model Setup for Speak to AI ==="
echo ""

# Create model directory
mkdir -p "$MODEL_DIR"

# Check if model already exists
if [ -f "$MODEL_PATH" ]; then
    echo "✓ Model already exists at: $MODEL_PATH"
    MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
    echo "  Size: $MODEL_SIZE"
    exit 0
fi

echo "Downloading Whisper model: $MODEL_NAME"
echo "Source: $MODEL_URL"
echo "Target: $MODEL_PATH"
echo ""
echo "This will download approximately 540 MB..."
echo "The medium model provides better accuracy for technical terms."
echo ""

# Download with progress
if command -v curl >/dev/null 2>&1; then
    curl -L --progress-bar -o "$MODEL_PATH" "$MODEL_URL"
elif command -v wget >/dev/null 2>&1; then
    wget --show-progress -O "$MODEL_PATH" "$MODEL_URL"
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo ""
echo "✓ Model downloaded successfully!"
echo "  Location: $MODEL_PATH"

# Verify file size (should be around 540 MB)
MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
echo "  Size: $MODEL_SIZE"

echo ""
echo "=== Setup Complete ==="
echo "You can now use Speak to AI with: $super+Shift+v"
