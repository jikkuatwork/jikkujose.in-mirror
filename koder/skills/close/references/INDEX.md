# Close Index

Use this index as the first loaded reference for this skill. Render the final hand-off with `FORMAT.md`.

# Close Session

Use this skill at the end of a real interactive work session or explicit durable
handoff. Do not invoke it for every phase worker or internal coordinator rollover;
those use compact receipts and batched checkpoints. A close is complete only when
every intentional change is committed and the working tree plus index are clean.
Do not claim success while `git status --porcelain=v1 --untracked-files=all`
prints anything.

## Workflow

1. Establish the repository root and inspect the complete delta, including staged, unstaged, and untracked work:
   ```bash
   git status --short --untracked-files=all
   git diff HEAD --stat
   git diff HEAD
   git diff --cached --name-only
   git ls-files --others --exclude-standard
   ```
   If this is not a Git repository, initialize it only when the user has asked to use the koder pattern or otherwise approved repository initialization.
2. Review every changed path before committing. Check implementation, docs, tests, deleted files, permissions, and untracked files. Inspect for secrets, credentials, private payloads, generated output, caches, and unrelated work. Never use `git add -A` blindly.
3. Run the repository's relevant tests, linters, formatters, validators, and `git diff --check`. Record failures honestly. Do not commit code that is known incomplete or unreviewed merely to make the status green.
4. Run the scratch retention gate after tests and validators, before committing:
   ```bash
   koder/skills/close/bin/scratch-invariant.sh
   ```
   The gate recursively checks durable scratch artifacts (`*.md`, `*.patch`, `*.txt`). Promote or delete each artifact, or cover it with an active entry in `koder/SCRATCH_RETAIN.jsonl`, then rerun the gate until its JSON report is clean. Use `KODER_SCRATCH_DIR`, `KODER_SCRATCH_RETAIN_PATH`, or the comma-separated basename list `KODER_SCRATCH_EXCLUDE` only when repository policy declares a different path or runtime-pad exemption. The ledger is durable and must be committed with the close. Any emergency bypass belongs in the repository's surrounding close wrapper, must be explicitly authorized and loudly reported, and does not count as a clean gate.
5. Commit all reviewed, intentional work in logical commits. Stage selected paths only. If unrelated or unknown dirty work exists, stop and ask rather than absorbing it or deleting it. A successful close must not strand reviewed work.
6. Refresh `koder/STATE.md` with the India-time timestamp:
   ```bash
   TZ='Asia/Kolkata' date '+%d %b %Y | %I:%M %p IST'
   ```
   Keep it under 100 lines and update its Past/Present/Future hand-off. The hand-off change itself must be included in a grepable commit with subject `state: close - <semantic result>` and the commit body must name `State file: koder/STATE.md`, the session result, delta, and validation.
7. Re-run the final review after the state commit:
   ```bash
   wc -l koder/STATE.md
   koder/skills/close/bin/scratch-invariant.sh
   git diff --check
   git status --short --untracked-files=all
   git diff --cached --name-only
   git log --grep='^state:' --oneline -5
   ```
8. Render `FORMAT.md` only after the final status check. Use `Git clean` only when both the index and working tree are empty. Report upstream ahead/behind separately; do not push or rewrite history unless the repository instructions or the user explicitly require it.

## Completion invariant

- **Clean close:** the scratch retention gate reports `clean`; no output from `git status --porcelain=v1 --untracked-files=all`; all intended work and any `koder/SCRATCH_RETAIN.jsonl` change are in commits; `koder/STATE.md` is current and under 100 lines; validation results are reported.
- **Blocked close:** if the scratch gate is skipped or non-clean, or any path is unknown, unsafe, incomplete, unreviewed, or cannot be committed safely, do not pretend the session closed. Render `Session Close Blocked`, list exact paths and the reason, and name the next action.
- A pre-existing dirty tree is not an excuse to skip the scratch gate or final check. Either resolve retained scratch and review and commit the intentional paths, or leave the close explicitly blocked.

## Rules

- Preserve unrelated dirty/staged work; never reset, discard, force-push, or overwrite it to manufacture cleanliness.
- Never commit secrets, credentials, caches, build outputs, or private data.
- Do not commit failed or incomplete implementation work just to satisfy the clean-state invariant; ask for a decision when needed.
- Routine artifacts/status changes belong in logical work commits or batched checkpoints; do not create standalone `state:` commits merely to prepare close.
- If a user explicitly says not to commit, report the resulting dirty paths and mark the close blocked rather than claiming a clean close.
