#!/usr/bin/env bash
# ==============================================================================
# scripts/download-smollm.sh
#
# Download SmolLM2 quantized GGUF models for local in-process inference in
# vyapaar CLI & TUI tools.
#
# Usage:
#   ./scripts/download-smollm.sh [360m|1.7b] [output_dir]
#
# Default:
#   360m (~230MB, SmolLM2-360M-Instruct-Q4_K_M.gguf) into ./models/
# ==============================================================================

set -euo pipefail

MODEL_SIZE="${1:-360m}"
TARGET_DIR="${2:-models}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$REPO_ROOT/$TARGET_DIR"

case "${MODEL_SIZE,,}" in
    360m|360M)
        MODEL_NAME="SmolLM2-360M-Instruct-Q4_K_M.gguf"
        DOWNLOAD_URL="https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf"
        ;;
    1.7b|1.7B)
        MODEL_NAME="SmolLM2-1.7B-Instruct-Q4_K_M.gguf"
        DOWNLOAD_URL="https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-GGUF/resolve/main/SmolLM2-1.7B-Instruct-Q4_K_M.gguf"
        ;;
    q8|360m-q8)
        MODEL_NAME="smollm2-360m-instruct-q8_0.gguf"
        DOWNLOAD_URL="https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct-GGUF/resolve/main/smollm2-360m-instruct-q8_0.gguf"
        ;;
    *)
        echo "Unknown model size: $MODEL_SIZE. Choose '360m' (default), '1.7b', or 'q8'."
        exit 1
        ;;
esac

DEST_PATH="$REPO_ROOT/$TARGET_DIR/$MODEL_NAME"

if [ -f "$DEST_PATH" ]; then
    echo "✓ Model file already exists at: $DEST_PATH"
else
    echo "==> Downloading $MODEL_NAME to $DEST_PATH..."
    if command -v curl &>/dev/null; then
        curl -L --progress-bar -f -o "$DEST_PATH" "$DOWNLOAD_URL"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$DEST_PATH" "$DOWNLOAD_URL"
    else
        echo "Error: Neither curl nor wget was found in PATH."
        exit 1
    fi
    echo "✓ Download complete: $DEST_PATH"
fi

echo ""
echo "=== How to run with vyapaar ==="
echo "1. Set environment variable:"
echo "   export VYAPAAR_GGUF_PATH=\"$DEST_PATH\""
echo ""
echo "2. Or pass --model-path explicitly:"
echo "   cargo run -p vyapaar-cli -- ask \"What is a stop loss?\" --model-path \"$DEST_PATH\""
echo "   cargo run -p vyapaar-cli -- chat --model-path \"$DEST_PATH\""
echo "   cargo run -p vyapaar-cli -- tui --model-path \"$DEST_PATH\""
