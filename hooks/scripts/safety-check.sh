#!/bin/bash
# Shipwright Safety Hook — blocks dangerous operations
# Reads JSON from stdin, checks for dangerous patterns, exits with code 2 to block

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Only check Bash and Write/Edit tools
if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

    # Allow commands targeting Shipwright plugin data directory (build memory, audit logs)
    if echo "$COMMAND" | grep -q '\.claude/plugins/data/shipwright\|\.shipwright'; then
        exit 0
    fi

    # Block destructive patterns using python for precise matching (avoids grep regex issues)
    BLOCKED=$(echo "$COMMAND" | python3 -c "
import sys, re
cmd = sys.stdin.read()
patterns = [
    r'rm\s+-rf\s+/(\s|$|;|\*)',
    r'rm\s+-rf\s+~(\s|$|;|\*)',
    r'rm\s+-rf\s+\\\$HOME',
    r'sudo\s+rm\b',
    r'sudo\s+chmod\b',
    r'sudo\s+chown\b',
    r'\bmkfs\b',
    r'dd\s+if=/dev/zero',
    r'dd\s+if=/dev/random',
    r'chmod\s+-R\s+777\s+/',
    r'curl\s+.*\|\s*bash',
    r'curl\s+.*\|\s*sh\b',
    r'wget\s+.*\|\s*bash',
    r'wget\s+.*\|\s*sh\b',
    r'eval\s+\\\$\(',
    r'base64\s+-d\s*\|',
]
for p in patterns:
    if re.search(p, cmd, re.IGNORECASE):
        print('BLOCKED')
        sys.exit(0)
print('OK')
" 2>/dev/null || echo "OK")

    if [ "$BLOCKED" = "BLOCKED" ]; then
        echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Dangerous command detected"}}'
        exit 2
    fi
fi

if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
    FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

    # Block writes to protected paths
    PROTECTED_PREFIXES=("/etc" "/usr" "/bin" "/sbin" "/var" "/root" "/System" "/Library")
    for prefix in "${PROTECTED_PREFIXES[@]}"; do
        if [[ "$FILE_PATH" == "$prefix"* ]]; then
            echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Cannot modify system files"}}'
            exit 2
        fi
    done

    # Block credential files
    PROTECTED_COMPONENTS=(".ssh" ".aws" ".gnupg" ".kube" "id_rsa" "id_ed25519" ".pem")
    for component in "${PROTECTED_COMPONENTS[@]}"; do
        if echo "$FILE_PATH" | grep -q "$component"; then
            echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Cannot modify credential files"}}'
            exit 2
        fi
    done
fi

# Allow the operation
exit 0
