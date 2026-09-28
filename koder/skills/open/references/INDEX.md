# Open Index

Use this index as the first loaded reference for this skill. Render the final hand-off with `FORMAT.md`.

# Open Session

Use this skill at the beginning of a work session in this repository. Opening is observational: do not modify files, start services, repair drift, or commit anything.

## Workflow

1. Locate the repository root from the current working directory.
2. Read `koder/STATE.md` completely before making changes. Treat it as the durable narrative hand-off.
3. Locate the repository's established project-history surface. Prefer root `CHANGELOG.md`; otherwise preserve and use an existing top-level or `docs/` changelog, changes, history, news, or release-notes file, or a release-notes directory such as `.changeset/`, `release-notes/`, or `releases/`. Do not invent a second history surface.
4. When a history surface exists, read no more than 100 lines of its newest-first content—one entrypoint or newest release file, not the whole archive. Use it only as historical grounding; `koder/STATE.md`, live Git facts, and current validation take precedence. If repository instructions require history tracking and none exists, note that without creating it during `open`.
5. When `koder/docs/EXECUTION.md` exists, read it completely and surface only the active authorization window, allowed scope, stop gate, and hard orchestration/context mode. Do not activate future windows or follow their linked implementation sources during `open`.
6. If state/execution declares `orchestration_mode: blind`, report that the primary must route isolated fresh workers and consume compact receipts rather than implement or ingest implementation detail.
7. Inspect live repository facts:
   ```bash
   git status --short --untracked-files=all
   git branch --show-current
   git log --oneline -5
   git rev-list --left-right --count @{u}...HEAD 2>/dev/null || true
   ```
   If this is not a Git repository, say so clearly and continue with the file-based hand-off.
8. Summarize the hand-off as **Past**, **Present**, and **Future**. Include dirty/staged/untracked paths, branch and upstream drift, when relevant. Use project history only to clarify meaningful movement that the compact hand-off omits.
9. Render the response using `FORMAT.md`:
   - use `━━━` separators, not Markdown horizontal rules;
   - keep the stat block compact;
   - omit **Notes** when there is nothing that needs attention;
   - use inline code for paths, commits, and issue numbers;
   - finish with one judgment line and one suggested next action.
10. Ask what the user wants to do next unless they already gave a concrete task. When an active window exists, make the default suggestion that bounded window and include its stop condition. For blind mode, say that “yes” routes isolated fresh workers—not direct implementation in the primary context.

## Output contract

The opening report should make it immediately obvious whether the repository is safe to start work in. Never describe a dirty repository as clean. If `koder/STATE.md` is missing, say so prominently and offer to create it; do not silently invent a hand-off.

## Rules

- Do not modify files as part of opening unless the user explicitly asks.
- Do not auto-repair dirty state, stale artifacts, services, remotes, or version drift.
- Do not dump secrets or private account details into the report.
- Do not start workers, preload queue plans, or repair orchestration state during opening.
- Prefer concise bullets over copied history; link to deeper artifacts by path instead of reading them speculatively.
