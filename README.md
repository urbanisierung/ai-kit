# AI Kit

**Personal AI coding configuration, skills, hooks, and memory — shareable across machines.**

One repo that holds everything: your context files, MCP setup, hooks, skills, and a structured learning path for Claude Code, Gemini CLI, and GitHub Copilot.

---

## AI Champion Roadmap

A 10-level interactive learning path built on top of this repo.

| Level | Topic | Actions |
|-------|-------|---------|
| 0 | Foundation: AI Resources Repository | 5 |
| 1 | Context Engineering | 9 |
| 2 | Compounding Engineering | 9 |
| 3 | Skills and Extensions | 12 |
| 4 | MCP Servers | 10 |
| 5 | Prompting Discipline | 6 |
| 6 | Token Management and Observability | 13 |
| 7 | Hooks and Persistent Memory | 19 |
| 8 | Remote Setup | 10 |
| 9 | Parallel Agents | 18 |

Each level has: a clear goal, action items with checkboxes, reasoning behind every step, code snippets, and links. Progress is saved locally in your browser.

Covers **Claude Code**, **Gemini CLI**, and **GitHub Copilot** — items are tagged so you see only what's relevant to your tools.

---

## Quick Start

```bash
git clone git@github.com:urbanisierung/ai-kit.git ~/github.com/urbanisierung/ai-kit
cp ~/github.com/urbanisierung/ai-kit/.env.example ~/github.com/urbanisierung/ai-kit/.env
# Edit .env — fill in your API keys
bash ~/github.com/urbanisierung/ai-kit/tools/setup.sh
```

`setup.sh` symlinks your context files and hooks into place, sources the AI aliases, and installs optional CLI tools. Re-run it any time after pulling.

> The checkout path above is the default. To use a different location, set `AI_KIT_REPO=/your/path` before running setup.

---

## What's Inside

```
claude/
  CLAUDE.md.global          Global context injected into every Claude session
  settings.json.template    Hook configuration (linter, verifier, fast path)
  mcp.json.template         MCP server definitions
  hooks/
    post-tool-use.sh        Fires after every tool call — lint, verify, log
  skills/                   Reusable agent skill files

copilot/
  copilot-instructions.md   Global Copilot instructions
  agents/                   Agent-specific instruction files

gemini/
  GEMINI.md.global          Global context for Gemini CLI

memory/
  CORE.md                   Durable learnings promoted by pi-self-learning
                            Commit this file — it travels to every machine

tools/
  setup.sh                  Bootstrap: symlink, source, install
  sync.sh                   Pull latest and re-run setup (alias: ai-sync)
  install-tools.sh          Install optional CLI tools (rtk, rudel, jai, ...)
  generate-docs.ts          Regenerate docs/ai-champion-roadmap.md from JSON

data/
  roadmap.json              Single source of truth for the roadmap
  roadmap.schema.json       JSON Schema for validation

site/                       Astro 5 static site (Cloudflare Pages)
  src/pages/
    index.astro             Landing page
    roadmap.astro           Interactive roadmap with progress tracking
    cheatsheet.astro        All commands on one dark page, filterable by tool

docs/
  ai-champion.md            The full guide and context behind the roadmap
  ai-champion-roadmap.md    Generated markdown version (do not edit directly)

dotfiles/
  .zshrc.ai                 AI aliases (ai-sync, etc.) — sourced by setup.sh
```

---

## Sync Across Machines

```bash
ai-sync          # pulls latest and re-runs setup.sh
```

---

## Add a Skill

```bash
mkdir -p claude/skills/my-skill
touch claude/skills/my-skill/SKILL.md
# write frontmatter + steps, commit
git add . && git commit -m "feat: add my-skill"
```

The symlink in `~/.claude/skills/` picks it up immediately.

---

## Site Development

```bash
cd site
pnpm install
pnpm dev          # localhost:4321
pnpm build        # output → site/dist/
```

The roadmap data lives in `data/roadmap.json`. To regenerate the markdown doc:

```bash
npx tsx tools/generate-docs.ts
```

Deploy to Cloudflare Pages with build command `cd site && pnpm install && pnpm build` and output directory `site/dist`.
