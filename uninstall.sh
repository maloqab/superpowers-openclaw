#!/usr/bin/env bash
set -euo pipefail

# superpowers-openclaw uninstaller
# Safely removes superpowers skill symlinks from OpenClaw.

OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
SUPERPOWERS_DIR="$OPENCLAW_DIR/superpowers"
SKILLS_DIR="$OPENCLAW_DIR/skills"

AUTO_YES=false
PURGE=false
SKILL_LIST=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Remove superpowers skills from OpenClaw.

Options:
  --yes         Skip confirmation prompt
  --purge       Also remove the superpowers git clone
  --skills LIST Only remove these skills (comma-separated)
  --help        Show this help message
EOF
  exit 0
}

log()  { printf "\033[0;32m=>\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m!>\033[0m %s\n" "$1"; }
err()  { printf "\033[0;31m!>\033[0m %s\n" "$1" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)     AUTO_YES=true; shift ;;
    --purge)   PURGE=true; shift ;;
    --skills)  SKILL_LIST="$2"; shift 2 ;;
    --help|-h) usage ;;
    *)         err "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$OPENCLAW_DIR" || "$OPENCLAW_DIR" != /* ]]; then
  err "OPENCLAW_DIR must be an absolute path. Got: '$OPENCLAW_DIR'"
  exit 1
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
  log "No skills directory found at $SKILLS_DIR. Nothing to remove."
  exit 0
fi

# Find superpowers symlinks
TO_REMOVE=()
for item in "$SKILLS_DIR"/*/; do
  [[ -L "${item%/}" ]] || continue
  target="$(readlink "${item%/}")"
  if [[ "$target" == "$SUPERPOWERS_DIR"* ]]; then
    name="$(basename "${item%/}")"
    if [[ -n "$SKILL_LIST" ]]; then
      IFS=',' read -ra REQUESTED <<< "$SKILL_LIST"
      for req in "${REQUESTED[@]}"; do
        req="$(echo "$req" | xargs)"
        [[ "$name" == "$req" ]] && TO_REMOVE+=("$name") && break
      done
    else
      TO_REMOVE+=("$name")
    fi
  fi
done

if [[ ${#TO_REMOVE[@]} -eq 0 ]]; then
  log "No superpowers skill symlinks found. Nothing to remove."
  exit 0
fi

echo "The following ${#TO_REMOVE[@]} superpowers skill symlinks will be removed:"
for name in "${TO_REMOVE[@]}"; do
  echo "  - $name"
done

if $PURGE; then
  echo ""
  echo "The superpowers clone at $SUPERPOWERS_DIR will also be deleted."
fi

if ! $AUTO_YES; then
  echo ""
  read -rp "Proceed? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { log "Cancelled."; exit 0; }
fi

# Remove symlinks
removed=0
for name in "${TO_REMOVE[@]}"; do
  rm "$SKILLS_DIR/$name"
  log "Removed: $name"
  removed=$((removed + 1))
done

# Optionally purge the clone
if $PURGE && [[ -d "$SUPERPOWERS_DIR" ]]; then
  rm -rf "$SUPERPOWERS_DIR"
  log "Removed superpowers clone at $SUPERPOWERS_DIR"
fi

echo ""
log "Removed $removed superpowers skill symlink(s)."

if ! $PURGE && [[ -d "$SUPERPOWERS_DIR" ]]; then
  echo "Superpowers clone preserved at $SUPERPOWERS_DIR"
  echo "Use --purge to also remove it."
fi

echo ""
echo "Run 'openclaw gateway restart' to apply changes."
