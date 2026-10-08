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
- **Claude Code settings:** adds `"claudeMdExcludes": ["**/.claude/global-agents-md/**"]` to `~/.claude/settings.json`, which skips vendored copies in repos (see "Single repo" below). Existing settings are kept; a backup is saved as `settings.json.bak`.
- Asks before changing an instruction file it didn't create (backup as `.bak`; default no); the settings exclude above is added without asking. It warns about `~/.claude/AGENTS.md`, which Claude Code doesn't load at user level, and about `~/.codex/AGENTS.override.md`, which shadows the installed file.

The delegation rules assume `/advisor fable` (`"advisorModel": "fable"` in `~/.claude/settings.json`). Nested subagents are capped at depth 3 by default; set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` in the settings `env` for deeper trees. Without subagents, `/model opusplan` gives a similar split at the harness level (Opus in plan mode, Sonnet for execution).

### Other tools

- **Gemini CLI:** symlink or copy `AGENTS.md` to `~/.gemini/GEMINI.md`.
- **Cursor / Copilot:** paste `AGENTS.md` into the user-level rules or personal instructions.

### Single repo instead of global

Use this to share the guidelines with a team, or to try them in one project.

- **Shared with the team (committed):** copy `AGENTS.md` and `claude-global.md` into `<repo>/.claude/global-agents-md/`, then add `@.claude/global-agents-md/claude-global.md` to the repo's `CLAUDE.md` (create it if missing). Anyone with the global install skips the vendored copy via the settings exclude above, so nothing loads twice. Re-copy to update.
  - Codex, Cursor and Copilot read only the root `AGENTS.md`. To support them, also copy `AGENTS.md` to the repo root. Claude Code ignores a root `AGENTS.md` when a `CLAUDE.md` exists, so Claude still loads the rules once; Codex has no exclude, so it loads both copies for people with the global Codex install.
- **Just for you (not committed):** create `CLAUDE.local.md` in the repo root containing `@<absolute path to this clone>/claude-global.md`, and add it to `.gitignore`. It's the same file as the global import, so Claude Code loads it once.
- **Existing `AGENTS.md`/`CLAUDE.md`:** merge the sections you want rather than overwriting.

## Verify

In a new Claude Code session outside this repo:

- `/memory` lists `~/.claude/CLAUDE.md`, `claude-global.md` and `AGENTS.md`.
- `/doctor prompt-audit` reports no outdated or conflicting instructions.
- Or ask: `claude -p "List the section headings of your user-level instructions"`.

## Editing

- Keep it short. Every line costs tokens in every session, and long instruction files lower adherence.
- Add a rule only after an agent repeats the same mistake. Phrase it as a default with a reason, not in caps or as MUST.
- Repo-level `AGENTS.md`/`CLAUDE.md` files take precedence; keep project-specific rules there.
