# Agent Instructions

This repo uses the koder pattern for durable agent handoff and project memory.

## Operator layout

- Keep durable non-code agent/operator files under `koder/`.
- Keep one physical copy of shared skills under `koder/skills/`. Root `AGENTS.md` (Pi/Codex), `CLAUDE.md` (Claude), `.pi/skills/*` (Pi), `.agents/skills/*` (Codex), and `.claude/skills/*` (Claude) should be relative symlinks/adapters to files under `koder/` when possible.
- `README.md` is the root documentation exception because repository hosts render it directly; prefer other durable docs under `koder/docs/` unless project conventions require otherwise.
- Do not put product source code under `koder/` unless the project explicitly says so.

## Session handoff

- Use the `open` skill at the start of a session.
- Use the `close` skill at the end of a session; it updates `koder/STATE.md` and creates a grepable `state: close - ...` commit for the semantic state transition.
- Read `koder/STATE.md` before making changes when opening manually.
- Keep `koder/STATE.md` short and current; update it at init, close, explicit handoff requests, or external-origin filings into this repo.
- Do not put secrets, private payloads, full prompts, credentials, or large copied source/output into `koder/`.

## Project history

- Reuse the repository's established changelog, release-notes, or equivalent history surface; never create a competing `CHANGELOG.md` when one already exists.
- When no equivalent exists, maintain root `CHANGELOG.md` as a concise, newest-first record of meaningful project milestones. Use umbrella entries rather than mirroring every commit or session.
- During `open`, read no more than 100 lines from the newest history content. It provides historical grounding only; `koder/STATE.md`, live Git facts, and current validation remain authoritative for present readiness.
- Update project history for material product, compatibility, documentation, or repository-operations milestones—not routine handoff-only or metadata-only changes.

## Commits and state

- Routine artifact/status changes ride with the logical work commit or a batched resumable checkpoint; do not create one commit per queue row, review approval, or frontmatter edit.
- Use standalone `state:` commits only when operator state is itself the milestone: scaffold init, real session handoff, external filing, owner authorization/block/acceptance, or a process-only checkpoint.
- `koder/STATE.md` is the compact session handoff, not a commit-by-commit ledger. Update it only at init, real close/handoff, explicit user request, or external filing.
- Phase workers and internal coordinators do not run the user-facing close skill merely to rotate context.
- In dirty repos, commit selected intended paths and preserve unrelated dirty/staged work. If the user says not to commit, report the remaining paths.

## Koder artifacts

- Minimum scaffold: `koder/STATE.md`, `koder/issues/`, `koder/skills/open/`, and `koder/skills/close/`.
- Create other artifact directories only when needed, for example `koder/proposals/`, `koder/plans/`, `koder/reviews/`, `koder/research/`, `koder/analysis/`, `koder/notes/`, `koder/tasks/`, `koder/queue/`, or `koder/scratch/`.
- Use folder-first artifacts for durable records: `koder/<type>/NNN_short_slug/INDEX.md`.
- Use `koder/proposals/` for RFC-scale ideas that should converge before issues/plans are extracted.
- Treat `INDEX.md` as canonical current state; use `turns/` only for optional discussion/history.
- Scan existing artifacts before choosing the next number; each artifact type has its own sequence.
- Prefer source links, file paths, command names, commits, and concise evidence over copied detail.
- Run local validators before finalizing artifacts when validators exist.

## Queue orchestration

- Apply koder-pattern's delivery-first gate before adding machinery. A queue does not imply blind mode, Harnex does not imply a chain, and owner-present planning/docs/metadata default to direct work or one supervised worker.
- Disclose product outcome, expected workers/artifacts, wall budget, and stop gate before planning-only or blind work. Stop planning after two dispatches or 30 minutes without product delta unless the owner re-authorizes it.
- `orchestration_mode: blind` is explicit opt-in. Load the skill's blind route only then; keep repo-local policy to authorization, review boundary, ownership, validation, caps, and forbidden actions.
- Coordinators own compact process accounting directly. Do not dispatch metadata-finalizer workers or require clean-review Markdown artifacts when a typed receipt plus queue checkpoint is sufficient. Two no-op/boot/permission attempts open the circuit breaker.
- Blind mode fails closed if its declared isolation/review boundary cannot be enforced. Recover from receipts, commits, artifacts, and Git at the first unproven phase rather than replaying work.
- Automatic dispatches follow the operator's `dispatch_models` policy (GPT-family by default; Claude is manual/interactive only). Never substitute an out-of-policy model to keep a queue moving — block and return to the owner.

## Safety

- Never commit secrets, credentials, private account identifiers, sensitive personal data, private payloads, full prompts, or large generated outputs.
- Ask before running commands that deploy, create cloud resources, mutate production data, install packages globally, rotate credentials, or change account/member access.
- Preserve live project conventions; these instructions are the operator baseline, not a replacement for project-specific policy.
