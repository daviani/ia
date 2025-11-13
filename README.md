# 🤖 Guide Complet - IA Locale avec Qwen3-Coder:30B

**Configuration :** M3 Pro 36GB RAM | **Modèle :** Qwen3-Coder:30B (local, gratuit, privé) | **Shell :** Fish | **Date :** 2025-11-10

---

## 🆕 Utilisation comme dépôt Git

1. **Cloner ou initialiser**
   ```bash
   git clone <votre_repo> ~/LLM   # ou: mkdir ~/LLM && cd ~/LLM && git init
   cd ~/LLM
   ```
2. **Configurer les liens et dossiers**
   ```bash
   bash bootstrap.sh
   exec fish
   ```
3. **Installer les dépendances Python (avec réseau)**
   ```bash
   python3 -m pip install --user --upgrade litellm mcp modelcontextprotocol huggingface_hub
   python3.11 -m pip install --user --upgrade mcp modelcontextprotocol  # si vous utilisez Homebrew Python
   ```
4. **Tester la pile MCP**
   ```bash
   cd mcp
   ./test-mcp.sh
   ./test-interactive.sh
   ```
5. **Lancer la stack**
   ```bash
   qwen-mcp                         # alias conseillé dans ~/.config/fish/config.fish
   agents                           # menu interactif des scripts IA
   ```

📅 Consultez `ROADMAP.md` pour connaître les prochaines étapes (support multi-MCP, intégration des agents, packaging multi-machine).

---

## 📋 Table des matières

- [Utilisation comme dépôt Git](#-utilisation-comme-dépôt-git)
- [Démarrage ultra-rapide](#démarrage-ultra-rapide)
- [Structure du dossier](#structure-du-dossier)
- [Agents disponibles](#agents-disponibles)
- [Fonctions Fish existantes](#fonctions-fish-existantes)
- [Aider (modifications de code)](#aider)
- [Continue.dev (IDE)](#continuedev)
- [Workflows](#workflows)
- [Configuration](#configuration)
- [Dépannage](#dépannage)
- [Roadmap](#-roadmap)

---

## ⚡ Démarrage ultra-rapide

```fish
# 1. Recharger Fish (une seule fois)
exec fish

# 2. Utiliser
agents                                    # Menu interactif
git-agent.sh "question"                   # Agent Git
security-agent.sh ./projet                # Audit sécurité
code-review-agent.sh fichier.js           # Review de code

# 3. Ou utiliser vos fonctions Fish existantes
ask "question rapide"                     # Question simple
gen-tests fichier.js                      # Générer des tests
```

---

## 📂 Structure du dossier

```
~/LLM/
├── README.md               → Ce guide complet
├── agents/                 → 7 scripts d'agents IA
├── aider/                  → Config + état d'Aider
│   ├── aider.conf.yml      → Thème & options dev
│   ├── model-settings.yml  → Paramètres avancés (num_ctx, t°)
│   └── state/              → Cache Aider (ancien ~/.aider)
├── ollama/                 → Modèles, logs & clés Ollama
└── qwen/                   → Notes & profils Qwen3
```

**Liens symboliques automatiques :**
- `~/.aider.conf.yml` → `~/LLM/aider/aider.conf.yml`
- `~/.aider.model.settings.yml` → `~/LLM/aider/model-settings.yml`
- `~/.aider` → `~/LLM/aider/state`
- `~/.ollama` → `~/LLM/ollama`

➡️ Toute la stack locale (Ollama, Qwen3, Aider) vit maintenant sous `~/LLM`, ce qui facilite les sauvegardes ou la synchronisation iCloud/Time Machine.

---

## 🤖 Agents disponibles

### 1. git-agent.sh - Expert Git
```fish
git-agent.sh "Comment annuler mon dernier commit ?"
git-agent.sh "Différence entre merge et rebase ?"
```

### 2. security-agent.sh - Audit de sécurité
```fish
security-agent.sh fichier.js       # Fichier
security-agent.sh ./src            # Dossier
security-agent.sh .                # Projet
```
Détecte : Injections SQL, XSS, CSRF, credentials exposés

### 3. db-agent.sh - Expert SQL/PostgreSQL
```fish
psql mydb -c "\d+ users" > schema.sql
db-agent.sh schema.sql "Crée une procédure de migration avec rollback"
```

### 4. code-review-agent.sh - Review de code
```fish
code-review-agent.sh app.js        # Fichier
code-review-agent.sh               # Changements git
```

### 5. refactor-agent.sh - Refactoring
```fish
refactor-agent.sh app.py "Réduire complexité cyclomatique"
refactor-agent.sh utils.js "Appliquer SOLID"
```

### 6. debug-agent.sh - Debugging
```fish
debug-agent.sh app.js "TypeError ligne 42"
```

### 7. agent-manager.sh - Menu interactif
```fish
agents                             # Alias
# ou
agent-manager.sh
```

---

## 🐟 Fonctions Fish existantes

Vous aviez déjà d'excellentes fonctions dans `~/.config/fish/config.fish` :

### Fonctions disponibles

```fish
ask "question"                     # Question rapide à Qwen3
ai                                 # Session interactive Qwen3
qwen                               # Alias de 'ai'
code-review fichier                # Review basique
gen-tests fichier                  # Générer des tests
explain-code fichier               # Expliquer du code
```

### Quand utiliser quoi ?

| Besoin | Fonction Fish | Agent |
|--------|--------------|--------|
| Question rapide | ✅ `ask "question"` | - |
| Review basique | `code-review` | ✅ `code-review-agent.sh` (plus détaillé) |
| Tests | ✅ `gen-tests` | - |
| Explications | ✅ `explain-code` | - |
| Questions Git | - | ✅ `git-agent.sh` |
| Audit sécurité | - | ✅ `security-agent.sh` |
| SQL/DB | - | ✅ `db-agent.sh` |
| Debug | - | ✅ `debug-agent.sh` |
| Refactoring | - | ✅ `refactor-agent.sh` |

**Les deux sont complémentaires !**

---

## 🔧 Aider

Outil CLI pour modifier du code avec IA.

### Utilisation

```fish
cd projet
aider fichier.js                   # Éditer un fichier
aider --read doc.md src/app.js     # Avec contexte read-only
```

### Commandes Aider

```
/add fichier.js      → Ajouter un fichier
/read fichier.md     → Contexte read-only
/ls                  → Lister fichiers
/exit                → Quitter
```

### Exemples

```
> Crée une API REST pour gérer des utilisateurs avec validation
> Corrige le bug TypeError ligne 42 dans app.js
> Refactorise utils.js : applique DRY et ajoute gestion erreurs
> Génère des tests Jest pour user.service.js
```

---

## 💻 Continue.dev

Extension IDE pour autocomplétion et chat.

### Installation

```fish
code --install-extension continue.continue    # VS Code
brew install --cask cursor                    # Cursor (intégré)
```

### Raccourcis

- `Cmd+L` : Chat
- `Cmd+I` : Édition inline
- `Tab` : Accepter autocomplétion

**Déjà configuré** dans `~/.continue/config.json` pour utiliser Qwen3-Coder:30B

---

## 🎯 Workflows

### Workflow 1 : Développement feature

```fish
# 1. Question rapide
ask "Comment implémenter un WebSocket ?"

# 2. Créer avec Aider
aider src/websocket.js
> Implémente un serveur WebSocket avec reconnexion

# 3. Review détaillée
code-review-agent.sh src/websocket.js

# 4. Audit sécurité
security-agent.sh src/websocket.js

# 5. Tests
gen-tests src/websocket.js

# 6. Commit
git commit -m "feat: add WebSocket server"
```

### Workflow 2 : Debugging

```fish
# 1. Identifier
debug-agent.sh app.js "TypeError ligne 42"

# 2. Fix
aider app.js
> Applique le fix suggéré

# 3. Vérifier
code-review-agent.sh app.js
```

### Workflow 3 : Audit sécurité

```fish
# 1. Scan
security-agent.sh .

# 2. Fix
aider vulnerable.js
> Corrige les vulnérabilités détectées

# 3. Re-vérifier
security-agent.sh vulnerable.js
```

---

## ⚙️ Configuration

### Fish (`~/.config/fish/config.fish`)

**Ajouté :**
```fish
fish_add_path -g ~/LLM/agents
alias agents='agent-manager.sh'
```

**Déjà présent (vos fonctions) :**
```fish
# Fonctions Ollama
function ask
function code-review
function gen-tests
function explain-code

# Alias
alias ai='ollama run qwen3-coder:30b'
alias qwen='ollama run qwen3-coder:30b'
```

### Aider (`~/LLM/aider/aider.conf.yml`)

```yaml
model: ollama_chat/qwen3-coder:30b
git: true
auto-commits: false
dirty-commits: false
dark-mode: false
watch-files: true
show-diffs: true
map-tokens: 2048
code-theme: nord
suggest-shell-commands: true
analytics: false
```

➡️ Thème Nord appliqué aux entrées/sorties + menu de complétion, et `commit-prompt` impose un message au format *conventional commit*. Important : laissez `dark-mode: false`, sinon Aider réécrit vos couleurs avec son profil fluo.

**`model-settings.yml`**

```yaml
- name: ollama_chat/qwen3-coder:30b
  extra_params:
    num_ctx: 131072
```

➡️ C'est ce fichier (lié à `~/.aider.model.settings.yml`) qui transmet vraiment `num_ctx` à Ollama. N'y mettez que les options spécifiques au modèle (température, keep_alive, etc.).

### Qwen & Ollama (`~/LLM/qwen`, `~/LLM/ollama`)

- `~/LLM/ollama` contient désormais tout ce qui se trouvait dans `~/.ollama` (modèles, clés SSH, logs). Le lien symbolique garantit que `ollama run …` continue à fonctionner.
- `~/LLM/qwen/Modelfile` propose un profil `qwen3-coder-dev` (température 0.2 + prompt système). Construisez-le avec `ollama create qwen3-coder-dev -f ~/LLM/qwen/Modelfile`.
- `~/LLM/qwen/system-prompt.md` vous sert de bloc-notes pour vos instructions maison : copiez-le dans vos `Modelfile` ou collez-le dans Aider/agents.

> Astuce : pensez à exclure `~/LLM/ollama/models` d’iCloud/Dropbox si l’espace est compté, mais gardez le reste pour pouvoir restaurer rapidement votre stack.

### Continue.dev (`~/.continue/config.json`)

```json
{
  "models": [{
    "provider": "ollama",
    "model": "qwen3-coder:30b",
    "apiBase": "http://localhost:11434"
  }]
}
```

---

## 🆘 Dépannage

### "command not found: git-agent.sh"

```fish
exec fish                          # Recharger Fish
```

### "Failed to connect to ollama"

```fish
ollama serve                       # Démarrer Ollama
```

### Agents lents

```fish
ollama list                        # Vérifier Ollama
top                                # Vérifier charge CPU
```

### Aider ne démarre pas

```fish
cat ~/LLM/aider/aider.conf.yml    # Vérifier config
ollama run qwen3-coder:30b "test" # Tester Ollama
pip install --upgrade aider-chat  # Réinstaller
```

---

## 📊 Comparaison alternatives

| | Votre Setup | Copilot | ChatGPT | Cursor |
|---|---|---|---|---|
| **Coût** | Gratuit | $10/mois | $20/mois | $20/mois |
| **Vitesse** | 3-15s | Instant | 10-30s | 5-20s |
| **Privé** | ✅ 100% | ❌ Cloud | ❌ Cloud | ❌ Cloud |
| **Context** | 262K | ~8K | 128K | ~128K |
| **Offline** | ✅ | ❌ | ❌ | ❌ |

**Économies : ~$240-600/an**

---

## 🗑️ Désinstallation

```fish
rm -rf ~/LLM
rm ~/.aider.conf.yml ~/.aider ~/.ollama
# Éditer ~/.config/fish/config.fish : supprimer les 2 lignes agents
exec fish
```

---

## 📅 Roadmap

### v0.1 – Initialisation (✅ en cours)
- [x] Documenter la stack locale (README principal).
- [x] Script `bootstrap.sh` pour créer les symlinks nécessaires.
- [x] Ajout du proxy LiteLLM + host MCP (`~/LLM/mcp`).

### v0.2 – MCP étendu (🔜)
- [ ] Support natif de plusieurs serveurs MCP (`--extra-server` prêts à l'emploi : git, navigateur, HTTP).
- [ ] Tests automatisés (`test-mcp.sh`, `test-interactive.sh`) intégrés dans un workflow CI.
- [ ] Normalisation des prompts système (fichier unique partagé entre Aider, agents et MCP).

### v0.3 – Agents unifiés (🧪 conception)
- [ ] Convertir les agents Bash (`agents/*.sh`) en serveurs MCP dédiés pour pouvoir les invoquer automatiquement.
- [ ] Ajouter une bibliothèque de prompts/recettes partagée (styles de commit, revues, etc.).
- [ ] Fournir une interface TUI/CLI unique (menu) pour démarrer Aider, MCP, tests.

### v0.4 – Distribution multi-machine (📦)
- [ ] Script d’installation complet (brew/pip) + vérifications Ollama.
- [ ] Gabarit de configuration Fish (alias `qwen-mcp`, fonctions, TMPDIR).
- [ ] Export/backup simplifié (`make package` ou script tar) pour déplacer la stack.

---

## 💡 Alias recommandés

Ajoutez dans `~/.config/fish/config.fish` :

```fish
alias sec='security-agent.sh'
alias review='code-review-agent.sh'
alias fix='debug-agent.sh'
alias githelp='git-agent.sh'
```

---

## ✅ Checklist

```fish
ollama list                        # ✅ qwen3-coder:30b présent
git-agent.sh "test"                # ✅ Réponse reçue
aider --version                    # ✅ aider 0.82.3
agents                             # ✅ Menu s'ouvre
```

---

**Vous avez :**
- ✅ 7 agents spécialisés
- ✅ Fonctions Fish rapides
- ✅ Aider pour modifier du code
- ✅ Continue.dev pour IDE
- ✅ Tout local, gratuit, privé

**Total : 68 KB | Modèle : Qwen3-Coder:30B | Config : M3 Pro 36GB**
