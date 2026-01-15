#!/bin/bash
# TDD Guard Wrapper Script - Web Environment Version
# Uses simple rule-based validation instead of nested Claude calls
# Exit code 2 blocks the tool call (PreToolUse hook semantics)

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/tdd-guard/data"

# Read stdin into a variable
hook_data=$(cat)

# Parse key fields from hook data
hook_event=$(echo "$hook_data" | grep -o '"hook_event_name":"[^"]*"' | cut -d'"' -f4)
tool_name=$(echo "$hook_data" | grep -o '"tool_name":"[^"]*"' | cut -d'"' -f4)
file_path=$(echo "$hook_data" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)

# Save the hook data to modifications.json (for tracking)
if [ -n "$tool_name" ] && [ "$tool_name" != "TodoWrite" ]; then
    echo "$hook_data" > "$DATA_DIR/modifications.json"
fi

# SessionStart and UserPromptSubmit events: always allow
if [ "$hook_event" = "SessionStart" ] || [ "$hook_event" = "UserPromptSubmit" ]; then
    exit 0
fi

# Skip validation for non-Edit/Write/MultiEdit operations
if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ] && [ "$tool_name" != "MultiEdit" ]; then
    exit 0
fi

# Skip validation for tdd-guard data files and config files
case "$file_path" in
    */.claude/tdd-guard/*|*/.claude/settings.json|*/.claude/*.sh|*/jest.config.*|*/package.json|*/package-lock.json|*/.gitignore)
        exit 0
        ;;
esac

# Check if editing a test file - always allow test modifications
if echo "$file_path" | grep -qE '\.(test|spec)\.(ts|tsx|js|jsx)$|__tests__/'; then
    exit 0
fi

# For implementation files, check test status
test_file="$DATA_DIR/test.json"

# If no test data exists, require tests to be run first
if [ ! -f "$test_file" ]; then
    echo "TDD Guard: No test results found. Run tests first with 'npm test'" >&2
    exit 2
fi

# Check if all tests are passing (handle JSON with or without spaces)
test_status=$(grep '"reason"' "$test_file" | sed 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)

if [ "$test_status" = "passed" ]; then
    # All tests pass - in TDD, you need a FAILING test before implementing
    echo "TDD Guard: All tests are passing. Write a failing test first before adding implementation code. (Red phase of TDD)" >&2
    exit 2
fi

# Tests are failing - check if there's exactly one failing test (valid TDD state)
failing_count=$(grep -c '"state"[[:space:]]*:[[:space:]]*"failed"' "$test_file" 2>/dev/null || echo "0")

if [ "$failing_count" -eq 0 ]; then
    # No failing tests but status is not "passed" - likely an error
    echo "TDD Guard: Test status unclear. Run 'npm test' to get a clean test state." >&2
    exit 2
fi

if [ "$failing_count" -gt 1 ]; then
    # Multiple failing tests - may indicate adding tests without implementing
    echo "TDD Guard: Multiple tests failing ($failing_count). Focus on making one test pass at a time." >&2
    exit 2
fi

# Exactly one failing test - this is the valid Green phase state
# Implementation is allowed
exit 0
