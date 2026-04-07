#!/usr/bin/env bash
set -euo pipefail

TYPE=""
ACTION_TEXT=""
ACTOR_ID="${PSL_ACTOR_ID:-global}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) TYPE="${2:-}"; shift 2 ;;
    --action-text) ACTION_TEXT="${2:-}"; shift 2 ;;
    --actor-id) ACTOR_ID="${2:-global}"; shift 2 ;;
    *) echo "usage: psl-core.sh --type detect|action|send [--action-text <text>] [--actor-id <id>]"; exit 2 ;;
  esac
done

MODE="${PSL_MODE:-balanced}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RULES_DIR="${PSL_RULES_DIR:-$SCRIPT_DIR/../rules}"
LOG_PATH="${PSL_LOG_PATH:-$ROOT_DIR/memory/security-log.jsonl}"
RL_STATE_PATH="${PSL_RL_STATE_PATH:-$ROOT_DIR/memory/psl-rate-limit.json}"
RL_MAX_REQ="${PSL_RL_MAX_REQ:-30}"
RL_WINDOW_SEC="${PSL_RL_WINDOW_SEC:-60}"
RL_ACTION="${PSL_RL_ACTION:-block}"

INPUT=""
if [[ "$TYPE" == "action" ]]; then
  INPUT="$ACTION_TEXT"
else
  INPUT="$(cat || true)"
fi

if [[ -z "$TYPE" || -z "${INPUT:-}" ]]; then
  echo '{"ok":false,"error":"missing type or input"}'
  exit 2
fi

python3 "$SCRIPT_DIR/psl-core.py" \
  "$TYPE" "$MODE" "$RULES_DIR" "$LOG_PATH" "$INPUT" "$ACTOR_ID" \
  "$RL_STATE_PATH" "$RL_MAX_REQ" "$RL_WINDOW_SEC" "$RL_ACTION"
