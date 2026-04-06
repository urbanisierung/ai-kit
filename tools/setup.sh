#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# AI_KIT_REPO is used in templates and dotfiles; can be overridden by the caller
export AI_KIT_REPO="${AI_KIT_REPO:-$REPO}"

echo "==> Linking Claude global config..."
ln -sf "$REPO/claude/CLAUDE.md.global" ~/.claude/CLAUDE.md
ln -sfn "$REPO/claude/skills" ~/.claude/skills

echo "==> Writing Claude configs from templates (keys from .env)..."
if [[ -f "$REPO/.env" ]]; then
  set -a; source "$REPO/.env"; set +a
fi
envsubst < "$REPO/claude/mcp.json.template" > ~/.claude/mcp.json
envsubst < "$REPO/claude/settings.json.template" > ~/.claude/settings.json

echo "==> Linking Gemini global config..."
mkdir -p ~/.gemini
ln -sf "$REPO/gemini/GEMINI.md.global" ~/.gemini/GEMINI.md

echo "==> Sourcing AI dotfiles..."
if ! grep -q "zshrc.ai" ~/.zshrc 2>/dev/null; then
  echo "source $REPO/dotfiles/.zshrc.ai" >> ~/.zshrc
fi

echo "Done. Open a new shell to pick up dotfile changes."
