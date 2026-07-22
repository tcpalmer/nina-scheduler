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

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any Bash command containing `curl` or `wget` is intercepted and replaced with an error message. Do NOT retry.
Instead use:
- `ctx_fetch_and_index(url, source)` to fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any Bash command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` is intercepted and replaced with an error message. Do NOT retry with Bash.
Instead use:
- `ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch — BLOCKED
WebFetch calls are denied entirely. The URL is extracted and you are told to use `ctx_fetch_and_index` instead.
Instead use:
- `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Bash (>20 lines output)
Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### Read (for analysis)
If you are reading a file to **Edit** it → Read is correct (Edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `ctx_execute_file(path, language, code)` instead. Only your printed summary enters context. The raw file content stays in the sandbox.

### Grep (large results)
Grep results can flood context. Use `ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is automatically injected into their prompt. Bash-type subagents are upgraded to general-purpose so they have access to MCP tools. You do NOT need to manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `ctx_search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `ctx_stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
