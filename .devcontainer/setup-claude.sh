#!/bin/bash
# Setup Claude Code authentication in devcontainer

set -e

CLAUDE_DIR="${HOME}/.claude"
CREDENTIALS_FILE="${CLAUDE_DIR}/.credentials.json"

echo "🔍 Checking Claude Code configuration..."

# Check if .claude directory exists
if [ ! -d "${CLAUDE_DIR}" ]; then
  echo "❌ ${CLAUDE_DIR} directory not found"
  echo "   Please ensure the devcontainer mounts are configured correctly"
  exit 1
fi

echo "✅ Claude directory found: ${CLAUDE_DIR}"

# Check if credentials file exists
if [ ! -f "${CREDENTIALS_FILE}" ]; then
  echo "⚠️  Credentials file not found: ${CREDENTIALS_FILE}"
  echo "   You may need to login to Claude Code manually"
  exit 0
fi

echo "✅ Credentials file found: ${CREDENTIALS_FILE}"

# Check file permissions
PERMS=$(stat -c "%a" "${CREDENTIALS_FILE}" 2>/dev/null || stat -f "%Lp" "${CREDENTIALS_FILE}" 2>/dev/null || echo "unknown")
echo "📋 Credentials file permissions: ${PERMS}"

# Ensure proper ownership (in case UID mapping is different)
if [ "$(stat -c "%U" "${CREDENTIALS_FILE}" 2>/dev/null)" != "$(whoami)" ]; then
  echo "⚠️  Credentials file owner mismatch, but this is expected with bind mounts"
fi

# Verify credentials file is valid JSON
if ! jq empty "${CREDENTIALS_FILE}" 2>/dev/null; then
  echo "⚠️  Credentials file is not valid JSON"
  exit 0
fi

echo "✅ Credentials file is valid JSON"

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
  echo "⚠️  Claude Code CLI not found in PATH"
  echo "   This is OK if you're using the VS Code extension"
  exit 0
fi

echo "✅ Claude Code CLI found"

# Test authentication (non-blocking)
if claude auth status &> /dev/null; then
  echo "✅ Claude Code is authenticated!"
else
  echo "⚠️  Claude Code authentication check failed"
  echo "   Please run 'claude auth login' if needed"
fi

echo "✨ Claude Code setup complete"
