---
name: stacks
description: Explain the available technology stacks in plain English. Use when the user asks what kinds of apps Shipwright can build, or wants to understand the technology choices.
user-invocable: true
allowed-tools: "Read"
model: haiku
effort: low
---

# Shipwright: Stacks

The user wants to understand what Shipwright can build. Explain it in **plain English** — no jargon.

---

## Your Response

First, read `stacks/stacks-reference.md` from the Shipwright plugin root directory. It contains the canonical stack definitions.

Then present the stacks to the user using each stack's **Plain name** and **User description** fields. Format your response conversationally like this:

> "Shipwright can build [N] types of apps right now, and I pick the best one for your idea automatically. You never need to worry about the technology — but here's what's available if you're curious:
>
> **1. [Plain name]** ([Stack name])
> [User description]
> - [Capabilities list]
>
> [repeat for each stack...]
>
> All of these deploy to Vercel for free — you get a live URL you can share with anyone.
>
> **A note on what these apps can do:**
> All Shipwright apps run on Vercel's serverless platform, which is great for most web apps. There are a few things serverless can't do out of the box:
> - No persistent WebSocket connections (but you can use Supabase Realtime or polling instead)
> - No long-running background jobs over 5 minutes (but Vercel Cron Jobs handle scheduled tasks)
> - No saving files directly on the server (but Supabase Storage or Vercel Blob work great)
>
> If your idea needs any of these, I'll work around the limitations or let you know upfront.
>
> **Just describe what you want to build and I'll pick the right one.** Use `/shipwright:build [your idea]` to get started!"

## If They Ask for Something We Don't Support Yet

If the user asks about mobile apps, iOS apps, Python backends, or Ruby apps:

> "That's not available in Shipwright yet, but it's on the roadmap! Right now I can build web apps and content sites. If your idea could work as a web app, I'd love to build it for you."
