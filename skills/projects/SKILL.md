---
name: projects
description: List all apps built by Shipwright. Shows project names, stacks, URLs, and quality scores. Use when the user wants to see what they've built or pick a project to enhance.
user-invocable: true
allowed-tools: "Read, Bash"
model: sonnet
effort: low
---

# Shipwright: Projects

The user wants to see what apps Shipwright has built. Read the project registry and display it clearly.

---

## Step 1: Read the Registry

Check for the project registry file:

```bash
cat "${CLAUDE_PLUGIN_DATA:-$HOME/.shipwright}/projects.jsonl" 2>/dev/null
```

## Step 2: Display Results

**If the file is empty or doesn't exist:**

> "No apps built yet! Use `/shipwright:build [your idea]` to create your first one."

**If projects exist**, parse each JSON line and display a friendly table:

> "Here are the apps you've built with Shipwright:
>
> | # | App | Type | Status | Quality | URL |
> |---|-----|------|--------|---------|-----|
> | 1 | [project_id] | [stack in plain English] | [status] | [quality_score] | [deployment_url or "not deployed"] |
> | 2 | ... | ... | ... | ... | ... |
>
> **What you can do:**
> - To add features to any of these, use `/shipwright:enhance [describe the feature]`
> - To rebuild or redeploy, just tell me which app and what you need
> - The code for each app is in the folder listed below"

Then list the project directories:
> "**Project locations:**
> - [project_id]: `[project_dir]`
> - ..."

## Stack Name Translation

When displaying stacks, use plain English:
- `nextjs-supabase` → "Full Web App (Next.js + Supabase)"
- `nextjs-prisma` → "Complex Web App (Next.js + Prisma)"
- `sveltekit` → "Lightweight App (SvelteKit)"
- `astro` → "Content Site (Astro)"

## Communication Rules

Same as all Shipwright skills — beginner-friendly, no jargon, encouraging tone.
