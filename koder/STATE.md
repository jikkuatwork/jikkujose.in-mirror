---
updated_at: "28 Sep 2026 | 02:49 PM IST"
---

# Koder State

## Past

- Initialized koder-pattern (`a232117`) with shared `open`/`close` skills and
  relative adapters for Pi, Codex, and Claude.
- Added `koder/docs/blog-workflow.md`, a concise `CHANGELOG.md`, and focused
  editorial/maintenance issues. Existing posts, drafts, and layouts are unchanged.
- Excluded operator files/tooling from Jekyll output and ignored local build caches.
- Preserved `koder/plan-hugo-migration.md` as historical, unexecuted planning.

## Present

- The blog remains Jekyll; locked version is 4.3.4. Local validation used Ruby 3.3.0.
- Inventory at adoption: 26 post files and 11 drafts. Production renders 25 posts;
  `_posts/2025-07-10-energy-as-currency.md` explicitly has `published: false`.
- Seven drafts also have `published: false`; ordinary `--drafts` renders only four
  drafts. The workflow guide explains local-only `--unpublished` previews.
- No article is selected for editing or approved for publication. No queue is active.
- Backlog (not started):
  - P2: `koder/issues/001_pages_ruby_version/INDEX.md` — Pages selects Ruby 3.1,
    incompatible with `Gemfile`'s `~> 3.2` requirement. Hosted status is unverified.
  - P3: `koder/issues/002_electronics_draft_metadata/INDEX.md` — the latest draft,
    `_drafts/2026-03-09-rebuild-electronics.md`, lacks frontmatter.
  - P3: `koder/issues/003_petite_vue_liquid_examples/INDEX.md` — existing Vue
    interpolation examples trigger Liquid warnings in draft rendering.
- Validation: `bundle check`, koder-pattern doctor, scratch gate, YAML/frontmatter
  and local-link checks, and `git diff --check` passed. Init dry-run is a no-op.
- Production and `--drafts` builds with `--strict_front_matter` passed in temporary
  destinations (25/29 articles); expected site outputs exist and operator paths
  are absent. All four previewed drafts are absent from production. Draft rendering
  emitted the four existing warnings tracked in issue 003; no visual audit was done.
- Setup is local only: no push, deployment, content promotion, or dependency change.

## Future

- In Pi, `/reload` once to discover the new skills, then `/skill:open` to resume.
- Choose an existing draft to work on; issue 002 is a small starting point for the
  latest article. Resolve issue 001 before relying on the Pages publishing path.
- Keep publication and pushing behind explicit owner approval; the Hugo note is
  not an active migration request.
- Use `/skill:close` to save reviewed work and the next handoff without publishing.
