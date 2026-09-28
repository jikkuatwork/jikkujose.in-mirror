# jikkujose.in

A small Jekyll blog designed to remain readable without JavaScript.

## Manage the blog

This repo uses **koder-pattern** for session memory and a lightweight backlog.
Blog content stays in `_drafts/` and `_posts/`; operator notes stay in `koder/`.

In Pi, run `/reload` once after setup, then:

- `/skill:open` — see the current handoff, Git state, drafts, and next issues.
- Ask **"Start a draft about …"** or **"Help me finish this draft …"**.
- Ask **"Review this post before publishing"** for the publication checklist.
- Ask **"File a blog issue for …"** to save a follow-up without starting it.
- `/skill:close` — commit reviewed work and save the next session's handoff;
  it does not push or publish.

The same repo-local `open` and `close` skills are available to Codex and Claude.

- [Blog workflow](koder/docs/blog-workflow.md) — drafting, preview, review, publishing.
- [Current handoff](koder/STATE.md) — where the last session stopped.
- [Backlog](koder/issues/) — focused editorial and maintenance follow-ups.
- [Project history](CHANGELOG.md) — meaningful milestones, not live readiness.

## Local preview

Use a Ruby version satisfying `Gemfile` (`~> 3.2`, i.e. Ruby 3.2–3.x) and Bundler.

```bash
bundle check                         # Install missing dependencies with bundle install.
bundle exec jekyll serve --drafts --host 127.0.0.1
```

Open <http://127.0.0.1:4000>. Draft previews are local only. Some drafts have
`published: false`; the [workflow guide](koder/docs/blog-workflow.md) explains
how to preview those without changing their publication flags.
For a publication-style build, without drafts:

```bash
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter
```

Production uses the repository's existing Git-to-Vercel connection on `master`;
publishing requires explicit owner approval. Verify the pushed commit's Vercel
status and the public article on <https://jikkujose.in> before calling it live.
The checked-in Pages workflow is manually disabled (verified 2026-09-28); its
Ruby-version mismatch remains [issue 001](koder/issues/001_pages_ruby_version/INDEX.md),
not a prerequisite for the active Vercel route. A local build is not deployment
proof.
