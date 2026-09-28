---
status: backlog
priority: P3
created: 2026-09-28
updated: 2026-09-28
tags: blog, editorial, drafts
type: docs
issue_kind: slice
context: The latest draft has article text but no Jekyll frontmatter for normal post rendering.
---

# Issue 002: Make the electronics draft preview-ready

## Problem

[`_drafts/2026-03-09-rebuild-electronics.md`](../../../_drafts/2026-03-09-rebuild-electronics.md)
starts directly with a heading. It has no `layout`, `title`, or summary metadata,
so a successful build alone is not proof that it renders as a normal blog post.
The article body has been left unchanged during koder-pattern adoption.

## Acceptance Criteria

- [ ] Add valid frontmatter using the ordinary `post` layout and a title/summary
      consistent with the draft; preserve its voice and body unless asked to edit.
- [ ] Run `bundle exec jekyll build --drafts --strict_front_matter` and inspect
      the generated page's title, layout, and body.
- [ ] Confirm the draft is absent from a production build without draft flags.
- [ ] Leave the draft under `_drafts/`; publication and substantive editorial
      review remain owner decisions.

## Non-Goals

- No automatic publication, date/slug changes, or bulk draft cleanup.
- No technical fact-check or rewrite is implied by adding metadata.
