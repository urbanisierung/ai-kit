#!/usr/bin/env bash
# install-tools.sh — install the CLI tools referenced in docs/ai-champion.md
#
# Run:  bash tools/install-tools.sh
# Each tool asks for confirmation before installing. Safe to re-run.
#
# What this covers (CLI tools only):
#   RTK, rudel, pi-self-learning, opencode-ai, ecc (everything-claude-code),
#   jai (Linux only), hermes, nvm/node
#
# What you still need to do manually (interactive/platform-specific):
#   Claude Code plugins   → run inside Claude: /plugin install <name>
#   MCP servers           → claude mcp add ... (needs API keys)
#   DeerFlow              → docker compose (see docs)
#   Open SWE              → LangGraph Cloud deploy (see docs)
#   Superset              → macOS app download
#   Project NOMAD         → Debian/Ubuntu only, sudo required
#   Agent-Reach           → tell Claude to install it from the install URL

set -euo pipefail

OS="$(uname -s)"
SKIP=0

_confirm() {
  local msg="$1"
  printf "\n[?] %s (y/N) " "$msg"
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

_ok()   { printf "  [ok] %s\n" "$1"; }
_skip() { printf "  [--] %s — skipped\n" "$1"; }
_warn() { printf "  [!]  %s\n" "$1"; }

echo "========================================"
echo " ai-kit tool installer"
echo " OS: $OS"
echo "========================================"

# ── Node.js / nvm ─────────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  if _confirm "node not found. Install via nvm?"; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    # shellcheck disable=SC1090
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    nvm install 22 && nvm use 22
    _ok "node $(node --version) installed"
  else
    _skip "nvm/node — several tools below require it"
  fi
else
  _ok "node $(node --version) already installed"
fi

# ── RTK (Rust Token Killer) ───────────────────────────────────────────────────
if ! command -v rtk &>/dev/null; then
  if _confirm "Install RTK (60–90% token savings on shell output)?"; then
    if [[ "$OS" == "Darwin" ]]; then
      brew install rtk
    else
      curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    fi
    rtk init -g   # install Claude Code hook
    _ok "RTK installed and hooked into Claude Code"
    echo "      Also run: rtk init -g --gemini  (for Gemini CLI)"
  else
    _skip "RTK"
  fi
else
  _ok "RTK already installed ($(rtk --version 2>/dev/null || echo '?'))"
fi

# ── rudel (session analytics) ─────────────────────────────────────────────────
if ! command -v rudel &>/dev/null; then
  if _confirm "Install rudel (session analytics dashboard)?"; then
    npm install -g rudel
    _ok "rudel installed — run: rudel login && rudel enable"
    _warn "rudel uploads full session transcripts. Use on appropriate projects only."
  else
    _skip "rudel"
  fi
else
  _ok "rudel already installed"
fi

# ── pi CLI + pi-self-learning ─────────────────────────────────────────────────
if ! command -v pi &>/dev/null; then
  if _confirm "Install pi CLI + pi-self-learning (persistent git-backed memory)?"; then
    npm install -g @pi-labs/cli
    pi install npm:pi-self-learning
    _ok "pi-self-learning installed — commands: /learning-now, /learning-month"
  else
    _skip "pi-self-learning"
  fi
else
  _ok "pi CLI already installed"
  if _confirm "Re-run 'pi install npm:pi-self-learning'?"; then
    pi install npm:pi-self-learning
    _ok "pi-self-learning installed"
  fi
fi

# ── Everything Claude Code (ecc) ──────────────────────────────────────────────
if ! command -v ecc &>/dev/null 2>&1; then
  if _confirm "Install Everything Claude Code (150+ skills, 70+ commands, hooks, AgentShield)?"; then
    curl -fsSL https://ecc.tools/install.sh | bash
    _ok "ecc installed — run /harness-audit to score your current config"
    _warn "Set ECC_HOOK_PROFILE=minimal if you see memory growth from the observer daemon."
  else
    _skip "Everything Claude Code"
  fi
else
  _ok "ecc already installed"
fi

# ── OpenCode (optional — for remote/headless agent server) ───────────────────
if ! command -v opencode &>/dev/null; then
  if _confirm "Install opencode-ai (headless agent server, 75+ model providers — optional)?"; then
    npm install -g opencode-ai
    _ok "opencode installed — run: opencode"
  else
    _skip "opencode-ai"
  fi
else
  _ok "opencode already installed"
fi

# ── Hermes Agent ──────────────────────────────────────────────────────────────
if ! command -v hermes &>/dev/null; then
  if _confirm "Install Hermes Agent (persistent agent with learning loop + messaging gateway)?"; then
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
    _ok "hermes installed — run: hermes setup"
    echo "      Optional: hermes gateway start  (connects Telegram/Discord/Slack)"
  else
    _skip "Hermes Agent"
  fi
else
  _ok "hermes already installed"
fi

# ── jai (Linux sandbox for AI agents) ─────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  if ! command -v jai &>/dev/null; then
    if _confirm "Install jai (Stanford Linux sandbox — containment for AI agents, no Docker)?"; then
      # Try AUR first (Arch), otherwise build from source
      if command -v yay &>/dev/null; then
        yay -S jai
      else
        echo "  Building from source..."
        TMP="$(mktemp -d)"
        git clone https://github.com/stanford-scs/jai.git "$TMP/jai"
        cd "$TMP/jai"
        ./autogen.sh && ./configure && make && sudo make install
        sudo systemd-sysusers
        cd - >/dev/null
        rm -rf "$TMP"
      fi
      jai --init
      _ok "jai installed — run: jai claude  (to sandbox a Claude session)"
    else
      _skip "jai"
    fi
  else
    _ok "jai already installed"
  fi
else
  _warn "jai is Linux-only — skipping on $OS"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo " Manual steps remaining:"
echo "========================================"
echo ""
echo "  Claude Code plugins (run inside Claude Code):"
echo "    /plugin install superpowers@claude-plugins-official"
echo "    /plugin marketplace add EveryInc/compound-engineering-plugin"
echo "    /plugin marketplace add jarrodwatts/claude-hud"
echo "    /plugin marketplace add mvanhorn/last30days-skill"
echo ""
echo "  MCP servers (need API keys in ~/.env or .env):"
echo "    claude mcp add brave-search -e BRAVE_API_KEY=BSA_... -- npx -y @modelcontextprotocol/server-brave-search"
echo "    claude mcp add mem0-mcp --scope global   # after adding key to mcp.json"
echo "    npx -y @deepwiki/mcp   # deepwiki (no key needed)"
echo ""
echo "  Agent-Reach (tell Claude to install it):"
echo "    'Help me install Agent Reach: https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md'"
echo ""
echo "  Heavier infrastructure (see docs/ai-champion.md for details):"
echo "    DeerFlow    → docker compose up  (github.com/bytedance/deer-flow)"
echo "    Open SWE    → LangGraph Cloud deploy  (github.com/langchain-ai/open-swe)"
echo "    Project NOMAD → offline AI stack  (github.com/Crosstalk-Solutions/project-nomad)"
echo "    Superset    → macOS app  (github.com/superset-sh/superset)"
echo ""
echo "Done."
