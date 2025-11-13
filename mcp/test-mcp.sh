#!/bin/bash
# Script de test pour la pile MCP
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/litellm.config.yaml"
LITELLM_HOST="127.0.0.1"
LITELLM_PORT="4000"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LITELLM_LOG="$LOG_DIR/litellm-test.log"

echo "🧪 Test de la pile MCP..."

# Vérifier qu'Ollama tourne
if ! curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "❌ Ollama n'est pas accessible sur http://127.0.0.1:11434"
    exit 1
fi
echo "✅ Ollama est accessible"

# Démarrer LiteLLM
echo "🚀 Démarrage de LiteLLM (log: $LITELLM_LOG)"
python3.11 -m pip show litellm >/dev/null 2>&1 || {
    echo "❌ litellm n'est pas installé pour Python 3.11"
    exit 1
}

~/Library/Python/3.11/bin/litellm --config "$CONFIG_FILE" --host "$LITELLM_HOST" --port "$LITELLM_PORT" >"$LITELLM_LOG" 2>&1 &
LITELLM_PID=$!

cleanup() {
    echo ""
    echo "🧹 Nettoyage..."
    kill $LITELLM_PID >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

# Attendre que LiteLLM démarre
echo "⏳ Attente du démarrage de LiteLLM..."
sleep 3

# Vérifier que LiteLLM répond
if curl -s http://${LITELLM_HOST}:${LITELLM_PORT}/health >/dev/null 2>&1; then
    echo "✅ LiteLLM est opérationnel sur http://${LITELLM_HOST}:${LITELLM_PORT}"
else
    echo "❌ LiteLLM ne répond pas"
    echo "📋 Dernières lignes du log:"
    tail -20 "$LITELLM_LOG"
    exit 1
fi

# Vérifier que python3.11 peut importer mcp
if ! python3.11 -c "import mcp; print('mcp version OK')" 2>/dev/null; then
    echo "❌ Le module mcp n'est pas accessible pour Python 3.11"
    exit 1
fi
echo "✅ Module mcp importable"

# Vérifier que python3.11 peut importer huggingface_hub
if ! python3.11 -c "from huggingface_hub.inference._mcp.agent import Agent; print('Agent OK')" 2>/dev/null; then
    echo "❌ Le module huggingface_hub.inference._mcp.agent n'est pas accessible"
    exit 1
fi
echo "✅ Module huggingface_hub.Agent importable"

echo ""
echo "✨ Tous les tests sont passés avec succès !"
echo ""
echo "Pour lancer l'interface interactive, utilisez :"
echo "  cd ~/LLM/mcp && ./start-qwen-mcp.sh --root ~/Dev"
echo "ou simplement (avec l'alias Fish) :"
echo "  qwen-mcp"
