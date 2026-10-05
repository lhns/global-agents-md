#!/bin/sh
# Installs the global agent instructions from this repo. Safe to re-run:
# updates what it installed and asks before touching anything else.
set -eu

REPO=$(cd "$(dirname "$0")" && pwd)
# Git Bash: Claude Code needs a Windows path (C:/...), not /c/...
if command -v cygpath >/dev/null 2>&1; then
  IMPORT="@$(cygpath -m "$REPO")/claude-global.md"
else
  IMPORT="@$REPO/claude-global.md"
fi

info() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
confirm() {
  printf '%s [y/N] ' "$1"
  read -r ans || ans=
  case $ans in [yY]*) return 0 ;; *) return 1 ;; esac
}

# Claude Code: import claude-global.md from ~/.claude/CLAUDE.md
claude_md="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
if [ ! -s "$claude_md" ]; then
  printf '%s\n' "$IMPORT" > "$claude_md"
  info "Claude: created $claude_md"
# tr strips CRs so files written on Windows match too.
elif tr -d '\r' < "$claude_md" | grep -qxF "$IMPORT"; then
  info "Claude: up to date"
elif tr -d '\r' < "$claude_md" | grep -q '^@.*/claude-global\.md$'; then
  cp "$claude_md" "$claude_md.bak"
  awk -v line="$IMPORT" '{ sub(/\r$/, "") } /^@.*\/claude-global\.md$/ { print line; next } { print }' \
    "$claude_md.bak" > "$claude_md"
  info "Claude: updated import path (backup: $claude_md.bak)"
else
  warn "$claude_md already has content ($(wc -l < "$claude_md") lines)."
  if confirm "Append the import line?"; then
    cp "$claude_md" "$claude_md.bak"
    printf '\n%s\n' "$IMPORT" >> "$claude_md"
    info "Claude: appended import (backup: $claude_md.bak)"
  else
    info "Claude: skipped. Add this line manually: $IMPORT"
  fi
fi

if [ -e "$HOME/.claude/AGENTS.md" ]; then
  warn "$HOME/.claude/AGENTS.md exists. Claude Code doesn't load it at user level; merge it into this repo or remove it."
fi

# Codex: ~/.codex/AGENTS.md as symlink, or as a copy where symlinks aren't
# available (Git Bash). The stamp records the installed copy so unedited
# copies can be updated without asking.
codex="$HOME/.codex"
src="$REPO/AGENTS.md"
dst="$codex/AGENTS.md"
stamp="$codex/.agents-md-installed"

install_codex() {
  rm -f "$dst"
  ln -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
  if [ -L "$dst" ]; then rm -f "$stamp"; else cp "$src" "$stamp"; fi
}

if [ ! -d "$codex" ]; then
  info "Codex: $codex not found, skipping"
else
  if [ -e "$codex/AGENTS.override.md" ]; then
    warn "$codex/AGENTS.override.md exists and takes precedence over AGENTS.md."
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "Codex: up to date (symlink)"
  elif [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
    install_codex
    info "Codex: installed $dst"
  elif [ ! -L "$dst" ] && cmp -s "$dst" "$src"; then
    cp "$src" "$stamp"
    info "Codex: up to date"
  elif [ ! -L "$dst" ] && [ -f "$stamp" ] && cmp -s "$dst" "$stamp"; then
    install_codex
    info "Codex: updated $dst"
  else
    warn "$dst differs from this repo's AGENTS.md (local edits or another file)."
    if confirm "Replace it (backup to AGENTS.md.bak)?"; then
      cp "$dst" "$dst.bak"
      install_codex
      info "Codex: replaced $dst"
    else
      info "Codex: skipped"
    fi
  fi
fi

info "Done. Verify with /memory in a new Claude Code session."
