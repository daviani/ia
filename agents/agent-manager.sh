#!/bin/bash
# Gestionnaire d'agents - Menu interactif

show_menu() {
    echo ""
    echo "🤖 GESTIONNAIRE D'AGENTS QWEN3-CODER"
    echo "===================================="
    echo ""
    echo "Agents disponibles:"
    echo "  1) git-agent         - Questions Git"
    echo "  2) security-agent    - Audit de sécurité"
    echo "  3) db-agent          - Expert SQL/PostgreSQL"
    echo "  4) code-review-agent - Review de code"
    echo "  5) refactor-agent    - Refactoring"
    echo "  6) debug-agent       - Debugging"
    echo ""
    echo "  7) Lancer Aider"
    echo "  8) Tester Qwen3-Coder"
    echo "  9) Documentation complète"
    echo "  0) Quitter"
    echo ""
}

while true; do
    show_menu
    read -p "Choisissez une option: " choice

    case $choice in
        1)
            read -p "Question Git: " question
            git-agent.sh "$question"
            ;;
        2)
            read -p "Fichier ou dossier à analyser [.]: " target
            target=${target:-.}
            security-agent.sh "$target"
            ;;
        3)
            read -p "Fichier schema SQL: " schema
            read -p "Question: " question
            if [ -f "$schema" ]; then
                db-agent.sh "$schema" "$question"
            else
                echo "❌ Fichier schema introuvable: $schema"
            fi
            ;;
        4)
            read -p "Fichier à reviewer (vide = changements git): " file
            code-review-agent.sh "$file"
            ;;
        5)
            read -p "Fichier à refactorer: " file
            read -p "Objectif du refactoring: " goal
            if [ -f "$file" ]; then
                refactor-agent.sh "$file" "$goal"
            else
                echo "❌ Fichier introuvable: $file"
            fi
            ;;
        6)
            read -p "Fichier avec bug: " file
            read -p "Description du bug: " bug
            if [ -f "$file" ]; then
                debug-agent.sh "$file" "$bug"
            else
                echo "❌ Fichier introuvable: $file"
            fi
            ;;
        7)
            echo "Lancement d'Aider..."
            aider
            ;;
        8)
            echo "Test de Qwen3-Coder:30B..."
            ollama run qwen3-coder:30b "Écris une fonction JavaScript qui vérifie si un nombre est premier."
            ;;
        9)
            if [ -f ~/GUIDE_AIDER_CONTINUE.md ]; then
                cat ~/GUIDE_AIDER_CONTINUE.md | less
            else
                echo "Documentation non trouvée"
            fi
            ;;
        0)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "❌ Option invalide"
            ;;
    esac

    read -p "Appuyez sur Entrée pour continuer..."
done
