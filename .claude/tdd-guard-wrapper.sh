#!/bin/bash
# TDD Guard Wrapper - Works in both local and web environments
#
# Local: Passes through to npx tdd-guard directly (uses local model, handles exit codes)
# Web: Uses API client and fixes exit codes (exit 2 to block)

# Capture stdin for potential reuse
input=$(cat)

# Check if we're in web environment (API key is set)
if [ -n "$TDD_GUARD_ANTHROPIC_API_KEY" ]; then
    # Web environment: Use API client and fix exit codes
    export VALIDATION_CLIENT=api

    result=$(echo "$input" | npx tdd-guard 2>&1)

    # Check if result contains a block decision
    if echo "$result" | grep -q '"decision"[[:space:]]*:[[:space:]]*"block"'; then
        reason=$(echo "$result" | grep -o '"reason"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [ -n "$reason" ]; then
            echo "TDD Guard: $reason" >&2
        else
            echo "TDD Guard: Blocked - TDD violation detected" >&2
        fi
        exit 2
    fi
    exit 0
else
    # Local environment: Pass through directly to tdd-guard
    echo "$input" | npx tdd-guard
fi
