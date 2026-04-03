# prompting-buddy

A Claude Code skill that writes your `CLAUDE.md`, `.claude/rules/`, and `.claude/agents/` files for you — grounded in Anthropic's official best practices.

You describe your project. Prompting Buddy scans your repo, asks a few sharp questions, and writes prompt files directly into your project. No copy-paste, no guesswork about what belongs in CLAUDE.md vs rules vs agents.

## What it does

1. **Fetches the latest official docs** from Anthropic before writing anything — so the advice never goes stale
2. **Scans your repo** to detect tech stack, build tools, linting config, CI setup, and existing prompt files
3. **Asks targeted questions** to fill gaps the code doesn't reveal (workflow, conventions, team quirks)
4. **Generates prompt files** — CLAUDE.md under 200 lines, path-scoped rules, properly formatted agent definitions
5. **Self-reviews** against a checklist before writing: no codebase tours, no teaching basics, no bloat
6. **Writes files directly** into your project — or falls back to markdown blocks if you prefer

It also **reviews and optimizes** existing CLAUDE.md files — trimming redundant emphasis, removing self-evident rules, and restructuring for better adherence.

## Install

Download the latest `prompting-buddy.skill` from [Releases](../../releases), then in Claude Code:

```
/skill install path/to/prompting-buddy.skill
```

Or clone this repo into your skills directory:

```bash
git clone https://github.com/YOUR_USERNAME/prompting-buddy.git ~/.claude/skills/prompting-buddy
```

## Usage

Once installed, the skill triggers automatically when you ask Claude Code things like:

- *"Set up CLAUDE.md for this project"*
- *"I need rules files scoped to each service in my monorepo"*
- *"Create a code-review agent"*
- *"My CLAUDE.md is too long and Claude keeps ignoring half of it — fix it"*
- *"Migrate my .cursorrules to Claude Code"*

Or invoke it directly:

```
/prompting-buddy set up Claude Code for this project
```

### Example: monorepo with 3 services

```
> I have a Python monorepo with api-gateway (FastAPI), ml-pipeline (PyTorch),
> and data-ingestion (Airflow). Each has different conventions. Set me up.
```

Prompting Buddy generates:

```
Created:
  ./CLAUDE.md                              (78 lines)
  ./.claude/rules/api-gateway.md           (24 lines, paths: services/api-gateway/**)
  ./.claude/rules/ml-pipeline.md           (18 lines, paths: services/ml-pipeline/**)
  ./.claude/rules/data-ingestion.md        (20 lines, paths: services/data-ingestion/**)
  ./.claude/agents/code-reviewer.md        (32 lines, model: sonnet, read-only)
```


## Contributing

The best way to improve this skill is to run evals, review the outputs, and iterate on `SKILL.md`. If Claude generates bad prompt files for a particular project type, add it as a new eval case in `evals/evals.json` and use it to drive the fix.

## License

MIT
