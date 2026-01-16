#!/bin/bash
# TDD Guard Wrapper - Fixes exit code bug in tdd-guard
# Calls the real tdd-guard (using API client) and converts the result to proper exit codes
# Exit code 2 = block the tool call

# Use API client for validation (works in web environment)
export VALIDATION_CLIENT=api

# Pass stdin to tdd-guard and capture output
result=$(cat | npx tdd-guard 2>&1)

# Check if result contains a block decision
if echo "$result" | grep -q '"decision"[[:space:]]*:[[:space:]]*"block"'; then
    # Extract the reason
    reason=$(echo "$result" | grep -o '"reason"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    if [ -n "$reason" ]; then
        echo "TDD Guard: $reason" >&2
    else
        echo "TDD Guard: Blocked - TDD violation detected" >&2
    fi
    exit 2
fi

# Allow the operation
exit 0
