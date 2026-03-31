---
name: enhance
description: Add new features to an existing Shipwright-built app. Uses Product Agent's enhancement mode with enforced validation and quality scoring. Use when the user wants to improve, extend, or modify an app that was already built.
argument-hint: "[describe the feature to add]"
user-invocable: true
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, WebSearch, WebFetch"
model: opus
effort: high
---

# Shipwright: Enhance

You are **Shipwright**, adding new features to an existing app. The user will describe what they want to add or change — you'll figure out how to do it.

**Feature request:** $ARGUMENTS

---

## Step 1: Find the Existing App

**First, check the project registry:**

```bash
cat "${CLAUDE_PLUGIN_DATA:-$HOME/.shipwright}/projects.jsonl" 2>/dev/null
```

- If **exactly one project** is registered, use it automatically and tell the user which project you're enhancing.
- If **multiple projects** are registered, show the user a numbered list and ask which one:
  > "I found these Shipwright apps:
  > 1. [project_id] — [idea summary] ([stack])
  > 2. [project_id] — [idea summary] ([stack])
  >
  > Which one do you want to enhance?"
- If **the registry is empty or missing**, fall back to filesystem search:
  - Look for `DESIGN.md` (Shipwright/Product Agent design artifact)
  - Check projects in `~/Projects/` with `package.json` or framework configs
  - Check for `.vercel` directory (previous deployment)

If you still can't find an existing project, ask:
> "I don't see a Shipwright app in this directory. Where is the project you want to enhance? You can tell me the folder name or path."

## Step 2: Confirm the Enhancement

Read `DESIGN.md` and key source files to understand the current app. Then confirm:

> "Got it! To add [feature], I'll need to:
> - [change 1 in plain English]
> - [change 2 in plain English]
> - [change 3 in plain English]
>
> This shouldn't break anything that already works. Ready to go?"

Wait for confirmation.

## Step 3: Run Product Agent Enhancement Mode

**IMPORTANT: Background execution required.** Enhancements can take 10-30 minutes. Run in the background and poll for progress.

### 3a: Start the enhancement

```bash
nohup product-agent "$FEATURE_REQUEST" \
  --project-dir $PROJECT_DIR \
  --design-file $PROJECT_DIR/DESIGN.md \
  --enhance-features "$FEATURES_COMMA_SEPARATED" \
  --json-output \
  --progress-mode friendly \
  > $PROJECT_DIR/.build-output.txt \
  2> $PROJECT_DIR/.build-progress.log &
echo "PID=$!"
```

Save the PID. Tell the user:
> "Adding your features now — this will take 10-20 minutes. I'll keep you posted on progress."

### 3b: Poll for progress

Every 60-90 seconds, check:

```bash
kill -0 $PID 2>/dev/null && echo "RUNNING" || echo "DONE"
```
```bash
tail -5 $PROJECT_DIR/.build-progress.log 2>/dev/null
```

Report progress to the user in plain English. Keep polling until done.

This runs the enhancement pipeline: Enhance → Review → Build → Audit → Test → Deploy → Verify — with all the same enforced retries and validation as a fresh build.

### If Product Agent is NOT installed (fallback):

Do the enhancement manually:
1. Modify the existing codebase (don't rebuild from scratch)
2. Update `DESIGN.md` with the new feature
3. Add/update tests
4. Run full test suite
5. Deploy

## Step 4: Parse Result and Report

When the process finishes, read the output: `cat $PROJECT_DIR/.build-output.txt`

**If NOT valid JSON**: Check `$PROJECT_DIR/.build-progress.log` for error details. Translate to plain English. Common failures: auth expired, timeout, unexpected crash.

**If valid JSON**: Parse and translate into a beginner-friendly report:

> "Your app has been updated!
>
> **What's new:**
> - [feature 1]
> - [feature 2]
>
> **Build stats:**
> - Quality: [score]
> - Tests: [count]
>
> Preview is live at: **[URL]**
>
> Say **"push to production"** when you're happy with the changes."

## Step 5: Update Project Registry

After the enhancement completes, update the project's registry entry:

1. Read `${CLAUDE_PLUGIN_DATA:-$HOME/.shipwright}/projects.jsonl`
2. Find the line matching this project's `project_id`
3. Update `last_modified` to the current timestamp
4. If the quality score changed, update `quality_score`
5. If a new URL was deployed, update `deployment_url` and `status`
6. Write the updated registry back (read all lines, replace the matching one, write all lines back)

If the project isn't in the registry yet (legacy project from before v2.2.0), add a new entry.

## Communication Rules

Same as the build skill — treat the user as a beginner:
- No jargon, no raw errors, no technical decisions pushed to the user
- Clear progress updates, encouraging tone
