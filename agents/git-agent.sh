#!/bin/bash
# Agent Git spécialisé avec Qwen3-Coder:30B
# Usage: git-agent.sh "votre question git"

PROMPT="Tu es un expert Git. Tu m'aides avec :
- Résolution de conflits
- Gestion de branches
- Historique et rebase
- Stratégies de merge
- Git hooks et workflows
- Récupération de commits perdus
- Git bisect pour debugging

Réponds de manière concise et fournis des commandes prêtes à l'emploi.

Question: $1"

ollama run qwen3-coder:30b "$PROMPT"
