# Shipwright Stacks Reference (v1 — Vercel Only)

> Single source of truth for all stack definitions.
> Referenced by: skills/stacks/SKILL.md, agents/builder.md, README.md
> When adding or modifying a stack, update THIS file first, then update references.

---

## Stack 1: Next.js + Supabase (DEFAULT)

- **Plain name:** Full Web Apps
- **Use for:** SaaS apps, dashboards, apps with user accounts, data-driven apps
- **User description:** For apps where people create accounts, log in, and work with data. Think: a project management tool, a booking system, a customer portal.
- **Deploy:** Vercel (serverless)
- **Database:** Supabase (managed PostgreSQL with auth, realtime, file storage)
- **Key packages:** next, @supabase/supabase-js, @supabase/ssr, tailwindcss
- **Selection signals:** users, accounts, login, dashboard, data, CRUD
- **CRITICAL:** Never use SQLite — Vercel is serverless, file-based DBs won't persist
- **Capabilities:**
  - User accounts and login
  - Database for storing information
  - Real-time updates
  - File uploads
  - Deploys instantly to the web

## Stack 2: Next.js + Prisma

- **Plain name:** Complex Web Apps
- **Use for:** Marketplaces, multi-tenant apps, complex data relationships
- **User description:** For apps with complicated data relationships. Think: a marketplace with buyers and sellers, a multi-company platform, an app with lots of interconnected data.
- **Deploy:** Vercel (serverless)
- **Database:** PostgreSQL via Supabase or Neon (use Prisma ORM)
- **Key packages:** next, prisma, @prisma/client, tailwindcss
- **Selection signals:** marketplace, tenants, complex relationships, roles
- **CRITICAL:** Always use PostgreSQL provider, never SQLite on Vercel
- **Capabilities:**
  - Everything in Stack 1, plus:
  - Complex data relationships
  - Multi-tenant (separate spaces for different companies)
  - Advanced database features

## Stack 3: SvelteKit

- **Plain name:** Lightweight Web Apps
- **Use for:** Fast interactive apps, simple dashboards, lightweight web apps
- **User description:** For simpler, blazing-fast interactive apps. Think: a dashboard, a calculator tool, a simple app that doesn't need a heavy framework.
- **Deploy:** Vercel (with @sveltejs/adapter-vercel)
- **Database:** Optional (Supabase if needed)
- **Key packages:** @sveltejs/kit, @sveltejs/adapter-vercel, tailwindcss
- **Selection signals:** interactive, fast, lightweight, simple app
- **Capabilities:**
  - Super fast loading
  - Clean, simple code
  - Optional database
  - Great for smaller projects

## Stack 4: Astro

- **Plain name:** Content Sites
- **Use for:** Blogs, portfolios, docs, landing pages, marketing sites
- **User description:** For websites focused on content rather than interactivity. Think: a blog, a portfolio, documentation, a marketing site, a landing page.
- **Deploy:** Vercel (with @astrojs/vercel)
- **Database:** None (static content), or Supabase if dynamic features needed
- **Key packages:** astro, @astrojs/vercel, @astrojs/tailwind
- **Selection signals:** blog, portfolio, docs, landing page, marketing
- **Capabilities:**
  - Fastest possible page loads
  - Great for SEO (Google rankings)
  - Markdown support (write content like a document)
  - Minimal code, maximum speed

---

## Stack Selection Logic

1. If they mention **users, accounts, login, dashboard, data, CRUD** → Next.js + Supabase
2. If they mention **marketplace, tenants, complex relationships, roles** → Next.js + Prisma
3. If they mention **blog, portfolio, docs, landing page, marketing** → Astro
4. If they mention **interactive, fast, lightweight, simple app** → SvelteKit
5. If unclear → Next.js + Supabase (safest default)

---

All stacks deploy to Vercel for free — the user gets a live URL they can share with anyone.
