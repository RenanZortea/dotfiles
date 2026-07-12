#!/usr/bin/env bash
#
# Pull the live configs out of ~/.config and into this repo.
#
#   ./sync.sh                    sync + show what changed (no commit)
#   ./sync.sh "commit message"   sync, commit, push
#
# Most of ~/.config is symlinked into ML4W's tree, so we copy through the links
# (rsync -L) and store real files. Committing the symlinks themselves would store
# link text and no content -- that is what broke the old `main` branch.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
MSG="${1:-}"

cd "$REPO"

# Anything already tracked, plus the .gitignore whitelist. A directory that
# exists in the repo but not in ~/.config is left alone rather than deleted --
# alacritty, dunst, ghostty, tmux, wal and wallust only exist here.
mapfile -t ENTRIES < <(git ls-tree --name-only HEAD | grep -vE '^(README\.md|\.gitignore|sync\.sh)$')

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

git add -A

if git diff --cached --quiet; then
    echo "nothing changed."
    exit 0
fi

# This repo is public and ~/.config is full of live credentials. Never let one
# through, even if a whitelist rule changes by accident.
echo
echo "checking for secrets..."
if git diff --cached | grep -inE 'gho_[A-Za-z0-9]{8}|ghp_[A-Za-z0-9]{8}|sk-[A-Za-z0-9]{16}|BEGIN [A-Z ]*PRIVATE KEY|oauth_token'; then
    echo
    echo "ABORT: that looks like a credential. Nothing was committed."
    git reset -q
    exit 1
fi
echo "clean."

echo
git diff --cached --stat | tail -20

if [ -z "$MSG" ]; then
    echo
    echo "staged but not committed. Re-run with a message to push:"
    echo "  ./sync.sh \"what changed\""
    exit 0
fi

git commit -qm "$MSG"
git push -q origin main
echo
echo "pushed: $(git log --oneline -1)"
