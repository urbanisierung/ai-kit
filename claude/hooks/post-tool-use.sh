#!/usr/bin/env bash
# PostToolUse hook — runs after every tool call Claude makes.
# Add project-specific linters or checks here.
# Keep it fast: slow hooks degrade the feedback loop.

# Example: run lint on the file Claude just wrote (if it's TypeScript)
# TOOL_INPUT is set by Claude Code when the hook fires
# Uncomment and adapt as needed:
# if [[ "$TOOL_INPUT" == *.ts || "$TOOL_INPUT" == *.tsx ]]; then
#   pnpm biome check "$TOOL_INPUT" 2>&1 | tail -10
# fi
