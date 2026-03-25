#!/bin/bash
# Shipwright Audit Log Hook — logs build activity after each response
# Fires on Stop event (when Claude finishes responding)
# Appends build records to ${CLAUDE_PLUGIN_DATA}/builds.jsonl

set -e

INPUT=$(cat)

# Determine data directory — use CLAUDE_PLUGIN_DATA if available, fallback to ~/.shipwright
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.shipwright}"
mkdir -p "$DATA_DIR"

LOG_FILE="$DATA_DIR/builds.jsonl"

# Extract info and log if this looks like a build-related response
python3 -c "
import sys, json, os
from datetime import datetime, timezone

data = json.load(sys.stdin)

# Get the transcript/response content to check if this was a build
# The Stop hook receives the full turn context
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

log_file = os.environ.get('CLAUDE_PLUGIN_DATA', os.path.expanduser('~/.shipwright'))
log_file = os.path.join(log_file, 'builds.jsonl')

with open(log_file, 'a') as f:
    f.write(json.dumps(record) + '\n')
" <<< "$INPUT" 2>/dev/null || true

exit 0
