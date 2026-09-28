---
status: backlog
priority: P2
created: 2026-09-28
updated: 2026-09-28
tags: blog, build, maintenance
type: bug
issue_kind: slice
context: The checked-in Pages workflow selects a Ruby version rejected by Gemfile.
---

# Issue 001: Align the Pages Ruby version with the blog

## Problem

`Gemfile` requires `ruby '~> 3.2'`, but `.github/workflows/jekyll.yml` selects
Ruby `3.1`. This is a static configuration mismatch: that workflow runtime does
not satisfy the application's declared Ruby requirement. Hosted run status was
not checked during setup; do not infer the current live site's health from this.

## Context

- [`Gemfile`](../../../Gemfile): Ruby requirement and Jekyll dependencies.
- [`Gemfile.lock`](../../../Gemfile.lock): locked gems and Bundler `2.6.9`.
- [Pages workflow](../../../.github/workflows/jekyll.yml): Ruby setup and deploy trigger.
- Adoption environment: Ruby `3.3.0`; `bundle check` passed locally.

## Current Deployment Context

Publication preflight on 2026-09-28 confirmed that production uses the existing
Git-to-Vercel connection and the Pages workflow is `disabled_manually`.
This issue remains a Pages-only backlog item, not a blocker for Vercel publication.
See [the workflow guide](../../docs/blog-workflow.md) for hosting checks.

## Acceptance Criteria

- [ ] The workflow uses a supported Ruby version satisfying `Gemfile` and the
      locked dependency requirements; document the chosen local runtime too.
- [ ] Using that runtime, `bundle check` and
      `JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter` pass.
- [ ] Keep drafts and operator files out of the production build.
- [ ] Record local validation separately from any owner-approved hosted run.

## Non-Goals

- No push, manual workflow dispatch, or deployment without separate approval.
- No Hugo migration, platform switch, broad dependency upgrade, or unrelated
  GitHub Actions modernization.
