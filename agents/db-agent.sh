#!/bin/bash
# Agent Base de Données spécialisé avec Qwen3-Coder:30B
# Usage: db-agent.sh <schema_file> "votre question"

SCHEMA_FILE="$1"
QUESTION="$2"

if [ -z "$SCHEMA_FILE" ] || [ -z "$QUESTION" ]; then
    echo "Usage: db-agent.sh <schema_file> \"votre question\""
    echo ""
    echo "Exemple:"
    echo "  db-agent.sh schema.sql \"Comment copier des données entre deux tables avec backup?\""
    exit 1
fi

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Fichier schema introuvable: $SCHEMA_FILE"
    exit 1
fi

SCHEMA=$(cat "$SCHEMA_FILE")

PROMPT="Tu es un expert PostgreSQL/MySQL/SQL.

Schéma de la base de données:
\`\`\`sql
$SCHEMA
\`\`\`

Question: $QUESTION

Fournis:
1. La requête SQL optimale
2. Explications des choix
3. Garde-fous et gestion d'erreurs
4. Options de rollback si applicable
"

ollama run qwen3-coder:30b "$PROMPT"
