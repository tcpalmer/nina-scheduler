# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Documentation-only repository for the **Target Scheduler** NINA plugin — an astrophotography automation plugin for the [NINA](https://nighttime-imaging.eu/) platform. The actual plugin source code lives in a separate repository (`tcpalmer/nina.plugin.targetscheduler`). This repo publishes to GitHub Pages at https://tcpalmer.github.io/nina-scheduler.

## Local Development

```bash
# Install dependencies (requires Ruby)
bundle install

# Serve site locally with live reload
bundle exec jekyll serve

# Build site (output to ./_site/)
bundle exec jekyll build
```

The site is served at `http://localhost:4000` by default.

## Deployment

Pushing to `main` triggers the GitHub Actions workflow (`.github/workflows/jekyll.yml`) which builds and deploys to GitHub Pages automatically. No manual deployment is needed.

## Tech Stack

- **Jekyll 4.3** — static site generator
- **just-the-docs 0.4.1** — Jekyll theme (pinned; upgrade carefully)
- Ruby Gemfile manages all dependencies

## Content Architecture

Documentation is organized into these main sections (each a subdirectory with `index.md`):

| Directory | Content |
|-----------|---------|
| `concepts/` | Core concepts including the planning engine algorithm |
| `target-management/` | Projects, Targets, Exposure Plans, Templates, Profiles |
| `sequencer/` | NINA Advanced Sequencer integration |
| `post-acquisition/` | Image grading, flats, reporting |
| `adv-topics/` | Advanced features |
| `ts-5-notes/` | Version 5 migration guides |

Top-level pages: `index.md`, `getting-started.md`, `release.md`, `flats.md`, `synchronization.md`, `faqs.md`, `roadmap.md`.

## Jekyll Page Metadata

Every page uses front matter for navigation ordering in the just-the-docs theme:

```yaml
---
layout: default
title: Page Title
nav_order: N
parent: Parent Page Title   # omit for top-level pages
---
```

## Callout Syntax

Two custom callout types are configured in `_config.yml`:

```markdown
{: .warning }
Warning text here.

{: .note }
Note text here.
```

## Release Versioning

Versions follow the pattern `TS X.Y.Z.W` (e.g., `TS 5.9.0.0`). Release notes are maintained in `release.md`. Commits are tagged with the version string as the commit message.
