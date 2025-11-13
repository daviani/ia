#!/bin/bash
# Configure les liens symboliques et dossiers nécessaires pour utiliser cette stack IA sur une nouvelle machine.
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔗 Création/actualisation des liens symboliques..."
ln -sf "$BASE_DIR/aider/aider.conf.yml" "$HOME/.aider.conf.yml"
ln -sf "$BASE_DIR/aider/model-settings.yml" "$HOME/.aider.model.settings.yml"
ln -sf "$BASE_DIR/aider/state" "$HOME/.aider"
ln -sf "$BASE_DIR/ollama" "$HOME/.ollama"

echo "📁 Préparation des dossiers temporaires..."
mkdir -p "$HOME/tmp"

cat <<'MSG'
✅ Configuration terminée.
- Relancez votre shell (ex: 'exec fish').
- Assurez-vous qu'Ollama est démarré et que le modèle qwen3-coder:30b est téléchargé.
- Pour la pile MCP : cd ~/LLM/mcp && ./start-qwen-mcp.sh --root ~/Dev
MSG
