# AI Champion Roadmap

Structured action plan based on [`ai-champion.md`](./ai-champion.md).
Work through each level in order — every level is a prerequisite for the next.

### Tool legend
Items are tagged where support differs across tools.
Untagged items apply to all three.

| Tag | Meaning |
|---|---|
| `[Claude]` | Claude Code only |
| `[Gemini]` | Gemini CLI only |
| `[Copilot]` | GitHub Copilot CLI / VS Code only |
| `[Claude+Gemini]` | Not available for Copilot CLI |
| `[Claude+Copilot]` | Not available for Gemini CLI |

---

## Level 0 — Foundation: AI Resources Repository
> Goal: one git repo that survives machine changes and holds every config, skill, and learning.

- [ ] Create the repo structure (`claude/`, `copilot/`, `gemini/`, `memory/`, `tools/`, `dotfiles/`)
- [ ] Write `.gitignore` (exclude `.env`, `*.local`)
- [ ] Create `.env` with real API keys (never commit)
- [ ] Write `AGENTS.md` at repo root — recognized by Claude Code, Copilot, Gemini CLI, and Cursor
- [ ] `[Claude]` Write `claude/CLAUDE.md.global` with communication style and behavior rules
- [ ] `[Claude]` Write `claude/mcp.json.template` with `${VAR_NAME}` placeholders
- [ ] `[Claude]` Write `claude/settings.json.template`
- [ ] `[Claude]` Write `claude/hooks/post-tool-use.sh` (starter hook, even if empty)
- [ ] `[Copilot]` Write `copilot/copilot-instructions.md` (symlinked to `.github/copilot-instructions.md`)
- [ ] `[Gemini]` Write `gemini/GEMINI.md.global` (symlinked to `~/.gemini/GEMINI.md`)
- [ ] `[Gemini]` Write `gemini/settings.json` with model selection and API key reference
- [ ] Write `memory/CORE.md` (empty placeholder)
- [ ] Write `dotfiles/.zshrc.ai` with AI aliases (`cc`, `cca`, `ai-sync`, `ai-env`)
- [ ] Write `tools/setup.sh` (idempotent: symlinks configs, runs `envsubst` on templates)
- [ ] Write `tools/sync.sh` (git pull + re-run setup)
- [ ] Run `bash tools/setup.sh` on current machine
- [ ] Push to a private remote repo
- [ ] Verify: `git clone && bash tools/setup.sh` reproduces full setup from scratch

---

## Level 3 — Context Engineering
> Goal: each tool's default behavior matches your preferences without prompting on every session.

All three tools load a context file at session start. The principle is the same; the file and location differ.

| Tool | File | Location |
|---|---|---|
| Claude Code | `CLAUDE.md` | repo root, subdirs, `~/.claude/CLAUDE.md` (global) |
| Copilot | `copilot-instructions.md` or `AGENTS.md` | `.github/copilot-instructions.md` or repo root |
| Gemini CLI | `GEMINI.md` | repo root or `~/.gemini/GEMINI.md` (global) |

- [ ] Review the existing `CLAUDE.md` in this repo as the reference format
- [ ] `[Claude]` Trim `CLAUDE.md` to under 100 lines; use `@imports` for long reference docs
- [ ] `[Claude]` Add a subdirectory `CLAUDE.md` for any subtree with different conventions
- [ ] `[Copilot]` Keep `copilot-instructions.md` focused — Copilot reads it on every message, no lazy loading
- [ ] `[Copilot]` Enable `AGENTS.md` in VS Code: `"chat.useAgentsMdFile": true` in settings
- [ ] `[Gemini]` Place `GEMINI.md` at repo root for project scope; `~/.gemini/GEMINI.md` for global defaults
- [ ] Add a rule across all context files: "Respond concisely; no filler, no preamble"
- [ ] After each session where you correct the agent, add one rule to the relevant context file
- [ ] Prune rules that haven't fired after 10 sessions

---

## Level 4 — Compounding Engineering
> Goal: each cycle of work improves future cycles; 80% planning and review, 20% execution.

compound-engineering supports all three tools via separate install commands.

- [ ] `[Claude]` Install: `/plugin marketplace add EveryInc/compound-engineering-plugin` then `/plugin install compound-engineering`
- [ ] `[Gemini]` Install: `bunx @every-env/compound-plugin install compound-engineering --to gemini`
- [ ] `[Copilot]` Install: `bunx @every-env/compound-plugin install compound-engineering --to copilot`
- [ ] Run `/ce:plan` on a real backlog task instead of just prompting
- [ ] Run `/ce:work` to execute with worktree isolation and task tracking
- [ ] Run `/ce:review` before merging any agent-produced code
- [ ] Run `/ce:compound` after the task — review the extracted learnings
- [ ] Commit the learnings output to `memory/` in your ai-kit repo
- [ ] Repeat the Plan → Delegate → Assess → Codify loop on 3 real tasks

---

## Level 5a — Skills and Extensions
> Goal: the agent gains specialized capabilities without permanently consuming context.

All three tools share the `SKILL.md` open standard. Install mechanisms differ.

- [ ] Write your first custom `SKILL.md` — write the `description` frontmatter first (it's the routing key)
- [ ] Store the skill in your ai-kit repo under the relevant tool's skills directory
- [ ] Add `AGENTS.md` to the repo root if not done in Level 0 — all tools pick it up
- [ ] `[Claude]` Install `skill-creator` from skills.sh (meta-skill for writing skills)
- [ ] `[Claude]` Install Superpowers: `/plugin install superpowers@claude-plugins-official`; run on a real task
- [ ] `[Claude]` Browse [skills.sh](https://skills.sh/) and install 2–3 skills that match your workflow
- [ ] `[Claude]` Optional: run `/harness-audit` from Everything Claude Code to score your setup
- [ ] `[Claude+Gemini]` Superpowers is available for Gemini CLI — install via the Gemini extension mechanism
- [ ] `[Copilot]` Browse [github/awesome-copilot](https://github.com/github/awesome-copilot) for community skills and agents
- [ ] `[Copilot]` Create `.github/agents/*.md` files for scoped Copilot agents (VS Code agent picker)
- [ ] `[Gemini]` Create extensions in `~/.gemini/extensions/<name>/gemini-extension.json` to bundle MCP servers + instructions
- [ ] Study [Sentry's skills](https://github.com/getsentry/skills) for the subagent delegation pattern — applies to all tools

---

## Level 5b — MCP Servers
> Goal: the agent can search the web and reach external systems; MCP cost is managed.

MCP is supported by all three tools, but the setup command differs.

| Tool | How to add an MCP |
|---|---|
| Claude Code | `claude mcp add <name> -- npx -y <package>` |
| Gemini CLI | Add to `mcpServers` in `~/.gemini/settings.json` or inside an extension JSON |
| Copilot | Add to VS Code `settings.json` under `"github.copilot.mcpServers"` — not CLI-native |

- [ ] Get a Brave Search API key; add the MCP for your primary tool
- [ ] Add DeepWiki MCP — no API key required
- [ ] Sign up at console.x.ai; add Grok MCP for X/Twitter search + large free tier
- [ ] Store all keys in `ai-kit/.env`; update `mcp.json.template` with `${VAR_NAME}` placeholders
- [ ] Test: ask the agent to research something — it should search without you pasting URLs
- [ ] `[Claude]` Run `/context` in a fresh session — investigate if > 15% is pre-consumed before typing
- [ ] `[Claude]` Habit: disable MCPs not needed in the current session
- [ ] `[Gemini]` Use `"excludeTools"` in extension JSON to block dangerous tool combos per context
- [ ] `[Copilot]` MCP in Copilot is VS Code-only — no CLI-level granularity; manage via workspace settings
- [ ] Optional: add mem0 MCP for cross-session memory (works for all tools via the MCP standard)

---

## Level 5c — Prompting Discipline
> Goal: better first responses; fewer correction loops.

These habits are tool-agnostic.

- [ ] Before every non-trivial task: write one sentence starting with "because"
- [ ] `[Claude]` Use Plan Mode (`Shift+Tab`) to iterate on the plan before any code is written
- [ ] Try the inline annotation pattern: edit spec file directly, add `%%` notes, tell the agent `check %% notes`
- [ ] At the end of long sessions: ask "Summarize what changed, assumptions made, and what you'd do differently"
- [ ] For any review pass: use a separate session or model — don't let the same instance grade its own exam
- [ ] Run the Pandya-style power prompt on something real in this repo and observe the parallelism

---

## Level 5d — Token Management and Observability
> Goal: know what the context window contains; stop burning tokens on noise.

- [ ] `[Claude]` Install claude-hud: `/plugin marketplace add jarrodwatts/claude-hud && /plugin install claude-hud`
- [ ] `[Claude]` Run `/claude-hud:setup` then `/claude-hud:configure` — enable agent and todo lines
- [ ] `[Claude]` Run `/context` before any heavy session; investigate if > 15% is pre-consumed
- [ ] `[Claude]` Habit: use `/compact` or start a fresh session when the context bar turns yellow
- [ ] `[Gemini]` Watch for context warnings in the Gemini CLI output; start fresh sessions for topic changes
- [ ] `[Copilot]` No built-in context visibility — keep sessions short and topic-scoped as a discipline
- [ ] Install RTK: `brew install rtk` (macOS) or `curl … | sh` (Linux) — works for all three tools
- [ ] `[Claude]` Run: `rtk init -g`
- [ ] `[Gemini]` Run: `rtk init -g --gemini`
- [ ] Run `rtk gain` at the end of your next session — note the savings
- [ ] `[Claude+Gemini]` Install last30days skill — see tool-specific install in `ai-champion.md`
- [ ] Run `/last30days <current topic>` and review the Polymarket section

---

## Level 6 — Hooks and Persistent Memory
> Goal: the agent detects its own errors without prompting; sessions start with context from previous ones.

### Backpressure / Hooks

The three tools have fundamentally different hook systems.

| Tool | Hook mechanism | What it enables |
|---|---|---|
| Claude Code | `hooks` in `settings.json` — shell commands on lifecycle events | Linters, tests, memory capture fire automatically |
| Gemini CLI | Extensions with `excludeTools` + bundled MCP servers | Block dangerous operations; no arbitrary shell hooks |
| Copilot CLI | **No hook system** | Manual discipline only; no automatic backpressure |

- [ ] `[Claude]` Add a `PostToolUse` hook that runs your linter after every file write
- [ ] `[Claude]` Verify the hook fires and Claude corrects lint errors without prompting
- [ ] `[Claude]` Keep hooks fast — slow hooks degrade the feedback loop (target < 2s)
- [ ] `[Claude]` Optional: install Rudel for session analytics: `npm install -g rudel && rudel login && rudel enable`
- [ ] `[Gemini]` Create an extension that bundles your linter as an MCP tool so Gemini can call it explicitly
- [ ] `[Gemini]` Use `"excludeTools"` to block destructive operations (e.g., `run_shell_command(rm -rf)`)
- [ ] `[Copilot]` Compensate for no hooks: run linter/tests manually before accepting agent output; use pre-commit hooks at the git level instead

### Persistent Memory

- [ ] `[Claude]` Install pi-self-learning: `npm install -g @pi-labs/cli && pi install npm:pi-self-learning`
- [ ] `[Claude]` After one week, run `/learning-month` and review the output
- [ ] `[Claude]` Commit the resulting `CORE.md` to `ai-kit/memory/`
- [ ] Set up mem0 cloud and store the key in `.env` — works via MCP for all three tools
- [ ] Habit: at session end, tell the agent "Save key decisions from this session to memory"
- [ ] Habit: at session start on a returning topic, tell the agent "Check memory for context on [topic]"
- [ ] `[Copilot+Gemini]` Without pi-self-learning, mem0 + manually maintained context files (`AGENTS.md`, `GEMINI.md`) are the primary memory mechanism
- [ ] After two weeks: ask the agent "what do I usually prefer for X?" — it should answer from memory

### Sandbox Safety

- [ ] `[Claude]` Install jai (Linux): build from source or AUR
- [ ] `[Claude]` Run `jai claude` before testing any new skill or hook for the first time
- [ ] `[Claude]` Use `jai --mode strict` before delegating any long autonomous task
- [ ] `[Gemini+Copilot]` Use git worktrees as a manual blast-radius limiter when no dedicated sandbox exists

---

## Level 7 — Remote Setup (Always-On Agent Server)
> Goal: an always-on agent server reachable from anywhere; no laptop dependency.

OpenCode supports 75+ model providers including Claude, Gemini, and others — making it the right choice for a model-agnostic remote server, regardless of which CLI tool you use day-to-day.

- [ ] Provision a Hetzner CX22 (~€4/month) with Ubuntu 24.04
- [ ] Harden the server: create `dev` user, copy SSH key, disable password auth
- [ ] Install Node.js 22 via nvm; install opencode: `npm install -g opencode-ai`
- [ ] Create `/home/dev/.env` with API keys for Claude, Gemini, and any others
- [ ] Start a persistent tmux session: `tmux new-session -s main`
- [ ] Write and enable a systemd service for headless OpenCode on port 3000
- [ ] Clone your ai-kit repo and run `bash tools/setup.sh` on the server
- [ ] Install Tailscale for private access: `curl -fsSL https://tailscale.com/install.sh | sh`
- [ ] Write `tools/setup-remote.sh` and `tools/update-remote.sh` in ai-kit
- [ ] Milestone: kick off a long background task from your phone via SSH

---

## Level 7+ — Parallel Agents
> Goal: multiple agents working on independent tasks simultaneously.

- [ ] `[Claude]` Enable agent teams in settings: `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": true`
- [ ] `[Claude]` Start with Superset: download and run 2 agents on genuinely independent tasks
- [ ] `[Claude]` Try the FD system: run `/fd-init`, write one real FD spec for your next task
- [ ] `[Claude]` Run `/fd-deep` (4 parallel Opus agents) on a complex task
- [ ] `[Claude]` Install the Dispatch skill for orchestrator-pattern without extra tooling
- [ ] Practice multi-model dispatch: one model for implementation, a different session/model for review
- [ ] Observe the practical ceiling: coordination overhead exceeds parallelism gain above 4–6 agents

### Path A — Long-horizon tasks (DeerFlow)
Works with any model provider, including Claude and Gemini via their APIs.
- [ ] Deploy DeerFlow via Docker: `git clone && make config && docker compose up`
- [ ] Delegate a research task that would take 30 minutes manually
- [ ] Milestone: use the DeerFlow output directly without rewriting it

### Path B — Persistent personal agent (Hermes)
- [ ] Install Hermes Agent via the install script
- [ ] Connect to one messaging platform (Telegram is simplest)
- [ ] Run for 10+ sessions; check skill stocktake
- [ ] Milestone: Hermes correctly anticipates a preference you never explicitly stated

### Path C — Team-scale async agent (Open SWE)
- [ ] Prerequisites: shared GitHub repo, Slack, Linear
- [ ] Deploy Open SWE with LangGraph Cloud and a sandbox provider (Modal)
- [ ] File a Linear issue, comment `@openswe`
- [ ] Milestone: agent opens a meaningful draft PR requiring minimal rework

---

## Anti-Patterns Checklist
> Review periodically. These are the failure modes.

- [ ] Am I shipping AI-generated code I don't understand? (comprehension debt)
- [ ] Is my context file (CLAUDE.md / copilot-instructions.md / GEMINI.md) over 100 lines? Is my MCP list longer than sessions need?
- [ ] Am I using the same session to implement and review?
- [ ] Is my human override rate trending toward zero without tracking why?
- [ ] Am I vibe-coding without maintaining a mental model of the system?

---

## Social Posts Unlock Conditions
> Share findings as you make them, not in advance.

- [ ] Week 1 complete → write Practical Post A (skills I use)
- [ ] Week 3 complete → write Practical Post B (how I solved the memory problem)
- [ ] Week 4 complete → write Practical Post C (three habits that changed my workflow)
- [ ] Any week → write Practical Post D (curation workflow)
