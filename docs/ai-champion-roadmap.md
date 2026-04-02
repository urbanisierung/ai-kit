# AI Champion Roadmap

Structured action plan based on [`ai-champion.md`](./ai-champion.md).
Work through each level in order — every level is a prerequisite for the next.

---

## Level 0 — Foundation: AI Resources Repository
> Goal: one git repo that survives machine changes and holds every config, skill, and learning.

- [ ] Create the repo structure (`claude/`, `copilot/`, `gemini/`, `memory/`, `tools/`, `dotfiles/`)
- [ ] Write `.gitignore` (exclude `.env`, `*.local`)
- [ ] Create `.env` with real API keys (never commit)
- [ ] Write `claude/CLAUDE.md.global` with communication style and behavior rules
- [ ] Write `claude/mcp.json.template` with `${VAR_NAME}` placeholders
- [ ] Write `claude/settings.json.template`
- [ ] Write `claude/hooks/post-tool-use.sh` (starter hook, even if empty)
- [ ] Write `copilot/copilot-instructions.md`
- [ ] Write `gemini/GEMINI.md.global`
- [ ] Write `memory/CORE.md` (empty placeholder)
- [ ] Write `dotfiles/.zshrc.ai` with AI aliases (`cc`, `cca`, `ai-sync`, `ai-env`)
- [ ] Write `tools/setup.sh` (idempotent: symlinks configs, runs `envsubst` on templates)
- [ ] Write `tools/sync.sh` (git pull + re-run setup)
- [ ] Run `bash tools/setup.sh` on current machine
- [ ] Push to a private remote repo
- [ ] Verify: `git clone && bash tools/setup.sh` reproduces full setup from scratch

---

## Level 3 — Context Engineering (CLAUDE.md)
> Goal: Claude's default behavior matches your preferences without prompting.

- [ ] Review the existing `CLAUDE.md` in this repo as a reference
- [ ] Trim global `CLAUDE.md` to under 100 lines
- [ ] Add the rule: "Respond as concisely as possible; remove unnecessary politeness"
- [ ] Add a subdirectory `CLAUDE.md` for any subtree that has different conventions
- [ ] Use `@imports` for long reference docs instead of inlining them
- [ ] After each session where you correct Claude, add one rule to `CLAUDE.md`
- [ ] Prune rules that haven't fired after 10 sessions

---

## Level 4 — Compounding Engineering
> Goal: each cycle of work improves future cycles; 80% planning and review, 20% execution.

- [ ] Install the compound-engineering plugin: `/plugin marketplace add EveryInc/compound-engineering-plugin`
- [ ] Install it: `/plugin install compound-engineering`
- [ ] Run `/ce:plan` on a real backlog task instead of just prompting
- [ ] Run `/ce:work` to execute with worktree isolation and task tracking
- [ ] Run `/ce:review` before merging any agent-produced code
- [ ] Run `/ce:compound` after the task — review the extracted learnings
- [ ] Commit the learnings output to `memory/` in your ai-kit repo
- [ ] Repeat the Plan → Delegate → Assess → Codify loop on 3 real tasks

---

## Level 5a — Skills and Extensions
> Goal: Claude gains specialized capabilities without permanently consuming context.

- [ ] Install `skill-creator` from skills.sh first (meta-skill for writing skills)
- [ ] Install Superpowers: `/plugin install superpowers@claude-plugins-official`
- [ ] Run Superpowers on a real task; observe the brainstorm → plan → implement loop
- [ ] Write your first custom `SKILL.md` for a routine task you repeat
- [ ] Copy the skill to `claude/skills/` in your ai-kit repo and symlink back
- [ ] Browse [skills.sh](https://skills.sh/) and install 2–3 skills that match your workflow
- [ ] Study [Sentry's skills](https://github.com/getsentry/skills) for the subagent delegation pattern
- [ ] Add `AGENTS.md` to the repo root (recognized by Claude, Copilot, Gemini, Cursor)
- [ ] Optional: run `/harness-audit` from Everything Claude Code to score your setup

---

## Level 5b — MCP Servers
> Goal: Claude can search the web and reach external systems; MCP cost is managed.

- [ ] Run `/context` in a fresh session — note what % is consumed before you type anything
- [ ] Get a Brave Search API key and add the MCP: `claude mcp add brave-search ...`
- [ ] Add DeepWiki MCP to `mcp.json.template`
- [ ] Sign up at console.x.ai; add Grok MCP for X/Twitter search + large free tier
- [ ] Store all new keys in `ai-kit/.env` and update `mcp.json.template` with placeholders
- [ ] Test: ask Claude to research something — it should search without you pasting URLs
- [ ] Disable MCPs not needed in the current session (confirm this is a habit, not set-and-forget)
- [ ] Optional: add mem0 MCP for cross-session memory: `npx mcp-add --name mem0-mcp --type http --url "https://mcp.mem0.ai/mcp"`

---

## Level 5c — Prompting Discipline
> Goal: better first responses; fewer correction loops.

- [ ] Before every non-trivial task: write one sentence starting with "because"
- [ ] Use Plan Mode (`Shift+Tab`) to iterate on the plan before any code is written
- [ ] Try the inline annotation pattern: edit spec file directly, add `%%` notes, tell Claude `check %% notes`
- [ ] At the end of long sessions: ask "Summarize what changed, assumptions made, and what you'd do differently"
- [ ] For any review pass: use a separate session or model — don't let the same instance grade its own exam
- [ ] Run the Pandya-style power prompt on something real in this repo and observe the parallelism

---

## Level 5d — Token Management and Observability
> Goal: know exactly what the context window contains; stop burning tokens on noise.

- [ ] Install claude-hud: `/plugin marketplace add jarrodwatts/claude-hud && /plugin install claude-hud`
- [ ] Run `/claude-hud:setup` then `/claude-hud:configure` — enable agent and todo lines
- [ ] Install RTK: `brew install rtk` (macOS) or use the curl installer (Linux)
- [ ] Run `rtk init -g` to install the hook for Claude Code
- [ ] Run `rtk gain` at the end of your next session — note the savings
- [ ] Run `/context` before any heavy session; investigate if > 15% is pre-consumed
- [ ] Install last30days skill: `/plugin marketplace add mvanhorn/last30days-skill`
- [ ] Run `/last30days <current topic>` and review the Polymarket section
- [ ] Habit: use `/compact` or start a fresh session when the context bar turns yellow

---

## Level 6 — Hooks and Persistent Memory
> Goal: Claude detects its own errors without you pointing them out; sessions start with context from previous ones.

### Hooks (backpressure)
- [ ] Add a `PostToolUse` hook that runs your linter after every file write
- [ ] Verify the hook fires and Claude corrects lint errors without prompting
- [ ] Keep hooks fast — slow hooks degrade the feedback loop (target < 2s)
- [ ] Optional: install Rudel for session analytics: `npm install -g rudel && rudel login && rudel enable`

### Persistent Memory
- [ ] Install pi-self-learning: `npm install -g @pi-labs/cli && pi install npm:pi-self-learning`
- [ ] After one week, run `/learning-month` and review the output
- [ ] Commit the resulting `CORE.md` to `ai-kit/memory/`
- [ ] Set up mem0 cloud (or self-hosted) and store the key in `.env`
- [ ] Habit: at session end, tell Claude "Save key decisions from this session to memory"
- [ ] Habit: at session start on a returning topic, tell Claude "Check memory for context on [topic]"
- [ ] After two weeks: ask Claude "what do I usually prefer for X?" — it should answer from memory

### Sandbox Safety
- [ ] Install jai (Linux): build from source or AUR
- [ ] Run `jai claude` before testing any new skill or hook for the first time
- [ ] Use `jai --mode strict` before delegating any long autonomous task

---

## Level 7 — Remote Setup (Always-On Agent Server)
> Goal: an always-on agent server reachable from anywhere; no laptop dependency.

- [ ] Provision a Hetzner CX22 (~€4/month) with Ubuntu 24.04
- [ ] Harden the server: create `dev` user, copy SSH key, disable password auth
- [ ] Install Node.js 22 via nvm; install opencode: `npm install -g opencode-ai`
- [ ] Create `/home/dev/.env` with API keys (not committed)
- [ ] Start a persistent tmux session: `tmux new-session -s main`
- [ ] Write and enable a systemd service for headless OpenCode on port 3000
- [ ] Clone your ai-kit repo and run `bash tools/setup.sh` on the server
- [ ] Install Tailscale for private access: `curl -fsSL https://tailscale.com/install.sh | sh`
- [ ] Write `tools/setup-remote.sh` and `tools/update-remote.sh` in ai-kit
- [ ] Milestone: kick off a long background task from your phone via SSH

---

## Level 7+ — Parallel Agents
> Goal: multiple agents working on independent tasks simultaneously.

- [ ] Enable agent teams in settings: `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": true`
- [ ] Start with Superset: download and run 2 agents on genuinely independent tasks
- [ ] Review both outputs side-by-side before merging anything
- [ ] Try the FD system: run `/fd-init`, write one real FD spec for your next task
- [ ] Run `/fd-deep` (4 parallel Opus agents) on a complex task
- [ ] Practice multi-model dispatch: Opus → implementation, Sonnet → review
- [ ] Install the Dispatch skill for orchestrator-pattern without extra tooling
- [ ] Observe the practical ceiling: coordination overhead exceeds parallelism gain above 4–6 agents

### Path A — Long-horizon tasks (DeerFlow)
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
- [ ] Is my CLAUDE.md over 100 lines? Is my MCP list longer than sessions need?
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
