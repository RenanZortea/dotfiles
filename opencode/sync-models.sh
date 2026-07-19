#!/usr/bin/env bash
# Regenerate opencode.json's ollama model list from `ollama list`.
# opencode has no Ollama auto-discovery, so this stands in for it.
# Custom display names are preserved; pulled models are added; removed models are dropped.
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"
[ -f "$CONFIG" ] || { echo "no config at $CONFIG" >&2; exit 1; }

discovered=$(ollama list | tail -n +2 | awk 'NF {print $1}' \
  | jq -R -s 'split("\n") | map(select(length > 0)) | map({(.): {name: .}}) | add // {}')

[ "$discovered" = "{}" ] && { echo "ollama has no models; refusing to blank the list" >&2; exit 1; }

tmp=$(mktemp)
jq --argjson d "$discovered" '
  .provider.ollama.models =
    ($d + ((.provider.ollama.models // {})
           | with_entries(.key as $k | select($d | has($k)))))
' "$CONFIG" > "$tmp"
mv "$tmp" "$CONFIG"

# A stale .model / .small_model silently breaks opencode at startup, so check.
for key in model small_model; do
  sel=$(jq -r --arg k "$key" '.[$k] // empty' "$CONFIG")
  [ -n "$sel" ] || continue
  id=${sel#ollama/}
  [ "$id" = "$sel" ] && continue   # not an ollama model, leave it alone
  jq -e --arg id "$id" '.provider.ollama.models | has($id)' "$CONFIG" >/dev/null \
    || echo "WARNING: .$key is '$sel' but that model is no longer in \`ollama list\`" >&2
done

echo "synced $(jq -r '.provider.ollama.models | keys | length' "$CONFIG") model(s):"
jq -r '.provider.ollama.models | keys[] | "  - " + .' "$CONFIG"
