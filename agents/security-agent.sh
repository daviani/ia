#!/bin/bash
# Agent Sécurité spécialisé avec Qwen3-Coder:30B
# Usage: security-agent.sh <fichier_ou_dossier>

TARGET="${1:-.}"

echo "🔍 Analyse de sécurité en cours sur: $TARGET"
echo ""

# Si c'est un fichier, l'analyser directement
if [ -f "$TARGET" ]; then
    CONTENT=$(cat "$TARGET")
    PROMPT="Tu es un expert en sécurité applicative (OWASP Top 10, CVE, etc.).

Analyse ce code pour détecter :
- Injections SQL
- XSS (Cross-Site Scripting)
- CSRF
- Authentification faible
- Exposition de secrets/credentials
- Injection de commandes
- Path traversal
- Désérialisation non sécurisée
- Dépendances vulnérables
- Mauvaises configurations

Code à analyser:
\`\`\`
$CONTENT
\`\`\`

Format de réponse :
1. Vulnérabilités trouvées (severity: CRITICAL/HIGH/MEDIUM/LOW)
2. Lignes concernées
3. Recommandations de fix
"
    ollama run qwen3-coder:30b "$PROMPT"

# Si c'est un dossier, scanner les fichiers sensibles
elif [ -d "$TARGET" ]; then
    PROMPT="Tu es un expert en sécurité applicative.

Analyse ce projet pour détecter :
- Fichiers de configuration exposés (.env, credentials, keys)
- Patterns de code vulnérables
- Dépendances obsolètes
- Permissions incorrectes

Fichiers trouvés :
$(find "$TARGET" -type f \( -name "*.env*" -o -name "*secret*" -o -name "*credential*" -o -name "*password*" -o -name "*.key" -o -name "*.pem" \) 2>/dev/null | head -20)

Structure du projet :
$(tree -L 2 "$TARGET" 2>/dev/null || ls -la "$TARGET")

Fournis un rapport de sécurité avec priorités.
"
    ollama run qwen3-coder:30b "$PROMPT"
else
    echo "❌ Cible invalide: $TARGET"
    exit 1
fi
