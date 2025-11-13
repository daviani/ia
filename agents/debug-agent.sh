#!/bin/bash
# Agent Debug spécialisé avec Qwen3-Coder:30B
# Usage: debug-agent.sh <fichier_avec_bug> "description du bug"

FILE="$1"
BUG_DESC="$2"

if [ -z "$FILE" ] || [ -z "$BUG_DESC" ]; then
    echo "Usage: debug-agent.sh <fichier> \"description du bug\""
    echo ""
    echo "Exemple:"
    echo "  debug-agent.sh app.py \"Erreur: IndexError: list index out of range à la ligne 42\""
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "❌ Fichier introuvable: $FILE"
    exit 1
fi

CODE=$(cat "$FILE")

PROMPT="Tu es un expert en debugging.

Bug reporté: $BUG_DESC

Code à debugger ($FILE):
\`\`\`
$CODE
\`\`\`

Analyse et fournis:
1. **Cause du bug** (ligne exacte + explication)
2. **Code fixé** (avec commentaires)
3. **Pourquoi ça buggait** (explication pédagogique)
4. **Comment éviter ce type de bug** (best practices)
5. **Tests à ajouter** pour éviter régression

Sois précis et pratique.
"

ollama run qwen3-coder:30b "$PROMPT"
