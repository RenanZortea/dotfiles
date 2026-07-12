#!/usr/bin/env bash
#
# Back up $HOME to the HDD at /mnt/d with restic.
#
#   backup.sh          take a snapshot, then prune old ones
#   backup.sh check    verify the repository is not corrupt
#   backup.sh list     show snapshots
#   backup.sh restore  print how to restore (does not restore anything)
#
# The repo is encrypted. The password lives in ~/.restic-password, which is NOT
# in the dotfiles repo and NOT backed up -- by design, since a backup password
# stored inside the backup is useless. If you lose it, the backup is
# unrecoverable. Put it in your password manager.

set -euo pipefail

export RESTIC_REPOSITORY="/mnt/d/restic"
export RESTIC_PASSWORD_FILE="$HOME/.restic-password"

EXCLUDES="$HOME/.config/restic/excludes.txt"

if ! mountpoint -q /mnt/d; then
    echo "/mnt/d is not mounted; nothing to back up to." >&2
    exit 1
fi

case "${1:-backup}" in
list)
    restic snapshots
    ;;

check)
    # --read-data-subset spot-checks actual file data, not just metadata.
    restic check --read-data-subset=5%
    ;;

restore)
    cat <<EOF
Snapshots:
  restic -r $RESTIC_REPOSITORY snapshots

Restore the latest snapshot somewhere safe first (never straight over \$HOME):
  restic -r $RESTIC_REPOSITORY restore latest --target /tmp/restore

Pull back a single path:
  restic -r $RESTIC_REPOSITORY restore latest --target /tmp/restore --include /home/renan/Projects

Browse a snapshot as a filesystem:
  mkdir -p /tmp/mnt && restic -r $RESTIC_REPOSITORY mount /tmp/mnt
EOF
    ;;

backup)
    restic backup "$HOME" \
        --exclude-file="$EXCLUDES" \
        --exclude-caches \
        --tag home \
        --verbose

    # Keep enough history to undo a mistake you notice late, without letting the
    # repo grow forever. Dedup means old snapshots are cheap.
    restic forget \
        --tag home \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        --keep-yearly 2 \
        --prune
    ;;

*)
    echo "usage: backup.sh [backup|list|check|restore]" >&2
    exit 1
    ;;
esac
