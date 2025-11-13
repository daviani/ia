#!/bin/bash
# Lance LiteLLM + host MCP en une seule commande
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/litellm.config.yaml"
LITELLM_HOST="127.0.0.1"
LITELLM_PORT="${LITELLM_PORT:-4000}"
MODEL_ALIAS="${MODEL_ALIAS:-qwen3-dev}"
API_KEY="${MCP_API_KEY:-dummy-key}"
FILESYSTEM_ROOT="${FILESYSTEM_ROOT:-$HOME/Dev}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --root PATH        Racine exposée par le serveur MCP filesystem (défaut: ~/Dev)
  --port PORT        Port pour LiteLLM (défaut: 4000)
  --model NAME       Alias du modèle défini dans litellm.config.yaml (défaut: qwen3-dev)
  --api-key KEY      Clé acceptée par LiteLLM (défaut: dummy-key)
  --python BIN       Binaire Python à utiliser pour qwen_mcp_host.py (défaut: python3)
  -h, --help         Affiche cette aide

Variables d'environnement acceptées :
  FILESYSTEM_ROOT, LITELLM_PORT, MODEL_ALIAS, MCP_API_KEY, PYTHON_BIN
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      FILESYSTEM_ROOT="$2"
      shift 2
      ;;
    --port)
      LITELLM_PORT="$2"
      shift 2
      ;;
    --model)
      MODEL_ALIAS="$2"
      shift 2
      ;;
    --api-key)
      API_KEY="$2"
      shift 2
      ;;
    --python)
      PYTHON_BIN="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Option inconnue: $1"
      usage
      exit 1
      ;;
  esac
done

ensure_python_has_mcp() {
  local bin="$1"
  "$bin" - <<'PY' >/dev/null 2>&1
import sys
try:
    import huggingface_hub  # noqa: F401
    from huggingface_hub.inference import _mcp  # noqa: F401
except Exception:
    sys.exit(1)
PY
}

LITELLM_BIN="$HOME/Library/Python/3.11/bin/litellm"

if ! test -f "$LITELLM_BIN"; then
  echo "❌ litellm est introuvable pour Python 3.11. Installez-le avec '/opt/homebrew/bin/python3.11 -m pip install --user \"litellm[proxy]\"'."
  exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1 || ! ensure_python_has_mcp "$PYTHON_BIN"; then
  if command -v python3.11 >/dev/null 2>&1 && ensure_python_has_mcp python3.11; then
    echo "ℹ️  Bascule automatique sur python3.11 (support MCP détecté)."
    PYTHON_BIN="python3.11"
  else
    echo "❌ Aucun interpréteur compatible MCP n'a été trouvé."
    echo "   Installez/actualisez huggingface_hub avec :"
    echo "     python3 -m pip install --user --upgrade \"huggingface_hub>=0.30\" \"modelcontextprotocol>=0.1\" \"mcp>=1.2\""
    exit 1
  fi
fi

ROOT_ABS="$(cd "${FILESYSTEM_ROOT/#\~/$HOME}" && pwd)"

echo "📁 Root filesystem MCP : $ROOT_ABS"
echo "🌐 LiteLLM: http://${LITELLM_HOST}:${LITELLM_PORT}/v1 (alias: ${MODEL_ALIAS})"

LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOG_DIR"
LITELLM_LOG="$LOG_DIR/litellm.log"

cleanup() {
  [[ -n "${LITELLM_PID:-}" ]] && kill "$LITELLM_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "🚀 Démarrage LiteLLM (log: $LITELLM_LOG)"
"$LITELLM_BIN" --config "$CONFIG_FILE" --host "$LITELLM_HOST" --port "$LITELLM_PORT" >"$LITELLM_LOG" 2>&1 &
LITELLM_PID=$!
sleep 2

echo "🤝 Connexion du host MCP..."
"$PYTHON_BIN" "$SCRIPT_DIR/qwen_mcp_host.py" \
  --filesystem-root "$ROOT_ABS" \
  --model "$MODEL_ALIAS" \
  --litellm-url "http://${LITELLM_HOST}:${LITELLM_PORT}/v1" \
  --api-key "$API_KEY"
