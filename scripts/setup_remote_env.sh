#!/bin/bash
# Setup script for mnemon remote database environment variables
# Usage: source scripts/setup_remote_env.sh

# Remote server configuration
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PORT=22

# Add mnemon to PATH if not already present
if [[ ":$PATH:" != *":/c/Users/Administrator/go/bin:"* ]]; then
    export PATH=$PATH:/c/Users/Administrator/go/bin
fi

echo "✓ Remote database environment configured:"
echo "  Host: $MNEMON_REMOTE_HOST"
echo "  User: $MNEMON_REMOTE_USER"
echo "  Port: $MNEMON_REMOTE_PORT"
echo ""
echo "You can now use mnemon commands, and they will execute on the remote server."
echo ""
echo "Examples:"
echo "  mnemon remember \"your memory\" --cat fact --imp 5"
echo "  mnemon recall \"search query\""
echo "  mnemon status"
