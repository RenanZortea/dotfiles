#!/usr/bin/env bash
#
# Apply this repo to a machine. The inverse of sync.sh.
#
#   ./restore.sh           show what would change (default: nothing is written)
#   ./restore.sh --apply   actually write
#
# Run this AFTER installing ML4W, so that ~/.config/{waybar,hypr,ml4w,...} already
# exist as symlinks into ~/.mydotfiles. Writing through those symlinks lands the
# files in ML4W's tree, which is where they belong.
#
# Not handled here, because they are not config:
#   - packages (see REQUIRED below)
#   - nvim plugins  -> lazy.nvim installs them from nvim/lazy-lock.json on first run
#   - tmux plugins  -> bootstrapped below, then `prefix + I` (or install_plugins)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

REQUIRED=(tmux nvim fzf zoxide playerctl rsync git)
OPTIONAL=(nvidia-smi bat)

echo "== packages =="
missing=()
for c in "${REQUIRED[@]}"; do
    command -v "$c" >/dev/null || missing+=("$c")
done
for c in "${OPTIONAL[@]}"; do
    command -v "$c" >/dev/null || echo "  optional, not installed: $c"
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "  MISSING: ${missing[*]}"
    echo "  install these first; the configs reference them."
    [ "$APPLY" -eq 1 ] && exit 1
fi

echo
echo "== configs =="
mapfile -t ENTRIES < <(git -C "$REPO" ls-tree --name-only HEAD |
    grep -vE '^(README\.md|\.gitignore|sync\.sh|restore\.sh|hooks)$')

# --delete keeps the target honest, but never touch the timestamped backups you
# took before hand-editing something, and never the tpm-managed plugin dirs.
RSYNC_FLAGS=(-a --delete --exclude='.git' --exclude='/plugins/' --exclude='*.bak-*')
[ "$APPLY" -eq 0 ] && RSYNC_FLAGS+=(--dry-run --itemize-changes)

for name in "${ENTRIES[@]}"; do
    src="$REPO/$name"
    dst="$CONFIG/$name"

    # ~/.config/waybar and friends are symlinks into ML4W's tree; a trailing
    # slash makes rsync write through the link, into the real files.
    if [ -d "$src" ]; then
        [ "$APPLY" -eq 1 ] && mkdir -p "$dst"
        if [ ! -e "$dst" ] && [ "$APPLY" -eq 0 ]; then
            echo "  NEW  $name/"
            continue
        fi
        # `|| true`: grep exits 1 when it matches nothing, which under pipefail
        # would abort the script exactly when a directory is already in sync.
        out=$(rsync "${RSYNC_FLAGS[@]}" "$src/" "$dst/" 2>/dev/null | grep -vcE '^$|/$' || true)
        [ "${out:-0}" -gt 0 ] && printf '  %-24s %s file(s) differ\n' "$name/" "$out"
    else
        if [ "$APPLY" -eq 1 ]; then
            cp "$src" "$dst"
        elif ! cmp -s "$src" "$dst" 2>/dev/null; then
            echo "  $name"
        fi
    fi
done

echo
echo "== tmux plugins =="
TPM="$CONFIG/tmux/plugins/tpm"
if [ -d "$TPM" ]; then
    echo "  tpm already present"
elif [ "$APPLY" -eq 1 ]; then
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
    "$TPM/bin/install_plugins" >/dev/null 2>&1 || true
    echo "  tpm cloned + plugins installed"
else
    echo "  would clone tpm and install plugins"
fi

echo
if [ "$APPLY" -eq 0 ]; then
    echo "dry run. Nothing was written. Re-run with --apply to commit to it."
else
    echo "done. Start a fresh nvim (lazy.nvim will install plugins from lazy-lock.json),"
    echo "and reload waybar with ~/.config/waybar/launch.sh"
fi
