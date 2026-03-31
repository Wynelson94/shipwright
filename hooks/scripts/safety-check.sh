#!/bin/bash
# Shipwright Safety Hook — blocks dangerous operations
# Reads JSON from stdin, checks for dangerous patterns, exits with code 2 to block
# IMPORTANT: If python3 is unavailable, falls back to bash-only checks (fail-closed for critical patterns)

set -e

# Check python3 availability once
if command -v python3 &>/dev/null; then
    PYTHON3_AVAILABLE=true
else
    PYTHON3_AVAILABLE=false
fi

INPUT=$(cat)

# Extract tool name — try python3 first, then bash fallback
if [ "$PYTHON3_AVAILABLE" = true ]; then
    TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
else
    # Bash-only JSON extraction (fragile but sufficient for simple keys)
    TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\([^"]*\)"/\1/')
fi

# --- Bash tool checks ---
if [ "$TOOL_NAME" = "Bash" ]; then

    # Extract command
    if [ "$PYTHON3_AVAILABLE" = true ]; then
        COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
    else
        # Bash-only command extraction — grab value after "command":
        COMMAND=$(echo "$INPUT" | grep -o '"command"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\([^"]*\)"/\1/')
    fi

    # Allow commands targeting Shipwright plugin data directory (build memory, audit logs)
    if echo "$COMMAND" | grep -q '\.claude/plugins/data/shipwright\|\.shipwright'; then
        exit 0
    fi

    if [ "$PYTHON3_AVAILABLE" = true ]; then
        # Full python3 pattern matching — comprehensive detection
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
" 2>/dev/null || echo "BLOCKED")
        # ^^^ FAIL CLOSED: if python3 crashes, treat as BLOCKED (not OK)
    else
        # Bash-only fallback — catch the most critical patterns without python3
        BLOCKED="OK"
        case "$COMMAND" in
            *"rm -rf /"*|*"rm -rf  /"*|*"rm -rf /*"*)
                BLOCKED="BLOCKED" ;;
            *"rm -rf ~"*|*"rm -rf  ~"*|*'rm -rf $HOME'*)
                BLOCKED="BLOCKED" ;;
            *"sudo rm"*|*"sudo chmod"*|*"sudo chown"*)
                BLOCKED="BLOCKED" ;;
            *"mkfs"*)
                BLOCKED="BLOCKED" ;;
            *"dd if=/dev/zero"*|*"dd if=/dev/random"*)
                BLOCKED="BLOCKED" ;;
            *"curl"*"|"*"bash"*|*"curl"*"|"*" sh"*)
                BLOCKED="BLOCKED" ;;
            *"wget"*"|"*"bash"*|*"wget"*"|"*" sh"*)
                BLOCKED="BLOCKED" ;;
        esac

        # Warn that we're running in degraded mode
        if [ "$BLOCKED" = "OK" ]; then
            echo '{"additionalContext":"[Shipwright Safety] WARNING: python3 not found. Running with limited bash-only safety checks. Install python3 for full protection."}'
        fi
    fi

    if [ "$BLOCKED" = "BLOCKED" ]; then
        echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Dangerous command detected"}}'
        exit 2
    fi
fi

# --- Write/Edit tool checks ---
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then

    # Extract file path
    if [ "$PYTHON3_AVAILABLE" = true ]; then
        FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
    else
        FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/.*:.*"\([^"]*\)"/\1/')
    fi

    # Block writes to protected paths (works with or without python3)
    PROTECTED_PREFIXES=("/etc" "/usr" "/bin" "/sbin" "/var" "/root" "/System" "/Library")
    for prefix in "${PROTECTED_PREFIXES[@]}"; do
        if [[ "$FILE_PATH" == "$prefix"* ]]; then
            echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Cannot modify system files"}}'
            exit 2
        fi
    done

    # Block credential files (works with or without python3)
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
