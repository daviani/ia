# MCP + Qwen3 via Ollama

Ce dossier prépare l'intégration **Model Context Protocol (MCP)** pour votre stack locale :

1. **LiteLLM proxy** transforme Ollama en endpoint OpenAI-compatible.
2. **Host MCP Python** s'appuie sur le SDK `modelcontextprotocol` pour consommer des serveurs MCP (filesystem, git, etc.) et délègue les réponses à Qwen3 via le proxy.

## Structure

```
LLM/mcp/
├── README.md                 ← ce guide
├── litellm.config.yaml       ← mapping Ollama ↔ LiteLLM
├── start-litellm.sh          ← lance le proxy OpenAI-compatible
└── qwen_mcp_host.py          ← petit host MCP (WIP sans dépendances)
```

## Prérequis

- Ollama en cours d'exécution avec le modèle `qwen3-coder:30b` (cf. `~/LLM/README.md`).
- Python 3.9+ avec `litellm` (déjà présent via Aider) et **accès réseau temporaire** pour installer le SDK MCP (`mcp` + `modelcontextprotocol`). \
  *Dans cet environnement hors-ligne, l'installation échoue (`pip` ne peut pas résoudre `pypi.org`). Dès que vous retrouvez Internet, exécutez :*

```bash
python3 -m pip install --user "mcp>=1.2.0" "modelcontextprotocol>=0.1.0"
```

## Étapes

### 1. Démarrer le proxy LiteLLM

```bash
cd ~/LLM/mcp
./start-litellm.sh
```

Cela expose une API OpenAI-compatible sur `http://127.0.0.1:4000/v1` pointant vers `qwen3-coder:30b` avec `num_ctx=131072`.

### 2. Lancer le host MCP

```bash
python3 qwen_mcp_host.py \
  --filesystem-root ~/Dev \
  --model qwen3-dev \
  --litellm-url http://127.0.0.1:4000/v1 \
  --api-key dummy-key
```

- `--filesystem-root` : chemin exposé via le serveur MCP filesystem (lecture/écriture locale). \
- `--model` : alias LiteLLM défini dans `litellm.config.yaml`. \
- `--litellm-url` / `--api-key` : identifiants utilisés par le SDK pour parler au proxy (mettez la même clé que `general_settings.master_key`). \
- `--extra-server` : ajoutez autant d'autres serveurs MCP que voulu (`--extra-server 'stdio::npx -y @modelcontextprotocol/server-git'`).

### 3. Consommer les ressources MCP

Une fois le host démarré, il agit comme **client** : il interroge les serveurs MCP, récupère les `resources/tools` puis formate les requêtes vers le modèle. Vous pouvez l’étendre pour :

- empiler plusieurs serveurs (filesystem + `--extra-server …`),
- exposer une API REST locale ou un TUI,
- connecter un IDE (Continue, VS Code) en pointant vers le proxy LiteLLM.

## Limites actuelles

- `modelcontextprotocol` n’est pas installable hors-ligne ⇒ le script `qwen_mcp_host.py` ne peut pas encore tourner ; il est fourni comme squelette prêt à l’emploi.
- Le serveur MCP utilisé en exemple est `filesystem`. Ajoutez vos propres serveurs MCP (binaires ou scripts) et adaptez le parseur de paramètres dans `qwen_mcp_host.py`.

Une fois la dépendance installée, vous pourrez lancer le host, pointer n’importe quel client MCP dessus ou l’intégrer à vos agents existants.
