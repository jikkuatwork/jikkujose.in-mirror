# Blog workflow

Keep this a writing workflow, not a project-management system. Work directly on
one draft or maintenance issue; introduce plans or queues only when needed.

## Sources of truth

- `_drafts/`: unfinished writing. Keep existing dated filenames; new drafts use
  `YYYY-MM-DD-short-slug.md`. A draft's existence does not imply it is ready.
- `_posts/`: posts eligible for publication, subject to frontmatter and dates.
  File counts are not proof of what is currently live.
- `assets/`: images, audio, styles, and scripts. Use site-relative asset paths
  and meaningful image alt text; do not put article assets under `koder/`.
- `_layouts/`, `_includes/`, `_config.yml`: Jekyll presentation and configuration.
- `koder/issues/NNN_short_slug/INDEX.md`: focused editorial or maintenance work.
- `koder/STATE.md`: the current handoff, not a duplicate content catalogue.

Operator files are excluded by `_config.yml`. This prevents site publication,
not access through Git: drafts and `koder/` must still be safe to commit.

## Start and resume

Use `open` (Pi: `/skill:open`) for the handoff, current Git facts, draft/post
counts, and outstanding issues. Opening is read-only; it does not start a server
or resume the old migration plan. Useful requests:

- "Show my drafts and suggest one to finish."
- "Start a draft about <topic>; keep it unpublished."
- "Help me finish `_drafts/<file>.md` without changing my voice."
- "Review this post before publishing."
- "File a blog issue for <follow-up>; don't implement it yet."

For a quick local inventory:

```bash
find _drafts -maxdepth 1 -type f -name '*.md' | sort -r
rg '^(status|priority):' koder/issues --glob INDEX.md
```

Do not create an issue per draft by default. The Markdown file is the writing
source; file an issue only when a specific follow-up needs tracking.

## Draft

Read the selected draft and relevant nearby posts before editing. Preserve the
author's voice and distinguish opinion from checkable claims. Do not invent
personal anecdotes, quotes, citations, or results; ask when those are missing.

For an ordinary new post, start with this frontmatter in `_drafts/`:

```yaml
---
layout: post
title: "Working title"
excerpt: "A short summary for the feed."
description: "A short description for page metadata."
# social_preview: /assets/short-slug-preview.webp
---
```

Then write the article body. Use `layout: audio` or `layout: summary` only when
intentionally using those existing formats; preserve their custom metadata.
Do not rename or bulk-normalize existing drafts as routine cleanup.

## Preview and validate

From the repository root, use a Ruby version satisfying `Gemfile` (`~> 3.2`)
and the locked gems. Check with `ruby --version`, `bundle --version`, and
`bundle check`; install missing project dependencies only as needed.

```bash
# Local draft preview; stop with Ctrl-C.
bundle exec jekyll serve --drafts --host 127.0.0.1

# One-shot draft render, without running a server.
bundle exec jekyll build --drafts --strict_front_matter

# Publication-style build: never add --drafts, --unpublished, or --future.
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter

git diff --check
```

Open <http://127.0.0.1:4000> for the server preview. A draft with
`published: false` may also need `--unpublished` for **local-only** review;
never use that flag in production. Missing frontmatter can leave a draft without
the normal post layout even when Jekyll builds successfully.

Builds write `_site/`; never edit or commit generated output. For isolated
validation, add `--destination /tmp/<unique-preview-directory>` and
`--disable-disk-cache`. Do not upload a draft-preview build as a release.

After configuration/operator changes, verify the production output contains no
`koder/`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `.pi/`, `.agents/`,
or `.claude/`. Inspect the homepage, the affected post, and `feed.xml` too.

## Review and publish — owner approval required

1. Check title, layout, summary, links, images/alt text, attribution, factual
   claims, and command examples. Review rendering on narrow and wide screens.
2. Preserve dates, slugs, categories, and any permalink on existing posts; these
   can change public URLs. Confirm an intentional URL change before editing.
3. Ask the owner to approve the article, publication date, and slug. Only then
   move the selected draft to `_posts/YYYY-MM-DD-short-slug.md`; reconcile any
   explicit `date` and `published` fields with that approved publication state.
4. Run the production build without draft flags. Confirm the post appears where
   expected, other drafts remain absent, and operator files are not emitted.
5. Review the diff and commit only intended files. A local commit is not a
   deployment. **Ask separately before pushing or triggering deployment.**
6. After explicit deployment approval, push the intended commit to the existing
   `origin` remote's `master` branch. The current production route is its
   Git-to-Vercel connection. Check the Vercel status for that exact commit, then
   verify the article, homepage entry, and `feed.xml` on <https://jikkujose.in>.
   Confirm the intended content, not just an HTTP success code. Do not push
   simply to save progress.

Hosting preflight on 2026-09-28 found a successful Vercel production status for
`master`, Vercel response headers behind the custom domain's Cloudflare edge,
and the checked-in Pages workflow in `disabled_manually` state. Re-check these
facts before future publication; a repository homepage URL may be stale.
Useful read-only checks are `gh api repos/{owner}/{repo}/commits/<sha>/status`
and `gh api repos/{owner}/{repo}/actions/workflows/jekyll.yml`.

The Pages Ruby mismatch remains tracked in
[issue 001](../issues/001_pages_ruby_version/INDEX.md), but it is not a blocker
for the active Vercel route. Do not enable Pages, switch providers, or change
cloud configuration as an incidental publishing fix.

Never promote a draft, change its publication flag, or deploy as a side effect of
`open`, `close`, or backlog cleanup. Keep draft preview services bound to loopback.

## Track follow-ups and close

Create small, folder-first issues with `status`, `priority`, `created`, `updated`,
`tags`, `type`, `issue_kind: slice`, and `context` frontmatter, then a problem,
source paths, acceptance criteria, and non-goals. Increment the highest existing
issue number. Use `open`, `backlog`, `blocked`, `resolved`, or `superseded`; do not
mark resolved without evidence. Normal writing does not require a plan or queue.

Use `close` (Pi: `/skill:close`) to review and commit intentional work, run the
scratch retention gate, and record the active draft/issue, review decisions,
validation, and next action in `koder/STATE.md`. The gate needs Bash and Python 3.
Do not copy article bodies into the handoff. `close` never implies permission to
push or publish.

The legacy [Hugo migration note](../plan-hugo-migration.md) is retained for
reference, not an active task. Its old counts and deployment assumptions are not
current facts; start a migration only with a new explicit owner decision.
