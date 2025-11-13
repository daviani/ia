#!/bin/bash
# Lance un proxy OpenAI-compatible branché sur Ollama/Qwen3
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/litellm.config.yaml"

LITELLM_BIN="$HOME/Library/Python/3.11/bin/litellm"

if ! test -f "$LITELLM_BIN"; then
  echo "❌ litellm n'est pas installé pour Python 3.11. Installez-le avec '/opt/homebrew/bin/python3.11 -m pip install --user \"litellm[proxy]\"'."
  exit 1
fi

echo "🚀 Démarrage LiteLLM (proxy OpenAI) sur http://127.0.0.1:4000/v1"
echo "   Config: $CONFIG_FILE"

"$LITELLM_BIN" --config "$CONFIG_FILE" --host 127.0.0.1 --port 4000
