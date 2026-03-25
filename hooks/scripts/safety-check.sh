#!/bin/bash
# Shipwright Safety Hook — blocks dangerous operations
# Reads JSON from stdin, checks for dangerous patterns, exits with code 2 to block

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Only check Bash and Write/Edit tools
if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

    # Block destructive patterns
    BLOCKED_PATTERNS=(
        'rm -rf /'
        'rm -rf ~'
        'rm -rf \$HOME'
        'sudo rm'
        'sudo chmod'
        'sudo chown'
        'mkfs'
        'dd if=/dev/zero'
        'dd if=/dev/random'
        'chmod -R 777 /'
        'curl.*| *bash'
        'curl.*| *sh'
        'wget.*| *bash'
        'wget.*| *sh'
        'eval \$('
        'base64 -d |'
    )

    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if echo "$COMMAND" | grep -qiE "$pattern"; then
            echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED by Shipwright: Dangerous command detected"}}'
            exit 2
        fi
    done
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
