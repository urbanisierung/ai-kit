# ai-kit

Personal AI configuration, skills, hooks, and memory — shareable across machines.

## Bootstrap a new machine

```bash
git clone git@github.com:urbanisierung/ai-kit.git ~/github.com/urbanisierung/ai-kit
cp ~/github.com/urbanisierung/ai-kit/.env.example ~/github.com/urbanisierung/ai-kit/.env   # fill in real keys
bash ~/github.com/urbanisierung/ai-kit/tools/setup.sh
```

> The checkout path is the default. To use a different location, set `AI_KIT_REPO`
> before running setup: `AI_KIT_REPO=/your/path bash /your/path/tools/setup.sh`

## Structure

```
claude/         Claude Code config: CLAUDE.md, MCP, settings, hooks, skills
copilot/        GitHub Copilot instructions and agent profiles
gemini/         Gemini CLI config and global instructions
memory/         CORE.md — durable learnings promoted by pi-self-learning
tools/          setup.sh (bootstrap), sync.sh (pull + relink), install-tools.sh (CLI tools)
dotfiles/       .zshrc.ai — AI aliases, sourced automatically by setup.sh
```

## Sync

```bash
ai-sync          # alias from .zshrc.ai — pulls latest and re-runs setup
```

## Add a new skill

```bash
mkdir -p claude/skills/my-skill
touch claude/skills/my-skill/SKILL.md
# write frontmatter + steps, then:
git add . && git commit -m "feat: add my-skill"
```

The symlink in `~/.claude/skills/` picks it up immediately — no reinstall needed.
