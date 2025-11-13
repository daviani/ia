#!/bin/bash
# Test interactif automatisé pour la pile MCP
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Test de l'interface MCP interactive..."
echo ""
echo "Ce test va lancer le host MCP et lui envoyer une commande simple."
echo "Le test devrait durer environ 10 secondes."
echo ""

# Créer un fichier temporaire avec la commande à tester
COMMAND_FILE=$(mktemp)
echo "Liste-moi les fichiers dans le répertoire courant" > "$COMMAND_FILE"
echo "exit" >> "$COMMAND_FILE"

cleanup() {
    rm -f "$COMMAND_FILE"
}
trap cleanup EXIT

echo "▶️  Lancement du host MCP..."
echo ""

# Lancer le script avec timeout et redirection d'entrée
timeout 15s "$SCRIPT_DIR/start-qwen-mcp.sh" --root ~/Dev < "$COMMAND_FILE" || {
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
        echo ""
        echo "⏱️  Timeout atteint (normal pour ce test)"
    else
        echo ""
        echo "❌ Le script s'est terminé avec le code $EXIT_CODE"
        exit $EXIT_CODE
    fi
}

echo ""
echo "✨ Si vous avez vu le prompt 'mcp>' et une réponse du modèle, le test est réussi !"
echo ""
echo "Pour utiliser l'interface de manière interactive :"
echo "  qwen-mcp"
echo "ou :"
echo "  cd ~/LLM/mcp && ./start-qwen-mcp.sh --root ~/Dev"
