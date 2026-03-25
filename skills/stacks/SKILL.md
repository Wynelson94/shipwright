---
name: stacks
description: Explain the available technology stacks in plain English. Use when the user asks what kinds of apps Shipwright can build, or wants to understand the technology choices.
user-invocable: true
allowed-tools: "Read"
model: sonnet
effort: low
---

# Shipwright: Stacks

The user wants to understand what Shipwright can build. Explain it in **plain English** — no jargon.

---

## Your Response

Explain what Shipwright can build using this framework:

> "Shipwright can build 4 types of apps right now, and I pick the best one for your idea automatically. You never need to worry about the technology — but here's what's available if you're curious:
>
> **1. Full Web Apps** (Next.js + Supabase)
> For apps where people create accounts, log in, and work with data. Think: a project management tool, a booking system, a customer portal.
> - User accounts and login
> - Database for storing information
> - Real-time updates
> - File uploads
> - Deploys instantly to the web
>
> **2. Complex Web Apps** (Next.js + Prisma)
> For apps with complicated data relationships. Think: a marketplace with buyers and sellers, a multi-company platform, an app with lots of interconnected data.
> - Everything in #1, plus:
> - Complex data relationships
> - Multi-tenant (separate spaces for different companies)
> - Advanced database features
>
> **3. Lightweight Web Apps** (SvelteKit)
> For simpler, blazing-fast interactive apps. Think: a dashboard, a calculator tool, a simple app that doesn't need a heavy framework.
> - Super fast loading
> - Clean, simple code
> - Optional database
> - Great for smaller projects
>
> **4. Content Sites** (Astro)
> For websites focused on content rather than interactivity. Think: a blog, a portfolio, documentation, a marketing site, a landing page.
> - Fastest possible page loads
> - Great for SEO (Google rankings)
> - Markdown support (write content like a document)
> - Minimal code, maximum speed
>
> All of these deploy to Vercel for free — you get a live URL you can share with anyone.
>
> **Just describe what you want to build and I'll pick the right one.** Use `/shipwright:build [your idea]` to get started!"

## If They Ask for Something We Don't Support Yet

If the user asks about mobile apps, iOS apps, Python backends, or Ruby apps:

> "That's not available in Shipwright yet, but it's on the roadmap! Right now I can build web apps and content sites. If your idea could work as a web app, I'd love to build it for you."
