#!/bin/bash
# Agent Code Review spécialisé avec Qwen3-Coder:30B
# Usage: code-review-agent.sh <fichier_ou_diff>

TARGET="$1"

if [ -z "$TARGET" ]; then
    # Si pas de fichier, review les changements git non commités
    echo "🔍 Review des changements Git en cours..."
    DIFF=$(git diff HEAD)

    if [ -z "$DIFF" ]; then
        echo "❌ Aucun changement détecté. Utilisez: code-review-agent.sh <fichier>"
        exit 1
    fi

    PROMPT="Tu es un senior developer expert en code review.

Analyse ces changements et fournis:
1. **Qualité du code** (1-10)
2. **Bugs potentiels**
3. **Problèmes de performance**
4. **Suggestions d'amélioration**
5. **Sécurité**
6. **Lisibilité et maintenabilité**

Diff à reviewer:
\`\`\`diff
$DIFF
\`\`\`

Format: Sois constructif et précis.
"
else
    if [ ! -f "$TARGET" ]; then
        echo "❌ Fichier introuvable: $TARGET"
        exit 1
    fi

    CODE=$(cat "$TARGET")

    PROMPT="Tu es un senior developer expert en code review.

Analyse ce code et fournis:
1. **Qualité du code** (1-10)
2. **Bugs potentiels**
3. **Problèmes de performance**
4. **Suggestions d'amélioration**
5. **Sécurité**
6. **Lisibilité et maintenabilité**
7. **Tests manquants**

Code à reviewer:
\`\`\`
$CODE
\`\`\`

Sois constructif et précis.
"
fi

ollama run qwen3-coder:30b "$PROMPT"
