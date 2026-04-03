# Claude Code Project Prompt Best Practices

> Extracted from Anthropic's official documentation, fetched 2026-04-03.
> Each section cites its source URL. Direct quotes are in blockquotes.
> The skill should also web-fetch fresh docs before generating prompts, as docs evolve.

## Sources

- [S1] https://code.claude.com/docs/en/memory -- "How Claude remembers your project"
- [S2] https://code.claude.com/docs/en/best-practices -- "Best Practices for Claude Code"
- [S3] https://code.claude.com/docs/en/sub-agents -- "Create custom subagents"
- [S4] https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices -- "Prompting best practices"

---

## 1. CLAUDE.md Fundamentals [S1]

> "CLAUDE.md files are markdown files that give Claude persistent instructions for a project, your personal workflow, or your entire organization. You write these files in plain text; Claude reads them at the start of every session." [S1]

> "CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself. Claude reads it and tries to follow it, but there's no guarantee of strict compliance, especially for vague or conflicting instructions." [S1]

> "The more specific and concise your instructions, the more consistently Claude follows them." [S1]

Key properties:
- Loaded into the context window every session, consuming tokens alongside your conversation
- Target under 200 lines per CLAUDE.md file; longer files reduce adherence
- Split large files using imports (`@path/to/file`) or `.claude/rules/` files
- Fully survives context compaction (re-read from disk after `/compact`)
- Check it into git so your team can contribute

> "Run `/init` to generate a starting CLAUDE.md automatically. Claude analyzes your codebase and creates a file with build commands, test instructions, and project conventions it discovers. If a CLAUDE.md already exists, `/init` suggests improvements rather than overwriting it." [S1]

## 2. What to Include vs Exclude [S2]

> "CLAUDE.md is loaded every session, so only include things that apply broadly. For domain knowledge or workflows that are only relevant sometimes, use skills instead. Claude loads them on demand without bloating every conversation." [S2]

> "Keep it concise. For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!" [S2]

Include / exclude table from [S2]:

| Include | Exclude |
|---------|---------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link to docs instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

> "If Claude keeps doing something you don't want despite having a rule against it, the file is probably too long and the rule is getting lost. If Claude asks you questions that are answered in CLAUDE.md, the phrasing might be ambiguous. Treat CLAUDE.md like code: review it when things go wrong, prune it regularly, and test changes by observing whether Claude's behavior actually shifts." [S2]

> "You can tune instructions by adding emphasis (e.g., 'IMPORTANT' or 'YOU MUST') to improve adherence." [S2]

Example CLAUDE.md from [S2]:
```markdown
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
```

## 3. Writing Effective Instructions [S1]

Four dimensions from [S1, "Write effective instructions"]:

**Size**: Target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence.

**Structure**: Use markdown headers and bullets to group related instructions. Claude scans structure the same way readers do.

**Specificity**: Write instructions concrete enough to verify:
- "Use 2-space indentation" instead of "Format code properly"
- "Run `npm test` before committing" instead of "Test your changes"
- "API handlers live in `src/api/handlers/`" instead of "Keep files organized"

**Consistency**: If two rules contradict each other, Claude may pick one arbitrarily. Review periodically to remove outdated or conflicting instructions. In monorepos, use `claudeMdExcludes` to skip CLAUDE.md files from other teams.

## 4. File Hierarchy and Scoping [S1]

Scope table from [S1]:

| Scope | Location | Purpose | Shared with |
|-------|----------|---------|-------------|
| Managed policy | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide, managed by IT/DevOps | All users in org |
| Project instructions | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared | Team via source control |
| User instructions | `~/.claude/CLAUDE.md` | Personal preferences, all projects | Just you |
| Local instructions | `./CLAUDE.local.md` | Personal project-specific; add to `.gitignore` | Just you (current project) |

Loading behavior from [S1]:
- Claude walks up the directory tree from the working directory, checking each directory for CLAUDE.md and CLAUDE.local.md
- All discovered files are concatenated into context rather than overriding each other
- CLAUDE.local.md is appended after CLAUDE.md at each level, so personal notes are read last when instructions conflict
- Subdirectory CLAUDE.md files load on demand when Claude reads files in those directories
- Block-level HTML comments (`<!-- ... -->`) are stripped before injection into context; use them for human-only notes without spending tokens

### Imports [S1]

> "CLAUDE.md files can import additional files using `@path/to/import` syntax. Imported files are expanded and loaded into context at launch alongside the CLAUDE.md that references them." [S1]

- Both relative and absolute paths allowed
- Relative paths resolve relative to the file containing the import, not the working directory
- Max depth of 5 hops for recursive imports

```
See @README for project overview and @package.json for available npm commands.
```

### AGENTS.md Compatibility [S1]

> "Claude Code reads `CLAUDE.md`, not `AGENTS.md`. If your repository already uses `AGENTS.md` for other coding agents, create a `CLAUDE.md` that imports it so both tools read the same instructions without duplicating them." [S1]

### Excluding CLAUDE.md Files [S1]

> "In large monorepos, ancestor CLAUDE.md files may contain instructions that aren't relevant to your work. The `claudeMdExcludes` setting lets you skip specific files by path or glob pattern." [S1]

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

## 5. .claude/rules/ Directory [S1]

> "For larger projects, you can organize instructions into multiple files using the `.claude/rules/` directory. This keeps instructions modular and easier for teams to maintain. Rules can also be scoped to specific file paths, so they only load into context when Claude works with matching files, reducing noise and saving context space." [S1]

> "Rules load into context every session or when matching files are opened. For task-specific instructions that don't need to be in context all the time, use skills instead, which only load when you invoke them or when Claude determines they're relevant to your prompt." [S1]

Structure example from [S1]:
```
your-project/
├── .claude/
│   ├── CLAUDE.md
│   └── rules/
│       ├── code-style.md
│       ├── testing.md
│       └── security.md
```

Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`.

### Path-specific rules [S1]

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All API endpoints must include input validation
- Use the standard error response format
- Include OpenAPI documentation comments
```

Glob patterns from [S1]:

| Pattern | Matches |
|---------|---------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` directory |
| `*.md` | Markdown files in the project root |
| `src/components/*.tsx` | React components in a specific directory |

Brace expansion supported: `"src/**/*.{ts,tsx}"`

### Symlinks and user-level rules [S1]
- `.claude/rules/` supports symlinks for sharing rules across projects
- Personal rules in `~/.claude/rules/` apply to every project; loaded before project rules (project rules have higher priority)

## 6. Subagent Files [S3]

> "Subagents are specialized AI assistants that handle specific types of tasks. Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions." [S3]

> "The frontmatter defines the subagent's metadata and configuration. The body becomes the system prompt that guides the subagent's behavior. Subagents receive only this system prompt (plus basic environment details like working directory), not the full Claude Code system prompt." [S3]

### File locations [S3]

| Location | Scope | Priority |
|----------|-------|----------|
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

> "Project subagents (`.claude/agents/`) are ideal for subagents specific to a codebase. Check them into version control so your team can use and improve them collaboratively." [S3]

### Frontmatter fields [S3]

Required:
- `name`: Unique identifier using lowercase letters and hyphens
- `description`: When Claude should delegate to this subagent (Claude uses this to decide when to delegate automatically)

Optional:
- `tools`: Tool allowlist (Read, Glob, Grep, Bash, Write, Edit, etc.). Inherits all if omitted. Use `Agent(agent_type)` to restrict which subagents can be spawned
- `disallowedTools`: Tools to deny, removed from inherited or specified list. If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first
- `model`: `sonnet`, `opus`, `haiku`, a full model ID (e.g., `claude-opus-4-6`), or `inherit`. Defaults to `inherit`
- `permissionMode`: `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`
- `maxTurns`: Maximum agentic turns before the subagent stops
- `skills`: Skills to load into the subagent's context at startup. Full content injected, not just made available. Subagents don't inherit skills from the parent
- `mcpServers`: MCP servers available to this subagent. Can be inline definitions or references to already-configured servers
- `hooks`: Lifecycle hooks scoped to this subagent (PreToolUse, PostToolUse, Stop)
- `memory`: Persistent memory scope: `user` (~/.claude/agent-memory/), `project` (.claude/agent-memory/), or `local` (.claude/agent-memory-local/)
- `background`: `true` to always run as a background task
- `effort`: `low`, `medium`, `high`, `max` (Opus 4.6 only)
- `isolation`: `worktree` for git worktree isolation
- `color`: Display color (`red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`)
- `initialPrompt`: Auto-submitted first user turn when running as main session agent

### Example from [S2]

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

### Built-in subagents [S3]

Claude Code includes built-in subagents: **Explore** (Haiku, read-only, fast codebase search), **Plan** (inherits model, read-only, research for plan mode), and **general-purpose** (inherits model, all tools, complex multi-step tasks).

## 7. General Prompting Principles [S4]

### Be clear and direct [S4]

> "Think of Claude as a brilliant but new employee who lacks context on your norms and workflows. The more precisely you explain what you want, the better the result." [S4]

> "**Golden rule:** Show your prompt to a colleague with minimal context on the task and ask them to follow it. If they'd be confused, Claude will be too." [S4]

### Add context / explain the why [S4]

> "Providing context or motivation behind your instructions, such as explaining to Claude why such behavior is important, can help Claude better understand your goals and deliver more targeted responses." [S4]

> "Claude is smart enough to generalize from the explanation." [S4]

Less effective: `NEVER use ellipses`
More effective: `Your response will be read aloud by a text-to-speech engine, so never use ellipses since the text-to-speech engine will not know how to pronounce them.`

### Use examples [S4]

> "Examples are one of the most reliable ways to steer Claude's output format, tone, and structure. A few well-crafted examples (known as few-shot or multishot prompting) can dramatically improve accuracy and consistency." [S4]

- Include 3-5 examples for best results
- Make them relevant, diverse, and structured
- Wrap in `<example>` tags

### Prefer positive over negative instructions [S4]

> Instead of: "Do not use markdown in your response"
> Try: "Your response should be composed of smoothly flowing prose paragraphs." [S4]

### XML tags for structure [S4]

> "XML tags help Claude parse complex prompts unambiguously, especially when your prompt mixes instructions, context, examples, and variable inputs." [S4]

### Give Claude a role [S4]

> "Setting a role in the system prompt focuses Claude's behavior and tone for your use case. Even a single sentence makes a difference." [S4]

### Avoid over-prompting for current models [S4]

> "Claude Opus 4.5 and Claude Opus 4.6 are also more responsive to the system prompt than previous models. If your prompts were designed to reduce undertriggering on tools or skills, these models may now overtrigger. The fix is to dial back any aggressive language. Where you might have said 'CRITICAL: You MUST use this tool when...', you can use more normal prompting like 'Use this tool when...'." [S4]

## 8. Verification and Workflow Patterns [S2]

### Verification is the highest-leverage instruction [S2]

> "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do." [S2]

> "Without clear success criteria, it might produce something that looks right but actually doesn't work. You become the only feedback loop, and every mistake requires your attention." [S2]

Verification strategies from [S2]:

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false. run the tests after implementing" |
| Verify UI changes visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot and compare" |
| Address root causes | "the build is failing" | "the build fails with this error: [paste]. fix it and verify the build succeeds" |

### Explore first, then plan, then code [S2]

Four-phase workflow from [S2]:
1. **Explore**: Enter Plan Mode. Claude reads files and answers questions without making changes
2. **Plan**: Ask Claude to create a detailed implementation plan
3. **Implement**: Switch to Normal Mode. Let Claude code and verify against its plan
4. **Commit**: Ask Claude to commit with a descriptive message and create a PR

> "Plan Mode is useful, but also adds overhead. For tasks where the scope is clear and the fix is small (like fixing a typo, adding a log line, or renaming a variable) ask Claude to do it directly. Planning is most useful when you're uncertain about the approach, when the change modifies multiple files, or when you're unfamiliar with the code being modified." [S2]

### Provide specific context [S2]

| Strategy | Before | After |
|----------|--------|-------|
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "add a calendar widget" | "look at how existing widgets are implemented on the home page. HotDogWidget.php is a good example. follow the pattern." |
| Describe the symptom | "fix the login bug" | "users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh." |

## 9. Agentic System Patterns [S4]

### Balancing autonomy and safety [S4]

> "Without guidance, Claude Opus 4.6 may take actions that are difficult to reverse or affect shared systems, such as deleting files, force-pushing, or posting to external services." [S4]

Sample prompt from [S4]:
```
Consider the reversibility and potential impact of your actions. You are encouraged to take local, reversible actions like editing files or running tests, but for actions that are hard to reverse, affect shared systems, or could be destructive, ask the user before proceeding.
```

### Minimizing overengineering [S4]

> "Claude Opus 4.5 and Claude Opus 4.6 have a tendency to overengineer by creating extra files, adding unnecessary abstractions, or building in flexibility that wasn't requested." [S4]

Sample prompt from [S4]:
```
Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused:
- Scope: Don't add features, refactor code, or make "improvements" beyond what was asked.
- Documentation: Don't add docstrings, comments, or type annotations to code you didn't change.
- Defensive coding: Don't add error handling for scenarios that can't happen.
- Abstractions: Don't create helpers or utilities for one-time operations.
```

### Minimizing hallucinations [S4]

```
<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file, you MUST read the file before answering. Make sure to investigate and read relevant files BEFORE answering questions about the codebase. Never make any claims about code before investigating unless you are certain of the correct answer.
</investigate_before_answering>
```

### Long-horizon reasoning and state tracking [S4]

> "Claude's latest models excel at long-horizon reasoning tasks with exceptional state tracking capabilities. Claude maintains orientation across extended sessions by focusing on incremental progress." [S4]

Key patterns from [S4]:
- Use structured formats (JSON) for state data like test results; freeform text for progress notes
- Use git for state tracking across sessions
- Write tests in structured format before starting work; remind Claude not to remove or edit tests
- Create setup scripts (`init.sh`) to avoid repeated work across context windows
- Encourage full usage of context: "Continue working systematically until you have completed this task"

### Reducing file creation [S4]

> "Claude's latest models may sometimes create new files for testing and iteration purposes." [S4]

Mitigation from [S4]: `"If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task."`

### Avoid focusing on passing tests / hard-coding [S4]

From [S4]: `"Write a high-quality, general-purpose solution using standard tools. Do not hard-code values or create solutions that only work for specific test inputs. Implement the actual logic that solves the problem generally."`

## 10. Common Failure Patterns [S2]

Directly from [S2, "Avoid common failure patterns"]:

- **The kitchen sink session.** Context full of irrelevant information from mixing unrelated tasks. Fix: `/clear` between unrelated tasks.
- **Correcting over and over.** Context polluted with failed approaches. Fix: After two failed corrections, `/clear` and write a better initial prompt.
- **The over-specified CLAUDE.md.** Too long, Claude ignores important rules lost in noise. Fix: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it or convert it to a hook.
- **The trust-then-verify gap.** Plausible implementation that misses edge cases. Fix: Always provide verification (tests, scripts, screenshots).
- **The infinite exploration.** Unscoped investigation fills the context. Fix: Scope investigations narrowly or use subagents.

## 11. Context Management [S2]

> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills." [S2]

Key strategies from [S2]:
- Use `/clear` frequently between tasks to reset context entirely
- Use `/compact <instructions>` for controlled summarization (e.g., `/compact Focus on the API changes`)
- Customize compaction behavior in CLAUDE.md: "When compacting, always preserve the full list of modified files"
- Use subagents for investigation to keep your main conversation clean
- Use `/btw` for quick questions that don't need to stay in context
- Start fresh sessions rather than compacting when doing long-horizon work [S4]

## 12. Scaling and Automation [S2]

- `claude -p "prompt"` for non-interactive / CI / scripted use
- `--output-format json` or `stream-json` for parsing results programmatically
- `--allowedTools` to restrict what Claude can do in unattended runs
- Run multiple sessions in parallel for throughput (separate context windows)
- Writer/Reviewer pattern: one session implements, another reviews with fresh context [S2]
