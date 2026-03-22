#!/usr/bin/env bash
set -euo pipefail

# superpowers-openclaw installer
# Brings superpowers development workflow skills to OpenClaw agents.
# https://github.com/maloqab/superpowers-openclaw

SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"
OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
SUPERPOWERS_DIR="$OPENCLAW_DIR/superpowers"
SKILLS_DIR="$OPENCLAW_DIR/skills"

# Defaults
MODE="all"
SKILL_LIST=""
EXCLUDE_LIST=""
FORCE=false
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install superpowers skills into OpenClaw.

Options:
  --all               Install all skills (default)
  --skills LIST       Install only these skills (comma-separated)
  --exclude LIST      Install all except these skills (comma-separated)
  --force             Override existing non-matching symlinks
  --dry-run           Show what would be done without doing it
  --update            Only update superpowers (git pull), skip symlinks
  --help              Show this help message

Examples:
  ./install.sh
  ./install.sh --skills brainstorming,test-driven-development,systematic-debugging
  ./install.sh --exclude writing-skills,using-superpowers
  ./install.sh --dry-run
EOF
  exit 0
}

log()  { printf "\033[0;32m=>\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m!>\033[0m %s\n" "$1"; }
err()  { printf "\033[0;31m!>\033[0m %s\n" "$1" >&2; }
die()  { err "$1"; exit 1; }

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)      MODE="all"; shift ;;
    --skills)   MODE="include"; SKILL_LIST="$2"; shift 2 ;;
    --exclude)  MODE="exclude"; EXCLUDE_LIST="$2"; shift 2 ;;
    --force)    FORCE=true; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --update)   MODE="update"; shift ;;
    --help|-h)  usage ;;
    *)          die "Unknown option: $1. Use --help for usage." ;;
  esac
done

# Pre-flight checks
command -v git >/dev/null 2>&1 || die "git is required but not installed."

if [[ -z "$OPENCLAW_DIR" || "$OPENCLAW_DIR" != /* ]]; then
  die "OPENCLAW_DIR must be an absolute path. Got: '$OPENCLAW_DIR'"
fi

if [[ ! -d "$OPENCLAW_DIR" ]]; then
  die "OpenClaw directory not found at $OPENCLAW_DIR. Is OpenClaw installed?"
fi

mkdir -p "$SKILLS_DIR"

# Clone or update superpowers
if [[ -d "$SUPERPOWERS_DIR" ]]; then
  if [[ -d "$SUPERPOWERS_DIR/.git" ]]; then
    log "Updating superpowers..."
    if $DRY_RUN; then
      log "[dry-run] Would run: git -C $SUPERPOWERS_DIR pull --ff-only"
    else
      git -C "$SUPERPOWERS_DIR" pull --ff-only 2>/dev/null || warn "Could not update (may have local changes). Continuing with existing version."
    fi
  else
    die "$SUPERPOWERS_DIR exists but is not a git repository."
  fi
else
  log "Cloning superpowers..."
  if $DRY_RUN; then
    log "[dry-run] Would run: git clone $SUPERPOWERS_REPO $SUPERPOWERS_DIR"
  else
    git clone "$SUPERPOWERS_REPO" "$SUPERPOWERS_DIR"
  fi
fi

if [[ "$MODE" == "update" ]]; then
  log "Update complete."
  exit 0
fi

# Discover available skills
AVAILABLE=()
for skill_dir in "$SUPERPOWERS_DIR"/skills/*/; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  AVAILABLE+=("$(basename "$skill_dir")")
done

if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
  die "No skills found in $SUPERPOWERS_DIR/skills/. Is the clone valid?"
fi

log "Found ${#AVAILABLE[@]} superpowers skills."

# Build install list based on mode
TO_INSTALL=()
case "$MODE" in
  all)
    TO_INSTALL=("${AVAILABLE[@]}")
    ;;
  include)
    IFS=',' read -ra REQUESTED <<< "$SKILL_LIST"
    for req in "${REQUESTED[@]}"; do
      req="$(echo "$req" | xargs)" # trim whitespace
      found=false
      for avail in "${AVAILABLE[@]}"; do
        if [[ "$avail" == "$req" ]]; then
          TO_INSTALL+=("$req")
          found=true
          break
        fi
      done
      if ! $found; then
        warn "Skill '$req' not found in superpowers. Skipping."
      fi
    done
    ;;
  exclude)
    IFS=',' read -ra EXCLUDED <<< "$EXCLUDE_LIST"
    for avail in "${AVAILABLE[@]}"; do
      skip=false
      for excl in "${EXCLUDED[@]}"; do
        excl="$(echo "$excl" | xargs)"
        if [[ "$avail" == "$excl" ]]; then
          skip=true
          break
        fi
      done
      if ! $skip; then
        TO_INSTALL+=("$avail")
      fi
    done
    ;;
esac

if [[ ${#TO_INSTALL[@]} -eq 0 ]]; then
  die "No skills to install after filtering."
fi

# Create symlinks
linked=0
skipped=0
for skill in "${TO_INSTALL[@]}"; do
  target="$SUPERPOWERS_DIR/skills/$skill"
  link="$SKILLS_DIR/$skill"

  if [[ -L "$link" ]]; then
    current_target="$(readlink "$link")"
    # Normalize trailing slashes for comparison
    norm_target="${target%/}"
    norm_current="${current_target%/}"
    if [[ "$norm_current" == "$norm_target" ]]; then
      skipped=$((skipped + 1))
      continue
    elif $FORCE; then
      if $DRY_RUN; then
        log "[dry-run] Would replace symlink: $skill"
      else
        rm "$link"
        ln -s "$target" "$link"
        log "Replaced: $skill"
      fi
      linked=$((linked + 1))
    else
      warn "Skill '$skill' symlink exists but points to $current_target. Use --force to override."
      skipped=$((skipped + 1))
    fi
  elif [[ -e "$link" ]]; then
    warn "Skill '$skill' exists as a real directory. Skipping to avoid data loss."
    skipped=$((skipped + 1))
  else
    if $DRY_RUN; then
      log "[dry-run] Would link: $skill"
    else
      ln -s "$target" "$link"
      log "Linked: $skill"
    fi
    linked=$((linked + 1))
  fi
done

# Summary
echo ""
if $DRY_RUN; then
  log "Dry run complete. Would install $linked skill(s), $skipped already present."
else
  log "Installed $linked skill(s), $skipped already present."
  # 修复：设置正确的技能目录权限，确保可执行
  if [[ $linked -gt 0 ]]; then
    chmod -R 755 "$SKILLS_DIR"
    log "已设置技能目录权限为755"
  fi
fi

# Verify
if ! $DRY_RUN && command -v openclaw >/dev/null 2>&1; then
  echo ""
  ready=$(openclaw skills list 2>/dev/null | grep -c "✓ ready" || true)
  log "OpenClaw reports $ready ready skills."
fi

# Next steps
echo ""
echo "Next steps:"
echo "  1. Restart your gateway:  openclaw gateway restart"
echo "  2. Verify:                openclaw skills list"
echo "  3. Add skill sections to your agents' SOUL.md files."
echo "     See templates/ in this repo for role-based examples."
echo ""
echo "Docs: https://github.com/maloqab/superpowers-openclaw"
