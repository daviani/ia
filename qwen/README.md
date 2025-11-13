# Qwen3-Coder local

Tout ce qui touche Qwen3 est regroupé ici pour éviter de fouiller dans `~/.ollama`.

## Contenu proposé

- `Modelfile` : profil `qwen3-coder-dev` prêt à être construit avec `ollama create`.
- `system-prompt.md` : espace pour vos instructions persistantes (distribué avec un exemple minimal).
- `sessions/` : créez librement un sous-dossier pour archiver vos prompts/réponses les plus utiles.

N'hésitez pas à adapter cette arborescence à vos propres projets.

## Créer un modèle dev séparé

```bash
ollama create qwen3-coder-dev -f ~/LLM/qwen/Modelfile
ollama run qwen3-coder-dev "test"
```

Ensuite, changez `model: ollama_chat/qwen3-coder-dev` dans `~/LLM/aider/aider.conf.yml` si vous préférez ce profil.

## System prompt dédié

Ajoutez/éditez `system-prompt.md` et recopiez son contenu dans vos Modelfiles ou dans Aider lorsqu'un projet a des garde-fous spécifiques (normes de commit, style de doc, etc.).

## Sauvegardes

Le dossier `~/LLM` peut être copié tel quel (iCloud, Time Machine, git privé). Les modèles sont volumineux : pensez à exclure `~/LLM/ollama/models` si l'espace manque.
