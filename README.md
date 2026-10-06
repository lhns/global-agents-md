# agents-md

Global, tool-agnostic instructions for coding agents, kept short so they help in any project without costing many tokens.

| File | Purpose |
| --- | --- |
| `AGENTS.md` | Portable guidelines for any agent: approach, verification, cleanup, writing, ADRs. |
| `claude-global.md` | Claude Code only: imports `AGENTS.md`, adds model and delegation defaults (Opus plans and coordinates, Sonnet implements, Fable advises). |

## Install

Clone the repo anywhere, then run the installer from it:

```sh
./install.sh      # macOS/Linux/Git Bash
install.bat       # Windows cmd
```

Re-run it any time to update. What it does:

- **Claude Code:** adds `@<repo>/claude-global.md` to `~/.claude/CLAUDE.md`. The import is live, so repo edits apply without re-running; a re-run fixes the path if the repo moved.
- **Codex** (if `~/.codex` exists): symlinks `AGENTS.md` to `~/.codex/AGENTS.md`, or copies it on Windows. Copies are updated on re-run unless you edited them.
- Asks before changing a file it didn't create (backup as `.bak`; default no). It warns about `~/.claude/AGENTS.md`, which Claude Code doesn't load at user level, and about `~/.codex/AGENTS.override.md`, which shadows the installed file.

The delegation rules assume `/advisor fable` (`"advisorModel": "fable"` in `~/.claude/settings.json`). Nested subagents are capped at depth 3 by default; set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` in the settings `env` for deeper trees.

### Other tools

- **Gemini CLI:** symlink or copy `AGENTS.md` to `~/.gemini/GEMINI.md`.
- **Cursor / Copilot:** paste `AGENTS.md` into the user-level rules or personal instructions.

### Single repo instead of global

Use this to share the guidelines with a team, or to try them in one project. Don't combine it with the global install, or every rule loads twice.

- **Shared with the team (committed):** copy `AGENTS.md` to the repo root; Codex, Cursor, Copilot and Claude Code read it there. For the Claude delegation rules, also copy `claude-global.md` to the repo root as `CLAUDE.md`. It already starts with `@AGENTS.md`. Note that Claude Code skips a project `AGENTS.md` once a `CLAUDE.md` exists, so the import is what keeps it loaded.
- **Just for you (not committed):** create `CLAUDE.local.md` in the repo root containing `@<path-to-this-clone>/claude-global.md`, and add `CLAUDE.local.md` to `.gitignore`.
- **Existing `AGENTS.md`/`CLAUDE.md`:** merge the sections you want rather than overwriting. If you merge into an existing `CLAUDE.md`, add an `@AGENTS.md` line so both load.

## Verify

In a new Claude Code session outside this repo:

- `/memory` lists both files.
- `/doctor prompt-audit` reports no outdated or conflicting instructions.
- Or ask: `claude -p "List the section headings of your user-level instructions"`.

## Editing

- Keep it short. Every line costs tokens in every session, and long instruction files lower adherence.
- Add a rule only after an agent repeats the same mistake. Phrase it as a default with a reason, not in caps or as MUST.
- Repo-level `AGENTS.md`/`CLAUDE.md` files take precedence; keep project-specific rules there.
