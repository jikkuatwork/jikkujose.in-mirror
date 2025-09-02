# Jekyll to Hugo Migration Plan

## Executive Summary

This document outlines the complete migration strategy for transforming the
existing Jekyll blog to Hugo static site generator. The migration leverages
containerized Hugo execution via Podman, automated code generation through
Claude Code CLI, and Git-based deployment to Vercel.

**Estimated Timeline:** 2-3 hours  
**Complexity Level:** Low  
**Risk Level:** Minimal

## Prerequisites

### Environment Setup

- [ ] Podman installed and configured
- [ ] Claude Code CLI authenticated and ready
- [ ] Git repository access
- [ ] GitHub repository linked to Vercel

### Current State Analysis

- **Content:** 22 blog posts in standard Jekyll format
- **Layouts:** 4 template files (index, post, audio, summary)
- **Includes:** 1 partial template (head.html)
- **Plugins:** Single plugin (jekyll-feed)
- **Theme:** Standard Minima theme
- **Assets:** Static files in /assets directory

## Migration Architecture

### Phase 1: Foundation Setup

**Objective:** Establish Hugo environment and import existing content

#### Feature 1.1: Hugo Environment Provisioning

**Given** a Jekyll site needs migration to Hugo  
**When** setting up the Hugo environment  
**Then** Hugo should be available via Podman container

**Implementation Tasks:**

- [ ] Create Podman alias for Hugo command execution
- [ ] Test Hugo version and functionality
- [ ] Verify container volume mounting for site directory

**Research Notes:**

```bash
# Podman Hugo container setup
podman run --rm -v $(pwd):/src -w /src klakegg/hugo:latest version
alias hugo="podman run --rm -v $(pwd):/src -w /src klakegg/hugo:latest"
```

#### Feature 1.2: Content Import and Structure Migration

**Given** Jekyll content exists in standard format  
**When** importing to Hugo structure  
**Then** all posts and pages should transfer with metadata intact

**Implementation Tasks:**

- [ ] Execute Hugo Jekyll import command
- [ ] Verify post frontmatter preservation
- [ ] Validate content directory structure
- [ ] Check asset reference integrity

**Research Notes:**

- Hugo import creates content/ directory with posts
- Frontmatter should transfer directly (YAML compatible)
- Static assets need manual relocation to static/ directory

### Phase 2: Template System Migration

**Objective:** Convert Liquid templates to Go template syntax

#### Feature 2.1: Layout Template Conversion

**Given** Jekyll Liquid templates exist  
**When** converting to Hugo Go templates  
**Then** all page rendering should function identically

**Template Mapping:**

```
Jekyll → Hugo
_layouts/index.html → layouts/index.html
_layouts/post.html → layouts/_default/single.html
_layouts/audio.html → layouts/audio/single.html
_layouts/summary.html → layouts/summary/single.html
```

**Implementation Tasks:**

- [ ] Convert variable syntax: `{{ page.title }}` → `{{ .Title }}`
- [ ] Transform loops: `{% for post in posts %}` → `{{ range .Pages }}`
- [ ] Update conditionals: `{% if condition %}` → `{{ if condition }}`
- [ ] Replace includes: `{% include head.html %}` → `{{ partial "head.html" . }}`

**Liquid to Go Template Reference:**

| Jekyll Liquid | Hugo Go Template | Notes                |
| ------------- | ---------------- | -------------------- |
| `page.title`  | `.Title`         | Page-level variables |
| `site.title`  | `.Site.Title`    | Site configuration   |
| `content`     | `.Content`       | Rendered content     |
| `page.date`   | `.Date`          | Post date            |
| `page.url`    | `.Permalink`     | Page URL             |

#### Feature 2.2: Partial Template Migration

**Given** Jekyll includes exist  
**When** converting to Hugo partials  
**Then** template composition should work seamlessly

**Implementation Tasks:**

- [ ] Move \_includes/head.html to layouts/partials/head.html
- [ ] Update partial calls in layout templates
- [ ] Test partial parameter passing if needed
- [ ] Verify CSS and JavaScript inclusion

### Phase 3: Asset Pipeline Configuration

**Objective:** Establish proper asset handling and optimization

#### Feature 3.1: Static Asset Migration

**Given** Jekyll assets directory contains static files  
**When** migrating to Hugo asset structure  
**Then** all assets should be accessible at same URLs

**Implementation Tasks:**

- [ ] Move assets/_ to static/_
- [ ] Update asset references in templates
- [ ] Verify CSS, JavaScript, and image loading
- [ ] Test asset fingerprinting if required

#### Feature 3.2: RSS Feed Configuration

**Given** Jekyll-feed plugin provides RSS functionality  
**When** configuring Hugo RSS generation  
**Then** RSS feed should be available at /feed.xml

**Implementation Tasks:**

- [ ] Configure RSS output in hugo.yaml
- [ ] Create custom RSS template if needed
- [ ] Test RSS feed generation and format
- [ ] Verify feed URL compatibility

**Configuration:**

```yaml
outputs:
  home: ["HTML", "RSS"]

rssLimit: 10
```

### Phase 4: Configuration and Optimization

**Objective:** Configure Hugo for production deployment

#### Feature 4.1: Site Configuration Migration

**Given** Jekyll \_config.yml contains site settings  
**When** converting to hugo.yaml configuration  
**Then** all site behavior should remain consistent

**Configuration Mapping:**

```yaml
# Jekyll _config.yml → Hugo hugo.yaml
title: → title:
description: → params.description:
url: → baseURL:
email: → params.email:
```

**Implementation Tasks:**

- [ ] Create hugo.yaml with migrated settings
- [ ] Configure permalink structure to match Jekyll
- [ ] Set up taxonomy configuration if needed
- [ ] Configure markup renderer options

#### Feature 4.2: SEO and Meta Tag Preservation

**Given** existing SEO optimization exists  
**When** migrating to Hugo templates  
**Then** all meta tags and SEO features should transfer

**Implementation Tasks:**

- [ ] Ensure Open Graph tags in head partial
- [ ] Configure Twitter Card meta tags
- [ ] Set up canonical URL generation
- [ ] Verify sitemap.xml generation

### Phase 5: Testing and Validation

**Objective:** Ensure complete functional parity with Jekyll site

#### Feature 5.1: Local Development Testing

**Given** Hugo site is configured  
**When** running local development server  
**Then** all pages should render correctly

**Testing Checklist:**

- [ ] Homepage renders with post list
- [ ] Individual post pages display correctly
- [ ] Audio post layout functions properly
- [ ] Summary post layout works as expected
- [ ] Navigation and internal links work
- [ ] CSS styling applies correctly
- [ ] JavaScript functionality intact
- [ ] RSS feed generates properly

#### Feature 5.2: Content Validation

**Given** all content has been migrated  
**When** comparing Jekyll and Hugo output  
**Then** content should be identical

**Validation Tasks:**

- [ ] Compare post count (22 posts expected)
- [ ] Verify post dates and titles
- [ ] Check frontmatter field preservation
- [ ] Validate markdown rendering
- [ ] Test internal link resolution

### Phase 6: Deployment Configuration

**Objective:** Configure automated deployment to Vercel

#### Feature 6.1: Git Repository Preparation

**Given** Hugo site is ready for deployment  
**When** committing to GitHub repository  
**Then** repository should be deployment-ready

**Implementation Tasks:**

- [ ] Create .gitignore with Hugo-specific patterns
- [ ] Commit all Hugo site files
- [ ] Push to GitHub main branch
- [ ] Verify repository structure

**.gitignore Configuration:**

```
public/
resources/
.hugo_build.lock
node_modules/
```

#### Feature 6.2: Vercel Integration Setup

**Given** GitHub repository contains Hugo site  
**When** linking to Vercel deployment  
**Then** site should build and deploy automatically

**Implementation Tasks:**

- [ ] Link GitHub repository to Vercel project
- [ ] Configure build command: `hugo --minify`
- [ ] Set output directory: `public`
- [ ] Configure Hugo version environment variable
- [ ] Test automated deployment

**Vercel Configuration:**

```json
{
  "buildCommand": "hugo --minify",
  "outputDirectory": "public",
  "installCommand": "echo 'No install needed'",
  "framework": "hugo"
}
```

## Risk Mitigation Strategies

### Content Loss Prevention

- [ ] Create full backup of Jekyll site before migration
- [ ] Version control all changes during migration
- [ ] Maintain parallel Jekyll site until Hugo verification complete

### URL Preservation

- [ ] Configure Hugo permalinks to match Jekyll structure
- [ ] Test all existing URLs for proper redirects
- [ ] Set up 301 redirects if URL structure changes

### SEO Impact Minimization

- [ ] Preserve all meta tags and structured data
- [ ] Maintain sitemap.xml URL and format
- [ ] Keep RSS feed URL consistent (/feed.xml)

## Success Criteria

### Functional Requirements

- [ ] All 22 blog posts accessible and properly formatted
- [ ] Homepage displays recent posts correctly
- [ ] RSS feed generates and validates
- [ ] All internal links function properly
- [ ] Site loads under 2 seconds on mobile

### Technical Requirements

- [ ] Hugo builds without errors or warnings
- [ ] Vercel deployment succeeds automatically
- [ ] Git workflow functions smoothly
- [ ] Podman Hugo execution works reliably

### Quality Assurance

- [ ] Visual appearance matches original Jekyll site
- [ ] No broken links or missing images
- [ ] Mobile responsiveness maintained
- [ ] Search engine optimization preserved

## Rollback Plan

**If migration fails or issues arise:**

1. **Immediate:** Revert Vercel deployment to Jekyll version
2. **Short-term:** Debug Hugo issues while Jekyll site remains live
3. **Long-term:** Complete Hugo fixes and retry deployment

**Recovery Steps:**

- [ ] Document all issues encountered
- [ ] Analyze root causes
- [ ] Implement fixes systematically
- [ ] Re-test entire migration process

## Post-Migration Maintenance

### Content Management

- [ ] Update content creation workflow for Hugo
- [ ] Document new post creation process
- [ ] Set up content preview workflow
- [ ] Configure automated builds on content changes

### Performance Monitoring

- [ ] Set up site performance monitoring
- [ ] Monitor build times and deployment success
- [ ] Track visitor analytics continuity
- [ ] Monitor search engine indexing
