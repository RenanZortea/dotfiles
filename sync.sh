#!/usr/bin/env bash
#
# Pull the live configs out of ~/.config and into this repo.
#
#   ./sync.sh                    sync + show what changed (nothing is staged)
#   ./sync.sh "commit message"   sync, commit, push
#
# Most of ~/.config is symlinked into ML4W's tree, so we copy through the links
# and store real files. Committing the symlinks themselves would store link text
# and no content -- that is what left the old `main` branch empty.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
MSG="${1:-}"

cd "$REPO"

# The credential check lives in .git/hooks/pre-commit so that a plain `git
# commit` cannot skip it. Hooks are not cloned, so install it if it is missing.
if [ ! -x "$REPO/.git/hooks/pre-commit" ]; then
    install -m 755 "$REPO/hooks/pre-commit" "$REPO/.git/hooks/pre-commit"
    echo "installed pre-commit credential check"
fi

# Anything already tracked. A directory that exists here but not in ~/.config is
# left alone rather than deleted -- alacritty, dunst, ghostty, wal and wallust
# only exist in this repo.
mapfile -t ENTRIES < <(git ls-tree --name-only HEAD |
    grep -vE '^(README\.md|\.gitignore|sync\.sh|hooks)$')

# We copy through symlinks, so a link inside a synced directory drags its target
# into a public repo. Only targets we already sync are acceptable. Note that the
# rest of ~/.config is NOT acceptable: gh/hosts.yml, Claude/, discord/ and others
# hold live credentials, and a link into one of them would quietly publish it.
ALLOWED=("$HOME/.mydotfiles")
for name in "${ENTRIES[@]}"; do ALLOWED+=("$CONFIG/$name"); done

escaped=0
for name in "${ENTRIES[@]}"; do
    src="$CONFIG/$name"
    [ -d "$src" ] || continue
    while IFS= read -r link; do
        target="$(readlink -f "$link" 2>/dev/null || true)"
        ok=0
        for root in "${ALLOWED[@]}"; do
            case "$target" in "$root" | "$root"/*) ok=1; break ;; esac
        done
        if [ "$ok" -eq 0 ]; then
            echo "  $link -> ${target:-<broken>}"
            escaped=1
        fi
    done < <(find -P "$src/" -type l 2>/dev/null)
done
if [ "$escaped" -eq 1 ]; then
    echo
    echo "ABORT: the symlinks above point outside what this repo syncs, and"
    echo "syncing follows them -- that is how a credential ends up published."
    echo "Repoint them, or add an --exclude for them."
    exit 1
fi

synced=() skipped=()
for name in "${ENTRIES[@]}"; do
    src="$CONFIG/$name"
    [ -e "$src" ] || { skipped+=("$name"); continue; }

    if [ -d "$src" ]; then
        rsync -aL --delete \
            --exclude='.git' \
            --exclude='*.bak-*' \
            --exclude='__pycache__' \
            --exclude='/plugins/' \
            "$src/" "$REPO/$name/"
    else
        cp -L "$src" "$REPO/$name"
    fi
    synced+=("$name")
done

printf 'synced %d from ~/.config\n' "${#synced[@]}"
[ ${#skipped[@]} -gt 0 ] && printf 'left alone (not on this machine): %s\n' "${skipped[*]}"

if [ -z "$(git status --porcelain)" ]; then
    echo "nothing changed."
    exit 0
fi

echo
git -c color.ui=always status --short | head -25

# Nothing is staged unless we are actually committing, so there is never a pile
# of staged-but-unscanned files sitting around for a later `git commit` to pick up.
if [ -z "$MSG" ]; then
    echo
    echo "not staged. Re-run with a message to commit and push:"
    echo "  ./sync.sh \"what changed\""
    exit 0
fi

git add -A
# The pre-commit hook scans for credentials here. If it refuses, unstage
# everything -- otherwise the rejected files sit staged and a later `git commit`
# would sweep them in without the hook ever looking at them again.
if ! git commit -qm "$MSG"; then
    git reset -q
    exit 1
fi
git push -q origin main
echo
echo "pushed: $(git log --oneline -1)"
