#!/bin/bash
# Shipwright Audit Log Hook — logs build activity after each response
# Fires on Stop event (when Claude finishes responding)
# Appends build records to ${CLAUDE_PLUGIN_DATA}/builds.jsonl
# If python3 is unavailable, falls back to basic bash logging

set -e

# Check python3 availability once
if command -v python3 &>/dev/null; then
    PYTHON3_AVAILABLE=true
else
    PYTHON3_AVAILABLE=false
fi

INPUT=$(cat)

# Determine data directory — use CLAUDE_PLUGIN_DATA if available, fallback to ~/.shipwright
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.shipwright}"
mkdir -p "$DATA_DIR"

LOG_FILE="$DATA_DIR/builds.jsonl"

# Set restrictive permissions on the log file — it contains deployment URLs
# and project paths that shouldn't be world-readable in shared environments.
if [ -f "$LOG_FILE" ]; then
    chmod 600 "$LOG_FILE" 2>/dev/null || true
fi

if [ "$PYTHON3_AVAILABLE" = true ]; then
    # Full python3 logging — rich data extraction
    python3 -c "
import sys, json, os
from datetime import datetime, timezone

data = json.load(sys.stdin)

# Get the transcript/response content to check if this was a build
transcript = json.dumps(data).lower()

# Only log if this appears to be a Shipwright build
build_signals = ['shipwright', '/shipwright:build', 'deploying to vercel', 'your app is live', 'building now']
is_build = any(signal in transcript for signal in build_signals)

if not is_build:
    sys.exit(0)

# Extract what we can from the response
record = {
    'timestamp': datetime.now(timezone.utc).isoformat(),
    'session_id': data.get('session_id', 'unknown'),
    'event': 'build_activity',
}

# Try to detect outcome signals
if 'your app is live' in transcript or 'deployed' in transcript:
    record['outcome'] = 'deployed'
elif 'error' in transcript or 'failed' in transcript:
    record['outcome'] = 'error'
else:
    record['outcome'] = 'in_progress'

# Try to extract richer data from transcript
# Project name: look for ~/Projects/<name> patterns
import re
project_match = re.search(r'~/Projects/([a-zA-Z0-9_-]+)', json.dumps(data))
if project_match:
    record['project_name'] = project_match.group(1)

# Stack: look for stack identifiers
stack_signals = {
    'nextjs-supabase': ['supabase', 'next.js + supabase', 'nextjs.*supabase'],
    'nextjs-prisma': ['prisma', 'next.js + prisma', 'nextjs.*prisma'],
    'sveltekit': ['sveltekit', 'svelte'],
    'astro': ['astro'],
}
for stack_id, signals in stack_signals.items():
    if any(re.search(s, transcript) for s in signals):
        record['stack'] = stack_id
        break

# Deployment URL: look for .vercel.app URLs
url_match = re.search(r'https?://[a-zA-Z0-9_-]+\.vercel\.app\b', json.dumps(data))
if url_match:
    record['deployment_url'] = url_match.group(0)

log_file = os.path.join('${DATA_DIR}', 'builds.jsonl')

with open(log_file, 'a') as f:
    f.write(json.dumps(record) + '\n')
" <<< "$INPUT" 2>/dev/null || true

else
    # Bash-only fallback — write a minimal log entry if this looks like a build
    TRANSCRIPT_LOWER=$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')

    IS_BUILD=false
    for signal in "shipwright" "/shipwright:build" "deploying to vercel" "your app is live" "building now"; do
        if echo "$TRANSCRIPT_LOWER" | grep -q "$signal"; then
            IS_BUILD=true
            break
        fi
    done

    if [ "$IS_BUILD" = true ]; then
        # Detect outcome
        OUTCOME="in_progress"
        if echo "$TRANSCRIPT_LOWER" | grep -qE 'your app is live|deployed'; then
            OUTCOME="deployed"
        elif echo "$TRANSCRIPT_LOWER" | grep -qE 'error|failed'; then
            OUTCOME="error"
        fi

        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

        echo "{\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"event\":\"build_activity\",\"outcome\":\"$OUTCOME\",\"note\":\"logged without python3\"}" >> "$LOG_FILE"
    fi
fi

exit 0
