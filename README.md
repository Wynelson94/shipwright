# Shipwright

**Describe your app. Get it deployed.**

Shipwright is a Claude Code plugin that builds complete web applications from plain English descriptions. No coding experience required — just describe what you want and Shipwright handles the rest.

## Quick Start

```bash
# Install the plugin
claude plugin install shipwright

# Build an app
/shipwright:build "a todo app with user accounts and dark mode"
```

That's it. Shipwright will:
1. Understand your idea
2. Design the app architecture
3. Write all the code
4. Run tests
5. Deploy it live to Vercel
6. Give you the URL

## What Can It Build?

| You Describe | Shipwright Builds |
|-------------|------------------|
| "A project management tool" | Full web app with accounts, dashboards, data |
| "A marketplace for freelancers" | Complex app with buyers, sellers, payments |
| "A company blog" | Fast content site with great SEO |
| "A simple dashboard" | Lightweight interactive web app |

## Commands

| Command | What It Does |
|---------|-------------|
| `/shipwright:build [idea]` | Build and deploy a new app |
| `/shipwright:enhance [feature]` | Add features to an existing app |
| `/shipwright:stacks` | See what kinds of apps Shipwright can build |
| `/shipwright:projects` | List all apps you've built with Shipwright |

## Setup

### Requirements

- [Claude Code](https://claude.ai/code) with an active Pro or Max subscription
- [Node.js](https://nodejs.org) v20+ (v24 LTS recommended)
- [Git](https://git-scm.com)
- [Python 3.10+](https://python.org) (required for safety hooks and build engine)
- [Vercel CLI](https://vercel.com/cli) (`npm i -g vercel`) + free Vercel account
- [Supabase](https://supabase.com) account (free, only needed for apps with a database)
- **Platform**: macOS or Linux (Windows is not currently supported)

> **No API key needed.** Shipwright runs entirely through your Claude Code subscription. You do not need an Anthropic API key or any paid API credentials.

### Build Engine (Product Agent)

Shipwright uses Product Agent as its build engine. To install it automatically:

```bash
bash setup.sh
```

Or install manually:

```bash
pip install product-agent
```

Minimum required version: **v12.0**

Shipwright checks for all requirements before building and walks you through installing anything that's missing.

### Permissions

For the smoothest experience, allow these permissions in Claude Code settings:
- `npm`, `npx`, `vercel` commands
- Writing files to `~/Projects/`

See [CLAUDE.md](CLAUDE.md) for the full list of recommended permissions.

## How It Works

Shipwright runs a 9-phase autonomous pipeline:

```
Understand → Design → Review → Build → Test → Audit → Deploy → Verify → Done!
```

Each phase runs independently with its own error recovery. If something goes wrong, Shipwright fixes it automatically (up to 5 attempts with backoff) and learns from mistakes.

## Technology Stacks

Shipwright auto-selects the best technology for your app:

| Stack | Best For | Key Features |
|-------|----------|-------------|
| **Next.js + Supabase** | SaaS, dashboards, user-facing apps | User accounts, database, realtime, file uploads |
| **Next.js + Prisma** | Marketplaces, multi-tenant apps | Complex data relationships, advanced queries |
| **SvelteKit** | Lightweight interactive apps | Blazing fast, minimal overhead |
| **Astro** | Blogs, portfolios, docs sites | Fastest page loads, great SEO |

All stacks deploy to Vercel with zero configuration.

## Safety & Security

Shipwright includes enterprise-grade safety features:

- **Input sanitization** — Detects and strips 11 prompt injection patterns, zero-width unicode, HTML entities, and encoded attacks
- **Command blocking** — Blocks destructive commands (`rm -rf /`, fork bombs, piped downloads, `sudo`, device writes) with shell-aware splitting
- **Path protection** — Prevents writes to system directories (`/etc`, `/usr`, `/System`) and credential files (`.ssh`, `.aws`, `.pem`, `.key`, `.p12`)
- **Audit logging** — Records all build activity with restrictive file permissions
- **Build memory** — Learns from past builds with automatic log rotation (max 500 records)

All safety hooks run as bash scripts with python3 for comprehensive pattern matching, and fail-closed when python3 is unavailable.

### Running the Hook Tests

```bash
bash tests/test_hooks.sh
```

41 tests covering bypass attempts, destructive commands, protected paths, and injection patterns.

## Limitations

All Shipwright apps run on Vercel's serverless platform. This is great for most web apps, but there are some things to be aware of:

- **No persistent WebSocket connections** — use Supabase Realtime or polling instead
- **No background jobs over 5 minutes** — use Vercel Cron Jobs for scheduled tasks
- **No server-side file storage** — use Supabase Storage or Vercel Blob for uploads
- **250MB deployment size limit** — sufficient for most apps
- **No GPU/ML inference** — use external APIs (Replicate, Modal) for AI models

If your idea needs any of these capabilities, Shipwright will work around the limitations or let you know upfront.

Alternative deploy targets (Railway, Fly.io, etc.) are on the roadmap for future versions.

## Built by Product Agent

Shipwright is powered by Product Agent v12.4 — an autonomous build pipeline with 1,544+ unit tests, 8 technology stacks, and battle-tested error recovery.

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.3.0** | Enterprise security audit: hook bypass fix, review validation hardening, encoded attack detection, retry backoff, JSONL rotation, 41-test hook harness |
| **v2.2.0** | Safety hardening, version pinning, project registry, docs overhaul |
| **v2.1.0** | Background execution + polling, public release prep |
| **v2.0.0** | Rewrite to use Product Agent CLI |
| **v1.0.0** | Initial plugin with autonomous 9-phase pipeline |

## License

MIT
