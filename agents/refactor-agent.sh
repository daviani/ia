#!/bin/bash
# Agent Refactoring spécialisé avec Qwen3-Coder:30B
# Usage: refactor-agent.sh <fichier> "objectif du refactoring"

FILE="$1"
GOAL="${2:-Améliorer la qualité du code}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: refactor-agent.sh <fichier> \"objectif\""
    echo ""
    echo "Exemples:"
    echo "  refactor-agent.sh app.js \"Réduire la complexité cyclomatique\""
    echo "  refactor-agent.sh utils.py \"Appliquer les principes SOLID\""
    exit 1
fi

CODE=$(cat "$FILE")
EXTENSION="${FILE##*.}"

PROMPT="Tu es un expert en refactoring et clean code.

Objectif: $GOAL

Code actuel ($FILE):
\`\`\`$EXTENSION
$CODE
\`\`\`

Fournis:
1. **Analyse du code actuel** (problèmes, code smells)
2. **Code refactoré** (complet, prêt à copier-coller)
3. **Explications des changements**
4. **Bénéfices** (lisibilité, performance, maintenabilité)
5. **Tests à ajouter/modifier**

Principes à respecter:
- DRY (Don't Repeat Yourself)
- SOLID
- Clean Code
- Performance
"

ollama run qwen3-coder:30b "$PROMPT"
