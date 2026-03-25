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

## How It Works

Shipwright runs a 9-phase autonomous pipeline:

```
Understand → Design → Review → Build → Test → Audit → Deploy → Verify → Done!
```

Each phase runs independently with its own error recovery. If something goes wrong, Shipwright fixes it automatically (up to 5 attempts) and learns from mistakes.

## Requirements

- [Claude Code](https://claude.ai/code) with an active subscription
- [Node.js](https://nodejs.org) (v18+)
- [Git](https://git-scm.com)
- [Vercel CLI](https://vercel.com/cli) (`npm i -g vercel`) + free Vercel account
- [Supabase](https://supabase.com) account (free, only for apps that need a database)

Shipwright checks for all of these before building and walks you through installing anything that's missing.

## Built by Product Agent

Shipwright is powered by [Product Agent](https://github.com/Wynelson94/product-agent) v12.0 — an autonomous build pipeline with 1,627+ tests, 8 technology stacks, and battle-tested error recovery.

## License

MIT
