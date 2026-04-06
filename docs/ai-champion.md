# AI Champion — Becoming More Effective with AI Coding Agents

A personal learning plan built from 130+ weeklyfoo newsletter issues.
Everything here has been sourced from real practitioner articles, not vendor docs.

This guide covers three CLI-based agent tools: **Claude Code**, **GitHub Copilot CLI**, and **Gemini CLI**.
Most concepts apply to all three. Where a tool, command, or capability is specific to one, it is labelled.

---

## The Maturity Model

Before diving into tools, a map of where things go. From Bassim Eledath's
[8 Levels of Agentic Engineering](https://www.bassimeledath.com/blog/levels-of-agentic-engineering)
(weeklyfoo #128) — the clearest progression I've found:

| Level | Name | What it means |
|---|---|---|
| 1 | Tab complete | Copilot-style autocomplete |
| 2 | Agent IDE | Cursor-style multi-file chat + plan mode |
| 3 | Context engineering | CLAUDE.md, system prompts, information density |
| 4 | Compounding engineering | Plan → Delegate → Assess → Codify loop |
| 5 | MCP and Skills | Capability expansion, team skill registries |
| 6 | Harness engineering | Feedback loops, tests, linters as agent backpressure |
| 7 | Background agents | Async orchestration, multi-model dispatch |
| 8 | Autonomous agent teams | Multi-agent coordination — still experimental |

> "Most of you should focus on Level 7. Level 8 is where the leverage eventually is, but not yet for day-to-day work."

**Start at Level 4 and work up.** Level 3 (CLAUDE.md) you already have — the CLAUDE.md in this repo is a working example. Each higher level builds on the previous; jumping to parallel agents without a solid skills and MCP foundation creates coordination overhead without the leverage.

---

## Tool Coverage Reference

How the three tools compare across the capabilities in this guide:

| Capability | Claude Code | Gemini CLI | Copilot CLI |
|---|---|---|---|
| Context file | `CLAUDE.md` | `GEMINI.md` | `copilot-instructions.md` / `AGENTS.md` |
| Skills (`SKILL.md`) | Yes — lazy-loaded | Via extensions | Via `.github/agents/*.md` |
| MCP servers | Yes | Yes — via `settings.json` or extensions | Yes — VS Code settings only, not CLI-native |
| Hooks / lifecycle events | Yes — `settings.json` hooks | Partial — `excludeTools` in extensions | No |
| compound-engineering | Yes | Yes (`--to gemini`) | Yes (`--to copilot`) |
| Superpowers plugin | Yes | Yes | No |
| Everything Claude Code | Yes | Yes | No |
| RTK token compression | Yes (`rtk init -g`) | Yes (`rtk init -g --gemini`) | Yes |
| last30days skill | Yes | Yes | No |
| pi-self-learning memory | Yes | No | No |
| mem0 MCP memory | Yes | Yes | Via VS Code only |
| claude-hud status bar | Yes | No | No |
| Rudel analytics | Yes | No | No |
| jai sandbox | Yes | No documented support | No documented support |
| Agent teams (parallel) | Yes (experimental) | No (use DeerFlow/OpenCode) | No |

**Bottom line:** Claude Code has the deepest tooling ecosystem. Gemini CLI has solid MCP and skills support and works with most of the cross-platform stack. Copilot CLI's extensibility is VS Code-centric — the CLI itself has no hook system, no plugin marketplace, and no native context visibility.

---

## STEP 0 — Your AI Resources Repository

**Do this before anything else.** Every tool, skill, config, MCP definition, and hook
you set up is worthless if it lives only on one machine. The repo is the foundation.

### Structure and starter content

Below is the full directory layout with starter content for each file. Copy what's useful,
delete what isn't. The files grow as you work through this plan.

```
ai-kit/
  .gitignore
  .env                       # real keys — NEVER committed
  README.md
  claude/
    CLAUDE.md.global
    mcp.json.template
    settings.json.template
    hooks/
      post-tool-use.sh
    skills/                  # symlinked into ~/.claude/skills/
  copilot/
    copilot-instructions.md
  gemini/
    GEMINI.md.global
  memory/
    CORE.md
  tools/
    setup.sh
    sync.sh
    install-tools.sh
  dotfiles/
    .zshrc.ai
```

---

**`.gitignore`**
```
.env
*.local
```

---

**`.env`** (never committed — fill in real values)
```bash
ANTHROPIC_API_KEY=sk-ant-...
BRAVE_API_KEY=BSA_...
XAI_API_KEY=xai-...
MEM0_API_KEY=m0-...
```

---

**`claude/CLAUDE.md.global`** — your personal defaults, loaded in every session
```markdown
# Global defaults

## Communication style
- Respond concisely. No filler, no preamble, no trailing summaries.
- No emojis unless I ask.
- When referencing code, include file:line so I can jump directly.

## Behavior
- Never add features beyond what was asked.
- Never modify tests to make them pass.
- Don't add comments to code you didn't change.
- Ask before adding external dependencies.

## When stuck
- Diagnose before switching approaches. Read the error.
- If blocked after investigation, surface the blocker — don't silently retry.
```

---

**`claude/mcp.json.template`** — MCP config with keys as variables (fill from `.env`)
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" }
    },
    "deepwiki": {
      "command": "npx",
      "args": ["-y", "@deepwiki/mcp"]
    },
    "mem0": {
      "type": "http",
      "url": "https://mcp.mem0.ai/mcp",
      "env": { "MEM0_API_KEY": "${MEM0_API_KEY}" }
    }
  }
}
```

---

**`claude/settings.json.template`**
```json
{
  "model": "claude-sonnet-4-6",
  "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": false,
  "hooks": {
    "PostToolUse": [
      { "command": "bash ${AI_KIT_REPO}/claude/hooks/post-tool-use.sh" }
    ]
  }
}
```

---

**`claude/hooks/post-tool-use.sh`** — fires after every tool call; add your linter here
```bash
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
```

---

**`copilot/copilot-instructions.md`** — used as `.github/copilot-instructions.md`
```markdown
## Communication
Respond concisely. No filler, no preamble.

## Coding
- TypeScript strict mode, no `null`, prefer `undefined`.
- Functional components, no `React.FC`.
- Never modify tests to make them pass.
- Ask before adding dependencies.

## Git
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`.
```

---

**`gemini/GEMINI.md.global`** — symlinked to `~/.gemini/GEMINI.md`
```markdown
# Gemini global defaults

Respond concisely. No filler.
Never add features beyond what was asked.
When stuck, surface the blocker rather than retrying silently.
```

---

**`memory/CORE.md`** — promoted durable learnings; populated by pi-self-learning over time
```markdown
# CORE — Durable learnings

This file is written by the pi-self-learning hook.
Each entry was promoted because it recurred across multiple sessions.

<!-- entries will appear here after running /learning-month -->
```

---

**`tools/setup.sh`** — run once on a new machine
```bash
#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Linking Claude global config..."
mkdir -p ~/.claude/skills
ln -sf "$REPO/claude/CLAUDE.md.global" ~/.claude/CLAUDE.md
ln -sf "$REPO/claude/skills" ~/.claude/skills

echo "==> Writing MCP config from template (keys from .env)..."
if [[ -f "$REPO/.env" ]]; then
  set -a; source "$REPO/.env"; set +a
fi
envsubst < "$REPO/claude/mcp.json.template" > ~/.claude/mcp.json

echo "==> Linking Gemini global config..."
mkdir -p ~/.gemini
ln -sf "$REPO/gemini/GEMINI.md.global" ~/.gemini/GEMINI.md

echo "==> Sourcing AI dotfiles..."
if ! grep -q "zshrc.ai" ~/.zshrc 2>/dev/null; then
  echo "source $REPO/dotfiles/.zshrc.ai" >> ~/.zshrc
fi

echo "Done. Open a new shell to pick up dotfile changes."
```

---

**`tools/sync.sh`** — pull latest and re-apply
```bash
#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$REPO" pull --ff-only
bash "$REPO/tools/setup.sh"
echo "Synced."
```

---

**`dotfiles/.zshrc.ai`** — AI-related shell aliases (no keys here)
```bash
# AI aliases — sourced from ~/.zshrc via tools/setup.sh

# Quick Claude Code session in current dir
alias cc="claude"
alias cca="claude --auto-mode"

# Sync ai-kit from any machine
alias ai-sync="bash $AI_KIT_REPO/tools/sync.sh"

# RTK shortcuts
alias rg="rtk grep"   # replace ripgrep with token-optimized version in AI sessions
                       # remove this if you use rg outside of AI contexts

# Load keys for current shell session (never in .zshrc directly)
alias ai-env="set -a && source $AI_KIT_REPO/.env && set +a && echo 'AI env loaded'"
```

### The sync model

Everything must be:
1. **Committed** — all configs in git, API keys only in `.env` (gitignored)
2. **Templated** — any file with secrets becomes a `.template` with `${VAR_NAME}` placeholders; `setup.sh` uses `envsubst` to fill them from `.env`
3. **Idempotent** — `setup.sh` can run twice safely; it symlinks rather than copies

### What to track

As you work through this plan, commit each artifact you create: skill files, CLAUDE.md
iterations, MCP configs, hook scripts, memory updates. The repo is the canonical source.
A new machine goes from zero to your full setup with:

```bash
git clone git@github.com:urbanisierung/ai-kit.git ~/github.com/urbanisierung/ai-kit
cp ~/github.com/urbanisierung/ai-kit/.env.example ~/github.com/urbanisierung/ai-kit/.env   # fill in real keys
bash ~/github.com/urbanisierung/ai-kit/tools/setup.sh
```

---

## LEVEL 3 — Context Engineering

Every major agentic tool loads a context file at session start. The file teaches the agent your preferences, constraints, and project conventions — once, rather than on every prompt.

| Tool | File | Location | Loading behavior |
|---|---|---|---|
| **Claude Code** | `CLAUDE.md` | Repo root, subdirectories, `~/.claude/CLAUDE.md` (global) | Hierarchical: root + subdirs loaded for relevant subtrees; global always loaded |
| **Copilot CLI / VS Code** | `copilot-instructions.md` or `AGENTS.md` | `.github/copilot-instructions.md` or repo root | Loaded on every conversation, fully |
| **Gemini CLI** | `GEMINI.md` | Repo root or `~/.gemini/GEMINI.md` (global) | Root file auto-discovered; global always loaded |

`AGENTS.md` at repo root is an emerging open standard recognized by all four tools (Claude, Copilot, Gemini, Cursor). Writing one file gives all agents the same baseline.

### Claude Code specifics
- **Subdirectory CLAUDE.md** files are loaded only when Claude works in that subtree — useful in a monorepo
- **The @imports system**: `See @docs/api-patterns.md for API conventions` keeps the main file lean
- **The compounding pattern**: after each session where you correct Claude, add a rule. After 10 sessions, prune what hasn't fired. The goal is 100 lines max.

### Copilot specifics
- No lazy loading — the full file is sent on every message. Keep it tight.
- Enable `AGENTS.md` in VS Code: `"chat.useAgentsMdFile": true` in settings
- Agent profiles (`.github/agents/*.md`) create named agents that appear in the VS Code agent picker

### Gemini CLI specifics
- `GEMINI.md` at repo root is auto-discovered when `gemini` is run from that directory
- `~/.gemini/GEMINI.md` is the global equivalent of Claude's `~/.claude/CLAUDE.md`
- Global config: `~/.gemini/settings.json` — API keys, model selection, temperature

**Sources:**
- [The Complete Guide to CLAUDE.md](https://www.builder.io/blog/claude-md-guide) — Builder.io (weeklyfoo #120)
- [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — CLAUDE.md derived from Karpathy's LLM coding pitfall observations (weeklyfoo #124)

---

## LEVEL 5 — Skills / Extensions Across Tools

### The pattern is the same everywhere

Every major agentic tool now has a structured way to extend the agent's behavior beyond the base system prompt. The names differ; the concept is identical: a metadata file that routes the agent to a specialized procedure.

| Tool | Config equivalent | Skills / extensions |
|---|---|---|
| **Claude Code** | `CLAUDE.md` / `CLAUDE.local.md` | `.claude/<skill>/SKILL.md` — loaded on-demand by description |
| **GitHub Copilot** | `.github/copilot-instructions.md` or `AGENTS.md` | `.github/agents/*.md` + VS Code Extensions Marketplace |
| **Gemini CLI** | `GEMINI.md` (repo root or `~/.gemini/`) | `~/.gemini/extensions/<name>/gemini-extension.json` |
| **Cursor** | `.cursorrules` (legacy), `AGENTS.md` | `.cursor/rules/*.md` (auto-discovered) |

`AGENTS.md` at repo root is an emerging open standard recognized by all four tools above.
If you write one file, all agents pick it up.

### Claude Code Skills

Reusable prompts — optionally bundled with scripts or reference docs — that extend
Claude's capabilities without permanently consuming context. Stored as `SKILL.md` files
at `.claude/<skill-name>/SKILL.md`.

**The clever mechanism:** Progressive disclosure. Claude reads only the skill *metadata*
(name + description) at session start. The full body is loaded on-demand when Claude
judges it relevant. Keeps context lean.

> "Skills are a way to encode routine tasks you execute, or want to share with the team." — David Cramer (Sentry)

`SKILL.md` structure:
```markdown
---
name: your-skill-name
description: Short, keyword-rich description. Claude uses this to decide whether to load the skill.
---

## When to use this skill
[trigger conditions]

## Steps
1. [step]
2. [step]

## Success criteria
- [what done looks like]
```

> "The description is for routing, not reading. It needs to be short, specific, and packed with the keywords your tasks will actually use."

### GitHub Copilot equivalent

**Instructions file:** `.github/copilot-instructions.md` — same principle as CLAUDE.md.
Copilot reads it on every conversation. Markdown, any length, committed to repo.

**Agent profiles:** `.github/agents/*.md` — scoped custom agents. Each file is a named
agent with its own system prompt and tool access. Copilot in VS Code shows them in the
agent picker dropdown.

**Extensions ecosystem:** 208+ community skills, 175+ agents in the
[github/awesome-copilot](https://github.com/github/awesome-copilot) directory.
Skills are the same open standard as Claude — a `SKILL.md` file works across both.

Enable agents in VS Code: `"chat.useAgentsMdFile": true` in settings.

### Gemini CLI equivalent

**Instructions file:** `GEMINI.md` at repo root (auto-discovered) or `~/.gemini/GEMINI.md`
for global defaults. Same as CLAUDE.md.

**Extensions:** stored in `~/.gemini/extensions/<name>/`. Each extension has:
```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "mcpServers": [...],
  "contextFileName": "GEMINI.md",
  "excludeTools": ["run_shell_command(rm -rf)"]
}
```
Extensions bundle MCP servers, custom instructions, and blocked tool lists.
They're auto-discovered at startup. No install command — just drop the folder.

**Global config:** `~/.gemini/settings.json` — API keys, model selection, temperature.

### The skills registry

[skills.sh](https://skills.sh/) — 90,000+ community skills, sorted by usage.

Top skills by usage (starting points worth studying):
| Skill | Uses | What it does |
|---|---|---|
| `find-skills` (vercel-labs) | 759K | Searches the skills registry |
| `vercel-react-best-practices` (vercel-labs ⭐24k) | 257K | 40+ rules across 8 React categories |
| `frontend-design` (Anthropic) | 213K | Design system best practices |
| `skill-creator` (Anthropic) | 113K | Meta: a skill for creating skills — start here |
| `agent-browser` (vercel-labs) | 138K | CLI-based web browsing |

### Skills that ship with npm packages

Libraries now ship skills alongside their packages. Skills in `node_modules` travel
with `npm update` — no stale copy-pasted rules files.

> "Skills ship inside your npm package. They travel with the tool via npm update — not the model's training cutoff, not community-maintained rules files." — TanStack

Already adopted by VS Code, GitHub Copilot, Cursor, Claude Code, Amp, Goose, and others.

**Source:** [TanStack Intent: Ship Agent Skills with npm packages](https://tanstack.com/blog/from-docs-to-agents) (weeklyfoo #128)

### Superpowers — the complete agentic workflow plugin

> "An agentic skills framework & software development methodology that works." — Jesse Vincent

[github.com/obra/superpowers](https://github.com/obra/superpowers) — the most complete out-of-the-box skills setup available.

**Install:**
```
/plugin install superpowers@claude-plugins-official
```

**What it does:** Instead of jumping straight to code, Claude is guided through:
1. **Brainstorm** — surfaces requirements gaps before any code is written
2. **Branch setup** — creates an isolated git worktree automatically
3. **Task planning** — decomposes into 2–5 minute atomic tasks with explicit deliverables
4. **Implementation** — executes via subagent coordination with review checkpoints
5. **Test loop** — enforces RED → GREEN → REFACTOR (won't proceed until tests pass)
6. **Code evaluation** — structured review against the original plan
7. **Completion** — branch merge or PR creation

**Skills that actually ship with it** (visible via `/context` description listing):

| Skill | Description tokens | What it does |
|---|---|---|
| `brainstorming` | ~56 | Ideation and requirements exploration phase |
| `writing-plans` | ~28 | Structured plan authoring |
| `executing-plans` | ~33 | Plan execution with checkpoints |
| `using-git-worktrees` | ~59 | Isolated worktree setup per feature |
| `subagent-driven-development` | ~31 | Delegate subtasks to focused subagents |
| `dispatching-parallel-agents` | ~37 | Coordinate agents running in parallel |
| `test-driven-development` | ~29 | RED → GREEN → REFACTOR enforcement |
| `systematic-debugging` | ~31 | Structured failure diagnosis |
| `requesting-code-review` | ~36 | Prepare work for review |
| `receiving-code-review` | ~67 | Process and apply review feedback |
| `verification-before-completion` | ~67 | Quality gate before marking done |
| `finishing-a-development-branch` | ~61 | Branch cleanup and merge/PR flow |
| `writing-skills` | ~31 | Meta: create new SKILL.md files |
| `using-superpowers` | ~47 | Meta: orientation to the plugin itself |

The description token counts matter: they're the cost of routing every session,
whether Claude uses the skill or not. Superpowers sits at 650–700 tokens of descriptions
loaded on every turn — worthwhile given what it provides, but be aware.

**Available in:** Claude Code, Cursor (marketplace), Codex, Gemini CLI, OpenCode.

**Source:** weeklyfoo #125

### compound-engineering-plugin ⭐12K

[github.com/EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) —
the practical implementation of Level 4 (Compounding Engineering). Where Superpowers
enforces a linear task workflow, compound-engineering focuses on making each cycle of work
improve future cycles. The philosophy: 80% planning and review, 20% execution.

**Install:**

*Claude Code:*
```
/plugin marketplace add EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

*Gemini CLI, Copilot, Cursor, and others:*
```bash
bunx @every-env/compound-plugin install compound-engineering --to gemini
bunx @every-env/compound-plugin install compound-engineering --to copilot
bunx @every-env/compound-plugin install compound-engineering --to cursor
# all targets: cursor | gemini | codex | opencode | copilot | kiro | windsurf
```

**Six commands:**

| Command | What it does |
|---|---|
| `/ce:ideate` | Discover high-impact improvements through divergent ideation |
| `/ce:brainstorm` | Explore and clarify requirements |
| `/ce:plan` | Convert feature requests into technical roadmaps |
| `/ce:work` | Execute the plan with worktree isolation and task tracking |
| `/ce:review` | Multi-agent code review before merging |
| `/ce:compound` | Document learnings for future reuse — the compounding step |

The `/ce:compound` command is the differentiator: after each task, it extracts what was
learned and codifies it so future sessions start smarter. This is the Codify step in the
Level 4 loop made explicit and automated.

Actively maintained (v2.60.0 as of April 2026, 57 open issues with active triage).

### Real-world skills to study
- [Sentry's internal skills](https://github.com/getsentry/skills) — PR review skill that
  conditionally launches subagents (database safety, complexity analysis, prompt health, linting)
- [jezweb/claude-skills](https://github.com/jezweb/claude-skills) — Full-stack Cloudflare,
  React, Tailwind v4, AI integrations (weeklyfoo #124)
- [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) — react-best-practices,
  web-design-guidelines, composition-patterns (weeklyfoo #120)
- [korthout/mac](https://github.com/korthout/mac/tree/main/.claude/skills) — personal dotfiles
  with a numbered skill convention worth copying: `1_research_codebase` → `2_create_plan` →
  `3_validate_plan` → `4_implement_plan`. The numeric prefix forces the agent to respect
  the sequence. Also includes a `github_create_issue` skill for programmatic issue creation.

### Everything Claude Code ⭐130K

[github.com/affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) —
the most comprehensive agent harness optimization available. Not a tool you run, but
infrastructure you install that changes how your agent harness behaves.

**What's actually in it:**
- **150+ skills** spanning every development domain: language-specific patterns (Python, Go, Rust,
  Kotlin, Java, C++, Swift, Perl), agentic infrastructure (`continuous-agent-loop`,
  `eval-harness`, `context-budget`, `token-budget-advisor`), domain skills
  (`healthcare-phi-compliance`, `deep-research`, `exa-search`), and meta-skills
  (`continuous-learning`, `rules-distill`, `codebase-onboarding`)
- **70+ slash commands**: `/plan`, `/orchestrate`, `/multi-execute`, `/learn`, `/learn-eval`,
  `/harness-audit`, `/loop-start`, `/quality-gate`, `/model-route`, `/resume-session`
- **Hooks** (`hooks.json`): session summaries on stop, memory persistence, context loading
  on start, pattern extraction for learning, security scanning on PreToolUse
- **Rules** for 12 language ecosystems — injected into agent context automatically
- **AgentShield** (`ecc-agentshield` npm package): pre-execution security scanning for
  prompt injection, credential exfiltration, sandbox escape patterns
- **Observer daemon**: background process that monitors sessions, extracts patterns,
  adds them to skill files (v1.9.0 includes throttling fix after a memory explosion issue)
- **Cross-harness**: same install works for Claude Code, Codex, Cursor, OpenCode, Gemini CLI,
  Kiro — each gets its own config directory (`.claude/`, `.codex/`, `.cursor/`, etc.)

**Install:**
```bash
# Linux/macOS
curl -fsSL https://ecc.tools/install.sh | bash

# Security only
npm install -g ecc-agentshield
```
The v1.9.0 selective install (`install-plan.js`) lets you pick components rather than
install everything at once.

**How to start:** Don't try to use all 150+ skills. Run `/harness-audit` to score your
current configuration, then `/skill-stocktake` to see what's relevant for your stack.
Add `ECC_HOOK_PROFILE=minimal` if you see memory growth from the observer daemon.

**Source:** [ecc.tools](https://ecc.tools)

### last30days-skill ⭐17K

[github.com/mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) —
a Claude Code skill that researches any topic across social media, prediction markets,
and web sources from the past 30 days, then synthesizes a narrative summary with citations.

**Install (one command):**
```
/plugin marketplace add mvanhorn/last30days-skill
/plugin install last30days@last30days-skill
```
Also works in Gemini CLI: `gemini extensions install https://github.com/mvanhorn/last30days-skill.git`

**Usage:**
```
/last30days <topic>                        # full research run (2–8 minutes)
/last30days <topic> --quick                # faster, less depth
/last30days <topic> --days=90              # extend window
/last30days Claude Code vs Codex           # comparative mode — side-by-side table + verdict
```

**Sources queried in parallel:** Reddit (free), Hacker News (free), Polymarket prediction
markets (free), X/Twitter via `bird` cookie extraction (free), YouTube transcripts via
`yt-dlp` (free), Bluesky, Exa/Brave web search, TikTok/Instagram via ScrapeCreators (paid).

**The differentiator:** Polymarket integration. You get real-money probability estimates
alongside community sentiment — unique among research skills. Five-factor market scoring:
text relevance, 24h volume, liquidity, price velocity, outcome competitiveness.

**What to know:** Runs for 2–8 minutes. X cookies expire and need periodic refresh.
ScrapeCreators is pay-as-you-go after 100 free calls (TikTok/Instagram). Every run saves
a full briefing to `~/Documents/Last30Days/<topic>.md` automatically.

**Zero config to start:** Reddit, HN, and Polymarket work immediately with no API keys.

### Agent-Reach ⭐14K

[github.com/Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) —
a scaffolding layer that installs upstream CLI tools so your agent can read and search
social media and web platforms with zero API fees.

**What it gives your agent:**

| Platform | Method | Cost |
|---|---|---|
| Web pages | Jina Reader (`r.jina.ai`) | Free |
| YouTube | `yt-dlp` subtitles | Free |
| Twitter/X | `bird` cookie extraction | Free |
| Reddit | Exa MCP | Free tier |
| GitHub | `gh` CLI | Free |
| Bilibili | `yt-dlp` (proxy req. on servers) | ~$1/mo proxy |
| XiaoHongShu | `xiaohongshu-mcp` (Docker) | Free |
| Weibo, V2EX | Direct requests | Free |
| RSS | `feedparser` | Free |

**Install — tell your agent:**
```
Help me install Agent Reach: https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md
```
The agent fetches the install doc and runs the setup. After install, a `SKILL.md` is
registered so the agent knows which upstream tool to call per platform.

**Diagnostic:**
```bash
agent-reach doctor   # shows which channels are live
```

**What to know:** Architecture is thin by design — each platform maps to an upstream tool,
no wrapper layer. Cookie-based channels (Twitter/X, Bilibili) expire and need periodic
maintenance. Server deployments need a proxy for Bilibili (~$1/month). English README
(`docs/README_en.md`) may lag the main Chinese README on recent changes.

**Best for:** research agents that need to pull from social platforms without paying API fees.
Particularly valuable for Chinese-language platforms (Bilibili, XiaoHongShu, Weibo) that
have no accessible API equivalents in English.

**Sources:**
- [Agent Skills vs. Rules vs. Commands](https://www.builder.io/blog/agent-skills-rules-commands) — Builder.io (weeklyfoo #121)
- [MCP, Skills, and Agents](https://cra.mr/mcp-skills-and-agents/) — David Cramer, Sentry (weeklyfoo #121)

---

## LEVEL 5 — MCP Servers

### What they are
MCP (Model Context Protocol) exposes external services as tools Claude can call.
OAuth-native. Each MCP server provides a set of typed functions Claude can invoke.

### The key tradeoff
> "MCP has gotten a bad rap because of poor implementations: too many tools, very unoptimized."

Every MCP injects its full tool schemas into the context on every turn — whether Claude
uses them or not. Token cost is real. Rule: enable only the MCPs you actually use per session.

**The CLI alternative:** For many use cases, having Claude run a targeted CLI command
(zero schema overhead, only the relevant output enters context) is more efficient than
the equivalent MCP. Not a replacement — a complement.

### High-value MCP servers to try

| MCP | What it does | Get it |
|---|---|---|
| **Playwright** | Browser automation — Claude launches browsers, navigates, screenshots | Built into Claude Desktop |
| **DeepWiki** | Access docs for any open-source repo without pulling them into context manually | deepwiki.com |
| **Brave Search** | Web search with local/news/image results. Free tier: ~1K queries/$5/month | `npx @modelcontextprotocol/server-brave-search` |
| **Grok (xAI)** | Web search + X/Twitter search + code execution. Paid — free tier ended Dec 2024. One-time $25 signup credit; data-sharing program for $150/month (permanent opt-in, no EU/UK) | [github.com/merterbak/Grok-MCP](https://github.com/merterbak/Grok-MCP) |
| **Storybook** | Browse, query, generate React components | [storybook.js.org](https://storybook.js.org/blog/storybook-mcp-for-react/) |
| **Sentry** | Configurable tool groups — enable only read or read+write | [mcp.sentry.dev](https://mcp.sentry.dev/) |
| **Cloudflare Code Mode** | Compresses entire Cloudflare API to ~1,000 tokens via typed SDK | [blog.cloudflare.com](https://blog.cloudflare.com/code-mode-mcp/) |
| **mem0** | Persistent memory across sessions — read/write to a shared memory layer | `npx mcp-add --name mem0-mcp --type http --url "https://mcp.mem0.ai/mcp"` |
| **crosspost** | Post to LinkedIn, X, Bluesky, Mastodon simultaneously | [github.com/humanwhocodes/crosspost](https://github.com/humanwhocodes/crosspost) |

### Search APIs: Brave vs. Grok

**Brave Search API**
- Package: `@modelcontextprotocol/server-brave-search` (official Anthropic MCP)
- Add key: `claude mcp add brave-search -e BRAVE_API_KEY=BSA_YOUR_KEY -- npx -y @modelcontextprotocol/server-brave-search`
- Free tier: $5/month credit ≈ 1,000 queries; attribution required
- Best for: generic web search with no platform lock-in

**Grok / xAI API**
- Sign up at [console.x.ai](https://console.x.ai) — **no ongoing free tier** (ended Dec 2024)
- New accounts get a one-time $25 credit (expires in 30 days)
- Data-sharing program: $150/month credits — but requires $5 prior spend, opt-in is permanent, and unavailable in EU/UK/Iceland/Liechtenstein/Norway
- Adds: web search, X/Twitter-specific search, code execution via `grok-4-1-fast-reasoning`
- Best for: anything where X/Twitter signal matters; be aware it is now a paid service

**Groq (free alternative for general inference)**
- Sign up at [console.groq.com](https://console.groq.com) — no credit card required
- Free tier: up to 14,400 req/day (8B model), 1,000 req/day (70B/Scout models); OpenAI-compatible API
- Best for: fast, free LLM inference when X/Twitter access is not needed

Store both keys in your `ai-kit/.env.example`:
```bash
BRAVE_API_KEY=BSA_...
XAI_API_KEY=xai-...
```

### The Cloudflare approach (worth studying for any API)
> "Instead of describing every operation as a separate tool, let the model write code against a typed SDK and execute the code safely in a Dynamic Worker Loader."

Compresses an entire API surface to ~1,000 tokens. Better than one tool per API endpoint.

**Sources:**
- [MCP, Skills, and Agents](https://cra.mr/mcp-skills-and-agents/) — David Cramer (weeklyfoo #121)
- [Cloudflare Code Mode MCP](https://blog.cloudflare.com/code-mode-mcp/) (weeklyfoo #126)
- [Storybook MCP for React](https://storybook.js.org/blog/storybook-mcp-for-react/) (weeklyfoo #130)

---

## LEVEL 5 — Prompting That Actually Works

### The "why before what" principle
Before any non-trivial task, write one sentence explaining *why* you want the change,
not just *what* it is. The output is measurably better because Claude makes decisions
consistent with the actual intent rather than the surface request.

❌ "Refactor this function"
✅ "Refactor this function because it's being called from three places and the duplication
   makes the error handling inconsistent"

### Constraints over checklists
> "Step-by-step prompting ('do A, then B, then C') is increasingly outdated. Defining
> boundaries works better, because agents fixate on the list and ignore anything not on it."

Better pattern: "Here's what I want, work on it until you pass all these tests."

### What a powerful single prompt looks like
From Hardik Pandya's [Power Prompts in Claude Code](https://hvpandya.com/power-prompts)
(weeklyfoo #122) — this single paragraph triggered parallel agents, visual regression
testing, MCP browser use, CLAUDE.md updates, and skill creation:

> "Optimize my site for performance, accessibility, SEO, and code quality. Before making
> any changes, capture baseline screenshots of all key pages. Run the audit and fixes in
> parallel using multiple agents: one for performance/build, one for accessibility, one
> for SEO, one for code cleanup. After all changes are complete, take screenshots at
> desktop, tablet, and mobile breakpoints and compare with baseline to make sure nothing
> broke visually. Update CLAUDE.md with what changed. Finally, create a reusable skill
> so I can run this same audit workflow in the future."

### Plan first, then implement
Use Plan Mode (`Shift+Tab`) to iterate on the plan before any code is written.
The [bicameral-ai piece](https://www.bicameral-ai.com/blog/tech-debt-meeting) (weeklyfoo #124)
documents why: AI jumps to implementation and bypasses the exploratory thinking
that surfaces actual constraints. Slow down at the planning stage.

### The inline annotation pattern
When conversational back-and-forth is imprecise: edit your spec file directly,
add `%%` annotations, then tell Claude `check %% notes`. More precise than describing
what you want in chat.

### End sessions with a summary request
Before closing a long session: "Summarize what we changed, what assumptions you made
that I should know about, and what you'd do differently if we were starting fresh."
The assumptions section surfaces things you'd otherwise discover three days later.

### Don't let the same model grade its own exam
If the same Claude instance implements and evaluates its own work, it will gloss over
issues. Have a different session (or a different model) do the review pass.

**Sources:**
- [Power Prompts in Claude Code](https://hvpandya.com/power-prompts) (weeklyfoo #122)
- [where good ideas come from (for coding agents)](https://sunilpai.dev/posts/seven-ways/) (weeklyfoo #119)
- [Why 'just prompt better' doesn't work](https://www.bicameral-ai.com/blog/tech-debt-meeting) (weeklyfoo #124)

---

## LEVEL 5 — Token Management

Context window budget is finite and costs money. Most practitioners don't measure it until
it hurts. Start measuring early.

### Run /context first

```
/context
```

This command shows exactly what's consuming your context before any task starts: System
Prompt, MCP Tools, Memory Files. Common finding: 30–40% of the window is gone before
you've typed a word, usually from MCP servers you mounted and forgot about. Every
mounted MCP injects its full tool schemas on every turn whether Claude uses them or not.

**Immediate wins:**
- Disable MCPs not needed in the current session
- Trim CLAUDE.md to under 100 lines. Add one rule: "Respond as concisely as possible;
  remove unnecessary politeness."
- If the topic changes mid-session, use `/clear` or start a new session. Claude Code
  sends the full conversation history with every message — carrying off-topic history
  is pure waste.

### Use the right model for the task

Ultrathink and Opus are powerful but expensive. Deep thinking is only necessary for
complex architecture and hard logical reasoning. For running tests, making small edits,
or scaffolding repetitive code: Sonnet is more than enough and costs a fraction.

Pattern: **Opus for planning and hard reasoning, Sonnet for execution and review.**

### RTK — Rust Token Killer ⭐16K

[github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk) — a Rust binary that sits between
your agent and shell commands. When Claude runs `git status`, RTK intercepts it, applies
compression (filtering, grouping, deduplication, truncation), and returns a token-optimized
version. The LLM never sees raw noisy output.

**Measured savings in a medium TypeScript/Rust project (30-min session):**

| Operation | Standard | With RTK | Savings |
|---|---|---|---|
| `ls`/`tree` ×10 | 2,000 tok | 400 tok | 80% |
| `cat`/`read` ×20 | 40,000 tok | 12,000 tok | 70% |
| `grep`/`rg` ×8 | 16,000 tok | 3,200 tok | 80% |
| `git log/diff` ×15 | 13,000 tok | 3,100 tok | 76% |
| Test output ×9 | 33,000 tok | 3,300 tok | 90% |
| **Total** | **~118,000** | **~23,900** | **~80%** |

**Install:**
```bash
brew install rtk           # macOS — cleanest path

# Linux
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# ⚠️ Do NOT use: cargo install rtk — that's a name collision with "Rust Type Kit"
# Correct cargo path: cargo install --git https://github.com/rtk-ai/rtk

# Install the hook for your agent
rtk init -g                # Claude Code (default)
rtk init -g --gemini       # Gemini CLI
rtk init -g --codex        # Codex / Copilot
```

RTK works across Claude Code, Gemini CLI, Copilot, Cursor, and Windsurf — it's one of the few tools with full coverage across all three tools in this guide.

**Key commands:**
```bash
rtk ls .                   # token-optimized directory tree
rtk read file.rs           # smart file reading
rtk read file.rs -l aggressive  # signatures only, strips function bodies
rtk grep "pattern" .       # grouped search results
rtk git status/log/diff    # compact git output
rtk test cargo/npm/pytest  # test output: passes summarized, failures highlighted
rtk gain                   # show token savings for current session
```

**What to know:**
- The hook only intercepts **Bash tool calls**. Claude Code's native `Read`, `Grep`,
  and `Glob` tools bypass RTK. Steer the agent toward shell equivalents (`cat`, `rg`, `find`)
  for maximum savings, or call `rtk read`/`rtk grep` directly.
- `aggressive` read level strips function bodies — verify the agent gets sufficient context.
- Works across: Claude Code, Copilot, Gemini CLI, Codex, Cursor, Windsurf.
- Linux install: set `TMPDIR=~/.cache/tmp` if you get cross-device link errors.

### claude-hud ⭐16K

[github.com/jarrodwatts/claude-hud](https://github.com/jarrodwatts/claude-hud) — a Claude
Code plugin that renders a live status bar in your terminal: context window usage,
active tools, running subagents, todo progress. Uses the native `statusLine` plugin API.

```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
```

**What it shows:**
- Context window bar (green → yellow → red, color-coded), with token breakdown detail
  appearing automatically above 85% fill
- Rate limits (hour and day usage)
- Tool activity: which tool is running, how many times
- Subagent status: which agent, what it's doing, elapsed time
- Todo progress: current task, X of N

The context bar uses **native token counts from Claude Code** — not estimates. Scales
correctly for 1M-context sessions.

**Why it matters for agentic sessions:** context exhaustion sneaks up on you. Without
visibility, you discover the window is full after the agent has already started
a complex task and has to restart. The subagent elapsed time display also surfaces
runaway agents before they blow up your budget.

Tool/agent/todo lines are off by default — enable via `/claude-hud:configure`.

> Install this and leave it on. It's the clearest observable improvement to the Claude Code
> development loop available as a plugin.

---

## LEVEL 6 — Hooks and Persistent Memory

Hooks (or their equivalent) give the agent a feedback signal without waiting for human review.
The three tools have very different capabilities here.

| Tool | Mechanism | What you can do |
|---|---|---|
| **Claude Code** | `hooks` object in `settings.json` — arbitrary shell commands on lifecycle events (`PostToolUse`, `Stop`, etc.) | Run linters, tests, memory capture, security scans automatically after every tool call |
| **Gemini CLI** | Extensions with `excludeTools` + bundled MCP servers | Block specific dangerous operations; bundle tools the agent can call explicitly — no arbitrary shell hooks |
| **Copilot CLI** | **None** | No hook system exists at the CLI level. Compensate with git-level pre-commit hooks (`lefthook`, `husky`) and manually running linters before accepting output |

### Claude Code: hooks for backpressure

Hooks that run type checks, tests, linters, and pre-commit validation automatically
give the agent a feedback signal — it can detect and correct mistakes without waiting
for human review. "If you want autonomy, you need backpressure."

**Session analytics (Rudel)** — *Claude Code only*
Hook fires on session end, uploads transcript to a dashboard:
token usage, session duration, activity patterns, model usage breakdown.

Setup: `npm install -g rudel && rudel login && rudel enable`

⚠️ Uploads full session transcripts including code and prompts. Use on appropriate projects only.

### Gemini CLI: extensions as partial equivalent

Gemini extensions (`~/.gemini/extensions/<name>/gemini-extension.json`) bundle MCP servers,
custom instructions, and blocked tool lists. This is the closest Gemini has to hooks:

```json
{
  "name": "my-dev-extension",
  "version": "1.0.0",
  "mcpServers": [{ "name": "lint-server", "command": "npx", "args": ["-y", "your-lint-mcp"] }],
  "contextFileName": "GEMINI.md",
  "excludeTools": ["run_shell_command(rm -rf)"]
}
```

You can wrap a linter or test runner as an MCP server and bundle it in the extension,
then instruct Gemini in `GEMINI.md` to call it after writing files. It's more explicit
(Gemini calls the tool by choice) than Claude's automatic PostToolUse hooks, but it
achieves a similar feedback loop.

### Copilot CLI: git-level backpressure

Copilot CLI has no hook system. The practical substitute is enforcing quality gates at
the git layer rather than the agent layer:

```bash
# Example with lefthook (works regardless of which agent wrote the code)
npm install -g @evilmartians/lefthook
# lefthook.yml: pre-commit → run linter; commit-msg → validate format
```

The agent still gets no automatic feedback mid-session, but errors are caught before
they can be committed.

### Persistent memory: three approaches

The memory problem: every new Claude session starts blank. Three ways to solve this,
each with different tradeoffs:

#### 1. pi-self-learning (git-backed, local)
After each completed task, automatically:
- Extracts what went wrong and how it was fixed
- Appends to a daily markdown file
- Updates `CORE.md` with top-ranked durable learnings (frequency + recency scored)
- Commits everything to a dedicated memory git repo

Install: `pi install npm:pi-self-learning`
Commands: `/learning-now`, `/learning-month`, `/learning-toggle`, `/learning-status`

> "Each session builds on the last. The agent is no longer starting from zero."

Commit the resulting `CORE.md` to your `ai-kit/memory/` repo. This is the
sharable, syncable version — pull it on any machine and Claude's memory travels with you.

#### 2. mem0 (vector + graph memory, cloud or self-hosted)

mem0 is a universal memory layer for AI agents. It compresses conversation history
into optimized memory entries using vector search + knowledge graph relationships.
Claims 90% token savings and 91% lower p95 latency vs. full context replay.

**Cloud (simplest):**
```bash
# Sign up at app.mem0.ai, then:
claude mcp add mem0-mcp --scope global
# Add to MCP config:
# npx mcp-add --name mem0-mcp --type http --url "https://mcp.mem0.ai/mcp"
```

**Self-hosted (data sovereignty):**
Uses Qdrant (vector store) + Neo4j (knowledge graph) + Ollama (embeddings).
```bash
pip install mem0ai
# or
npm install mem0ai
```
See [dev.to/n3rdh4ck3r](https://dev.to/n3rdh4ck3r/how-to-give-claude-code-persistent-memory-with-a-self-hosted-mem0-mcp-server-h68) for the full self-hosted setup.

**What mem0 does that pi-self-learning doesn't:**
- Stores memory from multiple agents and sessions in one queryable layer
- Semantic search over past context (not just file read)
- Cross-machine without git sync — the server is the source of truth
- Shareable across team members (same mem0 org)

**What pi-self-learning does better:**
- Fully offline / no external service
- Version-controlled history (git)
- Human-readable CORE.md you can edit directly

**Practical setup:** use both. pi-self-learning for distilled lessons you edit by hand;
mem0 for raw session context retrieval. Store the mem0 API key in your
`ai-kit/dotfiles/.env.template`.

#### 3. Cog (self-reflection architecture)
Persistent memory + self-reflection in a more structured form.
[github.com/marciopuga/cog](https://github.com/marciopuga/cog) — medium complexity, worth
reading the architecture even if you don't deploy it.

### Sandbox containment: jai

[jai.scs.stanford.edu](https://jai.scs.stanford.edu/) — Stanford SCS lightweight Linux sandbox
for AI agents. One-command containment with no Docker, no images, no configuration overhead.
Developed in response to real data-loss incidents from unintended `rm -rf` and destructive
operations in Claude Code, Cursor, and similar tools.

**How it works:** Wraps the agent process with a copy-on-write filesystem overlay. Changes are
isolated from your real home directory — you can see what would have changed, then discard or
apply. Three modes:

| Mode | What it does | Use it for |
|---|---|---|
| `casual` | Copy-on-write overlay, runs as your user | Day-to-day experimentation |
| `bare` | Hidden home directory, medium protection | Testing new hooks/skills |
| `strict` | Separate UID isolation | Running untrusted agent workflows |

**Install (Linux):**
```bash
# Arch (AUR)
yay -S jai

# From source
git clone https://github.com/stanford-scs/jai.git
cd jai && ./autogen.sh && ./configure && make && sudo make install
sudo systemd-sysusers
jai --init
```

**Usage:**
```bash
jai claude                   # run Claude Code inside the sandbox
jai --mode strict claude     # stronger isolation
jai --mode casual bash       # drop into a sandboxed shell
```

**When to use it:**
- Before running a new skill or hook for the first time
- When testing any agent that writes files or runs shell commands
- Before delegating a long autonomous task where you can't watch every step

> Pairs naturally with the Level 6 harness pattern: the hook gives the agent backpressure,
> jai contains the blast radius if it still goes wrong.

**Sources:**
- [Your Coding Agent Keeps Making the Same Mistakes](https://adventures.nodeland.dev/archive/your-coding-agent-keeps-making-the-same-mistakes/) — Matteo Collina (weeklyfoo #128)
- [Rudel](https://github.com/obsessiondb/rudel) (weeklyfoo #128)
- [mem0ai/mem0](https://github.com/mem0ai/mem0), [mem0.ai/blog/claude-code-memory](https://mem0.ai/blog/claude-code-memory)

---

## LEVEL 7 — Agents and Agent Teams

This is where the leverage is. Understanding the architecture is prerequisite to using it well.

### What an agent actually is

An agent is a model in a loop: it receives context (your prompt + tool results + conversation history),
produces an action (tool call or text), executes the action, and feeds the result back in.
The loop runs until a stop condition (task complete, error, token limit, or human intervention).

The key properties that make agents different from single-prompt interactions:
- **State persistence** — context accumulates within a session
- **Tool use** — the model can take actions in the world (read files, run code, call APIs)
- **Self-correction** — the model sees the output of its own actions and can adjust
- **Goal-directed** — given a high-level objective, it decomposes and pursues sub-goals

### Why single agents fail at scale

A single agent working on a large codebase runs into three walls:
1. **Context limit** — everything it needs to know eventually exceeds the context window
2. **Attention degradation** — long contexts cause the model to "forget" early instructions
3. **Serialization** — it can only do one thing at a time

Agent teams solve all three.

### Agent team architectures

**Orchestrator + Workers (most common)**

One "team lead" agent holds the high-level plan. It dispatches subtasks to worker agents,
each with a narrow context (just what they need). Workers report back; the orchestrator
integrates results.

```
User → [Orchestrator]
         ├── [Worker A: write tests]
         ├── [Worker B: refactor function]
         └── [Worker C: update docs]
```

Workers run in parallel. Each has its own context window. The orchestrator doesn't need
to know every detail — it manages the spec, not the implementation.

**Key finding from Anthropic's 16-agent C compiler experiment:**
Without a defined hierarchy, agents become risk-averse and churn without progress.
The team lead role is not optional. Structure produces results; flat teams stall.

**Peer-to-peer (Claude Code Agent Teams)**
Workers communicate directly with each other, not only up to the orchestrator.
Faster coordination on interdependent tasks, but harder to reason about.

**Subagent delegation (within a single session)**
Claude Code's built-in `Agent` tool spawns a fresh subagent in a clean context.
The spawning agent gives it a full brief, the subagent returns a result.
Used in Sentry's PR review skill: one orchestrating skill → 4 specialized subagents
→ results aggregated. No extra tooling required.

### How to run agent teams today

**Official Claude Code Agent Teams** (experimental, built-in)

Enable:
```json
// In Claude Code settings.json
{ "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": true }
```
Requires Claude Code v2.1.32+.

Modes:
- **in-process** — multiple agents share one terminal
- **split panes** — each agent gets its own pane in tmux/iTerm2

One session is the Team Lead, others are independent workers with shared task lists.
Workers communicate directly with each other.

[Docs](https://code.claude.com/docs/en/agent-teams) (weeklyfoo #123)

**FD (Feature Design) system** — most battle-tested parallel setup

Every feature gets a numbered spec file (FD-001, FD-002…) with problem statement,
solutions considered, final plan, and verification steps. Agents work from spec, not chat.

Three tmux window roles: **Planner** (builds specs), **Worker** (implements), **PM** (backlog)

Six slash commands: `/fd-new`, `/fd-status`, `/fd-explore`, `/fd-deep` (4 parallel Opus agents),
`/fd-verify`, `/fd-close`

Bootstrap: `/fd-init`

> "The bottleneck shifts to spec quality and coordination, not code generation capacity."

Practical ceiling: 4–8 agents before coordination overhead exceeds parallelism gain.

**Source:** [How I run 4–8 parallel coding agents with tmux and Markdown specs](https://schipper.ai/posts/parallel-coding-agents/) — Manuel Schipper (weeklyfoo #127)

**Dispatch skill** — orchestrator pattern, no extra tooling

[github.com/bassimeledath/dispatch](https://github.com/bassimeledath/dispatch)

> "The dispatcher plans, delegates, and tracks, so your main context window is preserved
> for orchestration. When a worker gets stuck, it surfaces a clarifying question rather
> than silently failing."

**Superset** — macOS app for parallel agents

Run 10+ agents simultaneously, each in its own git worktree. Built-in terminal, diff viewer,
review workflow. [github.com/superset-sh/superset](https://github.com/superset-sh/superset)

### Orchestration layers: three deployment patterns

These are not competing with Claude Code — they are layers *above* it for specific contexts.
Pick based on what you're trying to accomplish.

**DeerFlow ⭐56K — self-hosted super-agent with web UI**

[github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow) — ByteDance's
open-source long-horizon agent harness. You give it a high-level objective ("research X",
"build this feature", "write a report on Y") and it orchestrates a multi-agent pipeline
to execute it — potentially over minutes to hours with minimal supervision.

**Architecture:**
- Python + LangGraph backend, React/TypeScript web frontend
- Sub-agents spawned on demand, each with scoped context, parallel where possible
- Sandboxed bash execution (Docker via `AioSandboxProvider`, or file-only local mode)
- Skills stored as `SKILL.md` files, loaded lazily — ships with: `research`,
  `report-generation`, `slide-creation`, `image-generation`, `claude-to-deerflow`
- Supports any LangChain-compatible model. Notably: `ClaudeChatModel` and `CodexChatModel`
  providers let you use paid subscriptions (Claude Code OAuth, Codex CLI) rather than
  per-token API billing.
- `claude-to-deerflow` skill: dispatch tasks from your terminal directly to a running
  DeerFlow instance over HTTP

**Install:**
```bash
git clone https://github.com/bytedance/deer-flow && cd deer-flow
make config    # generates config.yaml, fill in your model provider
docker compose up
```

**What to know:** v2.0 is a ground-up rewrite from Feb 2026 — shares no code with v1.
ByteDance recommends their own models (Doubao, DeepSeek, Kimi) in the UI.
Bash execution requires Docker; without it, only file I/O works.
The `claude-to-deerflow` skill requires DeerFlow running at `localhost:2026`.

**Best for:** long-horizon tasks (research reports, multi-file feature work, slide decks)
you want to delegate fully and review when complete.

---

**Hermes Agent ⭐21K — persistent personal agent with a learning loop**

[github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) —
Nous Research's general-purpose agent. The differentiator is the learning loop: it creates
skills from complex tasks, improves those skills during subsequent uses, maintains cross-session
memory, and builds a user model via Honcho dialectic profiling.

**Why Nous Research built it:** to generate RL training trajectories from real agentic
sessions. This means the core loop is production-quality and heavily validated.

**Tool roster (40+):** browser automation (Camoufox), MCP integration, image generation,
TTS, subagent delegation (`delegate_tool`), mixture-of-agents, cron scheduling, security
(`tirith_security`), session search (FTS5 SQLite), and RL trajectory compression.

**Six terminal backends:** local, Docker, SSH, Daytona, Singularity, Modal serverless.
Modal mode: the agent hibernates when idle, wakes on demand — nearly zero cost when not active.

**Messaging gateway:** one process, all platforms — Telegram, Discord, Slack, WhatsApp,
Signal, Email. Start a task on Telegram, continue in CLI, same session context.

**Cron:** natural-language task scheduling, delivers results to any configured platform.
"Every Monday morning, summarize last week's GitHub issues in my repos and post to Slack."

**Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
hermes setup     # full wizard
hermes gateway start   # messaging gateway (optional)
hermes claw migrate    # if migrating from OpenClaw
```

**What to know:** The learning loop compounds with use — light usage won't accumulate
meaningful skills. Honcho user modeling requires separate Honcho API setup. No Windows
native support (Linux/macOS/WSL2 only).

**Compatible with** the `agentskills.io` open standard — skills are portable to other
compatible agents.

---

**Open SWE ⭐9K — async org-internal coding agent via Slack/Linear**

[github.com/langchain-ai/open-swe](https://github.com/langchain-ai/open-swe) — LangChain's
open-source implementation of the async coding agent pattern used by Stripe (Minions),
Ramp (Inspect), and Coinbase (Cloudbot). "Async by design" means: you invoke it via Slack
or Linear, it works in a cloud sandbox, you get pinged when it's done.

**Key differences from CLI-based agents:**
- You don't block on it. Mention the bot in Slack, continue your day, review a PR later.
- Mid-run follow-ups: send a Slack message or Linear comment while the agent is running —
  it picks up the message before its next model call and can redirect.
- Isolated cloud sandbox (Modal, Daytona, or Runloop) per task — repo is cloned in,
  full shell access, blast radius contained.
- `AGENTS.md` in the repo root is read from the sandbox and injected into the system prompt.
- After completing, it commits and opens a GitHub draft PR automatically.

**Invocation surfaces:**
- Slack: `@openswe fix the auth middleware` (specify repo with `repo:owner/name`)
- Linear: comment `@openswe` on any issue
- GitHub: tag `@openswe` on PR comments to address review feedback

**What to know:** This is a framework you deploy, not a tool you install. Requires LangGraph
Cloud (or self-hosted), a sandbox provider account (Modal recommended), and Slack/Linear
app configuration. Not a weekend project — plan a day for initial setup.

**Best for:** engineering teams with GitHub + Slack + Linear stack who want
"delegate to an agent" to be a natural part of issue triage.

---

**Project NOMAD ⭐21K — offline AI server, no internet required**

[github.com/Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) —
a Docker orchestration platform for running a curated offline knowledge + AI stack on
local hardware. Not an agent framework — an offline infrastructure kit.

**Stack it provisions:** Ollama (local LLM inference) + Qdrant (vector search/RAG) +
Kiwix (offline Wikipedia/medical references), Kolibri (Khan Academy), ProtoMaps (offline
maps), CyberChef (encryption/encoding), FlatNotes (markdown notes).

**Install (Debian/Ubuntu):**
```bash
curl -fsSL https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/install_nomad.sh \
  -o install_nomad.sh && sudo bash install_nomad.sh
```
Browser UI at `http://localhost:8080`. Headless-friendly.

**Hardware reality:** 2-core/4GB minimum gets you the stack without LLM. For actual
useful LLM inference (7B+ models): i7/Ryzen 7, 32GB RAM, RTX 3060+ GPU with 8GB+ VRAM.

**What to know:** No authentication by design — use network-level firewall controls.
Content libraries (Wikipedia ZIM files) must be downloaded during initial setup while
online. Recommended for: air-gapped enterprise deployments, emergency/field use, private
offline research environments.

**Fits into the Hetzner setup as an offline fallback:** NOMAD on a local box, OpenCode on
Hetzner when connectivity is available — two-environment strategy.

### Multi-model dispatch

Different models for different roles:
- **Opus** → implementation (best reasoning, worth the cost for complex logic)
- **Gemini** → exploratory research (1M+ token context window, cheap at scale)
- **Sonnet** → review (fast, cost-effective, catches surface issues)
- **Grok** → real-time web/X search tasks (paid — free tier ended Dec 2024)

> "The cumulative output is stronger than any single model working alone."

Don't have the review agent correct its own implementing context.

### Agent design principles (from practice)

1. **Narrow context beats wide context.** Give each agent exactly what it needs. Agents with
   100 relevant lines outperform agents with 10,000 lines and 100 relevant ones.

2. **Specs over chat.** An agent working from a written spec can be retried, replaced, or
   reviewed. An agent working from chat history cannot.

3. **Hierarchy is not optional.** Flat agent teams stall. Someone has to own the overall plan
   and break deadlocks.

4. **Isolation prevents contamination.** Each worker in its own git worktree. A broken
   worker doesn't corrupt the main branch.

5. **Make stopping conditions explicit.** "Work until the tests pass" is better than
   "fix the failing tests." The former is a condition; the latter is a command.

**Sources:**
- [How I run 4–8 parallel coding agents](https://schipper.ai/posts/parallel-coding-agents/) (weeklyfoo #127)
- [8 Levels of Agentic Engineering](https://www.bassimeledath.com/blog/levels-of-agentic-engineering) (weeklyfoo #128)
- [Superset](https://github.com/superset-sh/superset) (weeklyfoo #127)

---

## Remote Setup — OpenCode on Hetzner

Running an AI agent server remotely means: no laptop dependency, always-on async agents,
shared team access, and reproducible environments. This is Level 7+ infrastructure.

### What OpenCode is

[OpenCode](https://github.com/sst/opencode) is an open-source Claude Code alternative from
the SST team. Key differences from Claude Code:
- Works with 75+ model providers (Claude, GPT, Gemini, Ollama local models)
- Headless / server mode — no TUI required
- Linux-native (Claude Code CLI works on Linux too, but opencode is purpose-built for it)
- Vendor-agnostic: bring your own API keys

Both Claude Code and OpenCode work on remote Linux servers. OpenCode is easier to automate
because it has an explicit `--headless` mode and HTTP API.

### Minimum viable Hetzner setup

**Hardware:** CX22 (2 vCPU, 4GB RAM, 40GB NVMe) — ~€4/month. For parallel agents: CX32 (4 vCPU, 8GB RAM) ~€8/month.

**Step 1: Provision and harden**
```bash
# On the server (Ubuntu 24.04)
apt update && apt upgrade -y
useradd -m -s /bin/zsh dev
usermod -aG sudo dev
# Copy your SSH key, disable password auth
```

**Step 2: Install OpenCode**
```bash
# Install Node.js 22 via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 22 && nvm use 22

# Install opencode
npm install -g opencode-ai
```

**Step 3: Environment**
```bash
# /home/dev/.env (not committed)
ANTHROPIC_API_KEY=sk-ant-...
BRAVE_API_KEY=BSA_...
XAI_API_KEY=xai-...
MEM0_API_KEY=...
```

**Step 4: Persistent sessions with tmux**
```bash
# On the server
tmux new-session -s main
opencode  # starts interactive session

# Detach: Ctrl+B D
# Reconnect later: ssh dev@server; tmux attach -t main
```

**Step 5: Systemd service (for headless/background mode)**
```ini
# /etc/systemd/system/opencode.service
[Unit]
Description=OpenCode AI Agent
After=network.target

[Service]
Type=simple
User=dev
WorkingDirectory=/home/dev/projects
EnvironmentFile=/home/dev/.env
ExecStart=/usr/local/bin/opencode --headless --port 3000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```bash
systemctl enable opencode && systemctl start opencode
```

**Step 6: Sync your ai-kit repo**
```bash
git clone git@github.com:urbanisierung/ai-kit.git ~/github.com/urbanisierung/ai-kit
cd ~/github.com/urbanisierung/ai-kit && bash tools/setup.sh
```
This links your skills, CLAUDE.md, MCP config, and memory from the canonical repo.
When you update a skill on your laptop and push, pull on the server and it's live.

**Step 7: Optional — Tailscale for private access**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
```
No public port exposure. Access the server from any device on your Tailscale network.
`ssh dev@opencode-server` from anywhere.

### Remote workflow

```bash
# Quick one-shot task (SSH + run + exit)
ssh dev@server 'cd ~/projects/myrepo && opencode -p "Run tests and summarize failures" 2>&1 | tee /tmp/last-run.txt'

# Background task via tmux
ssh dev@server 'tmux send-keys -t main "opencode -p \"Generate weekly social posts from weeklyfoo #131\"" Enter'

# Check progress
ssh dev@server 'tmux capture-pane -t main -p'
```

### What to put in your ai-kit repo for remote

```
ai-kit/
  tools/
    setup-remote.sh    # Hetzner-specific bootstrap
    update-remote.sh   # pull latest and restart service
  claude/
    mcp.json.template  # MCP config with ${VAR} placeholders
```

---

## Tools Worth Trying (by effort)

### Easy (< 30 min)
| Tool | What it does | Link |
|---|---|---|
| **Claude Code Cheat Sheet** | All commands on one page | [cc.storyfox.cz](https://cc.storyfox.cz/) |
| **claude-hud** ⭐16K | Live context bar + subagent status in terminal | `/plugin install claude-hud` |
| **RTK (Rust Token Killer)** ⭐16K | 60–90% token savings on shell output via transparent hook | `brew install rtk && rtk init -g` |
| **last30days-skill** ⭐17K | Research any topic across Reddit/X/HN/Polymarket/YouTube in one command | `/plugin install last30days` |
| **Claude Code auto mode** | Remove permission friction | Simon Willison's [writeup](https://simonwillison.net/2026/Mar/24/auto-mode-for-claude-code/) |
| **githuman** | Human review gate before AI commits | [github.com/mcollina/githuman](https://github.com/mcollina/githuman) |
| **Rudel** | Session analytics dashboard | [github.com/obsessiondb/rudel](https://github.com/obsessiondb/rudel) |
| **OneCLI** | Open-source credential vault for AI agents | [github.com/onecli/onecli](https://github.com/onecli/onecli) |
| **Plannotator** | Annotate and review agent plans + code diffs visually | [github.com/backnotprop/plannotator](https://github.com/backnotprop/plannotator) |
| **Brave Search MCP** | Web search in Claude | `npx @modelcontextprotocol/server-brave-search` |

### Medium (1–3 hours)
| Tool | What it does | Link |
|---|---|---|
| **jai** (Linux) | Lightweight sandbox for AI agents — copy-on-write containment, no Docker | [jai.scs.stanford.edu](https://jai.scs.stanford.edu/) |
| **pi-self-learning** | Git-backed persistent memory across sessions | `pi install npm:pi-self-learning` |
| **mem0 MCP** | Vector+graph memory layer, cloud or self-hosted | [mem0.ai](https://mem0.ai) |
| **Agent-Reach** ⭐14K | Give your agent access to Twitter, Reddit, YouTube, GitHub, Bilibili — zero API fees | [github.com/Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) |
| **Hermes Agent** ⭐21K | Persistent personal agent with learning loop + messaging gateway | [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) |
| **Cog** | Persistent memory + self-reflection architecture | [github.com/marciopuga/cog](https://github.com/marciopuga/cog) |
| **compound-engineering** ⭐12K | Level 4 plugin: ideate → plan → work → review → compound (codify learnings) | `/plugin install compound-engineering` |
| **GSD** ⭐45K | Meta-prompting + spec-driven development system | [github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) |
| **Everything Claude Code** ⭐130K | 150+ skills, 70+ commands, hooks, rules, AgentShield security | [ecc.tools](https://ecc.tools) |
| **Dispatch skill** | Orchestrator pattern for parallel agents | [github.com/bassimeledath/dispatch](https://github.com/bassimeledath/dispatch) |
| **Project NOMAD** ⭐21K | Offline AI + knowledge server (Ollama + RAG + Wikipedia), no internet needed | [github.com/Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) |

### Harder (half-day+)
| Tool | What it does | Link |
|---|---|---|
| **FD system** | Full parallel agent workflow with tmux + specs | `/fd-init` slash command |
| **Superset** ⭐8.3K | 10+ parallel agents with worktree isolation | [superset.sh](https://github.com/superset-sh/superset) |
| **DeerFlow** ⭐56K | Self-hosted long-horizon super-agent with web UI; delegates to sub-agents | [github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow) |
| **Open SWE** ⭐9K | Async org-internal coding agent via Slack + Linear; opens PRs when done | [github.com/langchain-ai/open-swe](https://github.com/langchain-ai/open-swe) |
| **OpenCode on Hetzner** | Always-on remote agent server | See Remote Setup section above |
| **ZeroBoot** | Sub-millisecond VM sandboxes for agents via copy-on-write forking | [github.com/zerobootdev/zeroboot](https://github.com/zerobootdev/zeroboot) |

---

## What the Data Says (empirical findings, not opinions)

From [What Claude Code Actually Chooses](https://amplifying.ai/research/claude-code-picks)
(weeklyfoo #126) — 2,430 unguided agent runs:

- **"Claude Code builds, not buys"** — prefers custom/DIY in 12 of 20 tool categories
- When asked "add auth" in Python → writes JWT + bcrypt from scratch, not Passport or Auth0
- When it does pick a tool, it picks decisively: GitHub Actions 94%, Stripe 91%, shadcn/ui 90%
- **Model personalities:** Sonnet 4.5 = conventional (established tools), Opus 4.5 = balanced, Opus 4.6 = forward-looking

From [AI Tooling for Software Engineers in 2026](https://newsletter.pragmaticengineer.com/p/ai-tooling-2026)
(weeklyfoo #127) — 900+ engineers surveyed:

- Claude Code is the #1 most-loved tool at 46% (vs Cursor 19%, Copilot 9%)
- 95% use AI tools at least weekly
- 55% regularly use AI agents; staff+ engineers at 63.5%
- Most engineers juggle 2–4 tools simultaneously

---

## Anti-Patterns to Avoid

**Comprehension debt** — shipping AI-generated code faster than you understand it.
Unlike technical debt, it breeds false confidence. Ask "do I understand why this works?"
before merge. — [Addy Osmani](https://addyosmani.com/blog/comprehension-debt/) (weeklyfoo #129)

**Context overload** — too many MCP tools, too long a context file (CLAUDE.md / GEMINI.md / copilot-instructions.md), too many rules.
Every token fights for its place. Information density is the name of the game.

**Same model grading its own exam** — the implementing instance will gloss over its own errors.
Separate the review step; use a fresh session or a different model.

**Override rate going to zero** — this looks like AI adoption success. It's actually the
removal of your error-detection layer. Track *why* humans override, not just whether they do.

**Vibe coding without comprehension** — Mo Bitar did it for two years and went back to hand-writing.
The long-term costs emerge slowly. By the time they're visible, they're expensive.
— [After two years of vibecoding, I'm back to writing by hand](https://atmoio.substack.com/p/after-two-years-of-vibecoding-im) (weeklyfoo #122)

---

## Suggested Learning Order

Each week has a **theme**, **exact commands to run**, and **what you'll notice**.
Steps marked **(Claude)**, **(Gemini)**, or **(Copilot)** are tool-specific. Everything else applies to all three.

---

### Week 0 — Create your AI resources repo

**Goal:** A single git repo that holds every AI config, skill, hook, and learning.
Anything you set up this week and beyond lives here first.

```bash
mkdir -p ~/github.com/urbanisierung && cd ~/github.com/urbanisierung/ai-kit
git init
mkdir -p claude/skills claude/hooks copilot gemini memory tools dotfiles
touch .gitignore README.md
gh repo create urbanisierung/ai-kit --private --push
```

Copy the starter file contents from the STEP 0 section above into each file.
Then run:
```bash
chmod +x tools/setup.sh tools/sync.sh tools/install-tools.sh
bash tools/setup.sh          # links configs, writes MCP + settings from templates
bash tools/install-tools.sh  # interactive: installs CLI tools (RTK, rudel, ecc, jai, ...)
```

**What you'll notice:** Every skill, hook, and CLAUDE.md change you make for the rest
of this plan has a home. New machines get everything in one `git clone && bash setup.sh`.

---

### Week 1 — Skills and Superpowers

**Goal:** Your agent gains new capabilities and learns to plan before coding.

**(Claude) Step A — Install Superpowers (10 minutes):**
```
/plugin install superpowers@claude-plugins-official
```
Pick any real task from your backlog. Watch what happens before any code appears.
Let it run the full loop. Expect the first run to feel slow. The second run feels normal.

**(Gemini) Step A equivalent — Install Superpowers for Gemini:**
Superpowers is available for Gemini CLI via the extension mechanism. Check the
[superpowers repo](https://github.com/obra/superpowers) for the Gemini install path.

**(Copilot) Step A equivalent:**
Superpowers is not available for Copilot CLI. Use compound-engineering instead:
```bash
bunx @every-env/compound-plugin install compound-engineering --to copilot
```

**Step B — Write your own first skill (30–60 minutes):**
```bash
# Claude Code
mkdir -p .claude/your-skill-name && touch .claude/your-skill-name/SKILL.md

# Gemini CLI — place in your extension or at a skills path
mkdir -p ~/.gemini/skills/your-skill-name && touch ~/.gemini/skills/your-skill-name/SKILL.md

# Copilot — agent profiles in .github/agents/
mkdir -p .github/agents && touch .github/agents/your-agent.md
```
Write the frontmatter `description` first — that's the routing key for Claude and Gemini.
Commit everything to your ai-kit repo.

**(Claude) Step C — Browse skills.sh:**
Go to [skills.sh](https://skills.sh/). Install `skill-creator` first. Then 2–3 that match your workflow.

**(Copilot) Step C equivalent:**
Browse [github/awesome-copilot](https://github.com/github/awesome-copilot) for community skills and agents.

**What you'll notice:** Your agent's first response to a task changes from "I'll do X" to
"Before I start: here's what I'm going to build and why."

**Read:** [Agent Skills vs. Rules vs. Commands](https://www.builder.io/blog/agent-skills-rules-commands)

---

### Week 2 — MCP and search

**Goal:** Your agent can reach external systems; you have working search without pasting URLs.

**Brave Search (5 minutes):**
```bash
# Claude Code
claude mcp add brave-search -e BRAVE_API_KEY=BSA_YOUR_KEY -- npx -y @modelcontextprotocol/server-brave-search

# Gemini CLI — add to ~/.gemini/settings.json
# { "mcpServers": { "brave-search": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-brave-search"], "env": { "BRAVE_API_KEY": "BSA_..." } } } }

# Copilot — add to VS Code settings.json under "github.copilot.mcpServers"
# (no CLI-native method; requires VS Code)
```

**Grok API (10 minutes):**
Sign up at [console.x.ai](https://console.x.ai). **No ongoing free tier** — the $25/month beta ended Dec 2024.
New accounts receive a one-time $25 credit (30-day expiry). A data-sharing program offers $150/month credits
but has significant strings: requires $5 prior spend, opt-in is permanent, and unavailable in EU/UK/Iceland/Liechtenstein/Norway.
Add the MCP from [github.com/merterbak/Grok-MCP](https://github.com/merterbak/Grok-MCP).
The same MCP server definition works for all three tools; only the config file location differs.

**Groq (free alternative):**
Sign up at [console.groq.com](https://console.groq.com) — no credit card required. Provides fast LLM inference
(Llama 4, Llama 3.3 70B, Qwen3) via an OpenAI-compatible API with a genuine ongoing free tier.
Does not provide X/Twitter search; use only when Grok's social media signal is not needed.

**DeepWiki (5 minutes):**
```json
{ "mcpServers": { "deepwiki": { "command": "npx", "args": ["-y", "@deepwiki/mcp"] } } }
```
Add this block to `~/.claude/mcp.json` (Claude), `~/.gemini/settings.json` (Gemini),
or VS Code settings (Copilot).

**Store all keys in ai-kit:**
```bash
# Commit the MCP config as a template with ${VAR_NAME} placeholders
cp ~/.claude/mcp.json ~/github.com/urbanisierung/ai-kit/claude/mcp.json.template
# Replace actual key values with ${VAR_NAME}; setup.sh fills them in via envsubst
```

**What you'll notice:** MCP has real context cost. Disable MCPs you aren't using
in the current session. This is not set-and-forget configuration.

---

### Week 3 — Persistent memory

**Goal:** Sessions start with context from previous sessions.

**(Claude) pi-self-learning — git-backed automatic memory:**
```bash
npm install -g @pi-labs/cli
pi install npm:pi-self-learning
```
After one week, run `/learning-month`. Commit the resulting `CORE.md` to your ai-kit repo.

**(Gemini / Copilot) No pi-self-learning equivalent.** Use mem0 (below) as the primary
memory layer, and manually maintain your `GEMINI.md` / `copilot-instructions.md` with
the lessons you'd otherwise capture automatically.

**mem0 MCP (cloud, easiest):**
```bash
# Sign up at app.mem0.ai, get API key
npx mcp-add --name mem0-mcp --type http --url "https://mcp.mem0.ai/mcp"
claude mcp add mem0-mcp --scope global
```
After adding, tell Claude at the end of sessions: "Save the key decisions from this session to memory."
At the start of the next relevant session: "Check memory for context on [topic]."

**What you'll notice:** After two weeks you'll have a corpus. Ask Claude
"what do I usually prefer for X?" and it will answer from memory, not from guessing.

---

### Week 4 — Prompting discipline

**Goal:** Better first responses; fewer correction loops.

**The one habit worth forming:**
Before any non-trivial task, write one sentence starting with "because."

**(Claude) pi-self-learning after corrections:**
Every time you correct Claude, the hook captures it. After one week, run `/learning-month`.
You'll see your most common corrections. The top 3 belong in CLAUDE.md immediately.

**(Gemini / Copilot) Manual equivalent:**
After each session, note the top correction you made and add it to your context file.
One rule per session. Prune after 10 sessions. No automation — just discipline.

**The power prompt experiment:**
Adapt the Pandya example from the Prompting section to something real in this repo.
Run it. You'll see parallel agents, context file updates, and a new skill appear — from one prompt.

---

### Week 4b — Token management and observability

**Goal:** Know what your context window contains and stop burning tokens on noise.

**(Claude) Step A — Install claude-hud (5 minutes):**
```
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
```
Run `/claude-hud:configure` and enable the agent and todo lines, not just the context bar.
Watch the context fill during Week 5's hooks session. The color shift from green to yellow
to red is the signal to `/compact` or start fresh.

**(Gemini / Copilot) No claude-hud equivalent.**
Context visibility is not built into either tool's CLI. Compensate by keeping sessions
short and scoped: one topic per session, use `/clear` (Gemini) or start a new chat when
switching context. If token usage matters, measure with RTK (see below).

**Step B — Install RTK (10 minutes) — all tools:**
```bash
brew install rtk     # macOS
# or: curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

rtk init -g                # Claude Code
rtk init -g --gemini       # Gemini CLI
rtk init -g --codex        # Copilot / Codex
```
Run `rtk gain` at the end of your next session. The number is usually surprising.

**(Claude) Step C — Run /context:**
Open a new Claude Code session. Run `/context` before typing anything.
Note what percentage is already consumed. If it's over 15%, investigate:
which MCPs are mounted? Is your CLAUDE.md over 100 lines?

**Step D — Add the last30days skill (5 minutes):**
```
/plugin marketplace add mvanhorn/last30days-skill
/plugin install last30days@last30days-skill
```
Run `/last30days <something you're currently working on>`. Let it finish (2–8 minutes).
Read the Polymarket section of the output — that's the part you won't get from a search engine.

**What you'll notice:** After RTK + claude-hud, agentic sessions feel fundamentally different.
You can see what's happening, and the agent isn't burning tokens on test output noise.

---

### Week 5 — Hooks and harness

**Goal:** Your agent detects its own errors without you pointing them out.

**(Claude) PostToolUse hook:**
```json
{
  "event": "PostToolUse",
  "command": "pnpm lint --filter @urbanisierung/book-generator 2>&1 | tail -20"
}
```
After every file write, Claude sees the lint output and fixes errors immediately.
This is backpressure — the faster feedback loop changes how the agent behaves.

**(Gemini) Equivalent approach:**
Wrap your linter as an MCP tool and bundle it in an extension. Instruct Gemini in `GEMINI.md`:
"After writing or editing any source file, call the lint tool and fix any errors before proceeding."
No automatic firing — Gemini calls it explicitly — but the effect is similar.

**(Copilot) Equivalent approach:**
No in-session hooks. Set up git-level pre-commit hooks (`lefthook` or `husky`) so quality gates
fire before any agent output can be committed. Add the instruction to `copilot-instructions.md`:
"Always run the linter and fix all errors before presenting code as complete."

**Study Sentry's PR review skill:**
[github.com/getsentry/skills](https://github.com/getsentry/skills) — one orchestrating skill
→ multiple focused subagents → results aggregated. This pattern works with any agent tool that
supports subagent delegation (Claude Code, Gemini CLI with extensions).

---

### Week 6 — Remote setup (Hetzner)

**Goal:** An always-on agent server you can reach from anywhere.

Follow the Remote Setup section above. The milestone for this week:
1. OpenCode running on a Hetzner CX22
2. Your ai-kit repo cloned and set up via `setup-remote.sh`
3. tmux session persisting across SSH disconnects
4. Tailscale installed for private access

Once this is running: kick off a long background task from your phone via SSH.
That's the proof-of-concept.

---

### Week 7+ — Agent teams

**Goal:** Run multiple agents on independent tasks simultaneously.

**Start with Superset:**
Download from [github.com/superset-sh/superset](https://github.com/superset-sh/superset).
Start with 2 agents on genuinely independent tasks. Review both when done.

**FD system:**
Run `/fd-init`. Write one real FD for your next task instead of just prompting.
The overhead is the point — it prevents mid-task pivots and makes decisions auditable.

**Multi-model dispatch:**
- Opus → implementation
- Sonnet → review
- Don't have the review agent correct its own implementing context

**The ceiling:** 4–6 parallel agents is the practical limit before coordination overhead
exceeds the parallelism gain. Above that, spec quality is the bottleneck.

**When you're ready to go further — three distinct paths:**

*Path A — Self-hosted long-horizon tasks (DeerFlow):*
Stand up DeerFlow via Docker. Give it a research task that would take you 30 minutes to
do manually. Watch it run sub-agents, produce a report, generate slides. The milestone:
delegate a full research pass on a technical topic and use the output rather than rewriting it.

*Path B — Persistent daily-driver agent (Hermes):*
Install Hermes Agent. Connect it to one messaging platform (Telegram is the simplest).
Let it run for two weeks. After 10 sessions, run the skill stocktake to see what it's
learned. The milestone: it correctly anticipates a preference you never explicitly stated.

*Path C — Team-scale async agent (Open SWE):*
Only if you have a team, a shared GitHub repo, and Slack. Deploy Open SWE. File a
Linear issue, comment `@openswe`. The milestone: it opens a meaningful draft PR that
requires minimal rework before merge.

---

## For the Social Posts

After working through the learning plan above, you'll have genuine firsthand
experience to draw from. The practical posts in `social-posts.md` (templates A–D)
can be filled in as you complete each week:

- **Week 1** → Practical Post A (Claude Skills I use)
- **Week 3** → Practical Post B (how I solved the memory problem)
- **Week 4** → Practical Post C (Three habits that changed my workflow)
- **Any week** → Practical Post D (curation workflow — this one is already partially yours)

The principle: share findings as you make them, not in advance.
"I tried this, here's what happened" outperforms "here's how to do this"
every time on LinkedIn.
