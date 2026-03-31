# Shipwright Plugin — Claude Code Instructions

## What This Plugin Does

Shipwright builds complete web applications from plain English descriptions. It delegates heavy building to the `product-agent` CLI and deploys to Vercel. The user may be a complete beginner — always communicate in plain English.

## Commands

- `/shipwright:build [idea]` — Build and deploy a new app
- `/shipwright:enhance [feature]` — Add features to an existing app
- `/shipwright:stacks` — Explain what kinds of apps Shipwright can build
- `/shipwright:projects` — List all apps Shipwright has built

## Recommended Permissions

For Shipwright to work smoothly, users should allow these patterns:

- `Bash(npx create-next-app*)` — scaffolding new projects
- `Bash(npm create astro*)` — scaffolding Astro projects
- `Bash(npx sv create*)` — scaffolding SvelteKit projects
- `Bash(npm install*)` — installing dependencies
- `Bash(vercel*)` — deploying to Vercel
- `Bash(product-agent*)` — running the build engine
- `Bash(python3*)` — safety checks and audit logging
- `Bash(npx prisma*)` — database operations
- `Write(~/Projects/*)` — creating project files
- `Edit(~/Projects/*)` — modifying project files

## Safety Boundaries

These are enforced by hooks but should also be followed as defense-in-depth:

- NEVER modify files outside `~/Projects/` or the current project directory
- NEVER run `sudo` commands
- NEVER hardcode API keys or secrets in source code
- NEVER use SQLite with Vercel deployments (serverless can't persist files)
- NEVER write to system paths (`/etc`, `/usr`, `/bin`, `/var`, `/System`, `/Library`)
- NEVER modify credential files (`.ssh`, `.aws`, `.gnupg`, `.kube`)

## Build Workflow

1. User invokes `/shipwright:build [idea]`
2. Preflight checks environment (Node.js, Git, python3, product-agent, Vercel CLI)
3. Confirms the idea with the user
4. Product-agent runs the 9-phase pipeline (Analyze, Design, Review, Build, Test, Audit, Deploy, Verify)
5. Result is deployed to Vercel
6. User gets a live URL and a menu of next steps

## Data Files

- `${CLAUDE_PLUGIN_DATA}/projects.jsonl` — project registry (all built apps)
- `${CLAUDE_PLUGIN_DATA}/builds.jsonl` — audit log (build activity records)
- `${CLAUDE_PLUGIN_DATA}/lessons.jsonl` — build memory (lessons from past builds)

## Stacks

Shipwright auto-selects the best stack based on the user's description:

| Stack | Use Case |
|-------|----------|
| Next.js + Supabase | SaaS, dashboards, apps with user accounts |
| Next.js + Prisma | Marketplaces, multi-tenant, complex data |
| SvelteKit | Lightweight interactive apps |
| Astro | Blogs, portfolios, docs, landing pages |

All stacks deploy to Vercel. See `agents/builder.md` for detailed stack configurations.
