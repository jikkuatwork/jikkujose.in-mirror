---
status: backlog
priority: P3
created: 2026-09-28
updated: 2026-09-28
tags: blog, drafts, rendering
type: bug
issue_kind: slice
context: Jekyll interprets Petite Vue interpolation examples as Liquid during draft previews.
---

# Issue 003: Preserve Petite Vue examples in draft rendering

## Problem

[`_drafts/2025-03-02-petite-vue-components.md`](../../../_drafts/2025-03-02-petite-vue-components.md)
contains literal Vue interpolation in prose and fenced code. Jekyll processes
Liquid before Markdown, so code fences do not protect those examples.

During adoption, `bundle exec jekyll build --drafts --strict_front_matter`
completed with four Liquid syntax warnings from this existing draft. Other
interpolations may be silently consumed. A successful exit is not enough to
prove the code examples are preserved.

## Acceptance Criteria

- [ ] Protect literal Vue syntax in this draft from Liquid evaluation using
      narrowly scoped escaping/raw blocks or another verified per-document approach.
- [ ] The draft build produces no Liquid warnings from this file.
- [ ] Inspect rendered prose and code examples: Vue interpolations remain literal
      and copyable rather than disappearing or being partially evaluated.
- [ ] Production still omits the draft; preserve its content and unpublished state.

## Non-Goals

- No global Liquid disabling, tutorial rewrite, dependency change, or publication.
