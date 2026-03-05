#!/bin/bash
# Remote configuration setup script for Mnemon

echo "=== Mnemon Remote Database Configuration ==="
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed."
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt-get install sshpass"
    echo "  macOS: brew install sshpass"
    exit 1
fi

# Prompt for configuration
read -p "Remote host (IP or hostname): " REMOTE_HOST
read -p "Remote user: " REMOTE_USER
read -sp "Remote password: " REMOTE_PASSWORD
echo ""
read -p "Remote port [22]: " REMOTE_PORT
REMOTE_PORT=${REMOTE_PORT:-22}

# Test connection
echo ""
echo "Testing SSH connection..."
if sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Connection successful'" &> /dev/null; then
    echo "✓ SSH connection successful"
else
    echo "✗ SSH connection failed"
    echo "Please check your credentials and try again."
    exit 1
fi

# Check if mnemon is installed on remote server
echo "Checking if mnemon is installed on remote server..."
if sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "command -v mnemon" &> /dev/null; then
    REMOTE_VERSION=$(sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "mnemon --version 2>&1")
    echo "✓ mnemon is installed on remote server: $REMOTE_VERSION"
else
    echo "✗ mnemon is not installed on remote server"
    echo "Please install mnemon on the remote server first:"
    echo "  ssh ${REMOTE_USER}@${REMOTE_HOST}"
    echo "  go install github.com/mnemon-dev/mnemon@latest"
    exit 1
fi

# Create config directory
mkdir -p ~/.mnemon

# Write configuration
CONFIG_FILE=~/.mnemon/remote.conf
cat > "$CONFIG_FILE" << EOF
# Mnemon Remote Database Configuration
# Generated on $(date)

export MNEMON_REMOTE_HOST=$REMOTE_HOST
export MNEMON_REMOTE_USER=$REMOTE_USER
export MNEMON_REMOTE_PASSWORD=$REMOTE_PASSWORD
export MNEMON_REMOTE_PORT=$REMOTE_PORT
EOF

chmod 600 "$CONFIG_FILE"

echo ""
echo "✓ Configuration saved to $CONFIG_FILE"
echo ""
echo "To use remote mode, source the configuration file:"
echo "  source ~/.mnemon/remote.conf"
echo ""
echo "Or add to your shell profile (~/.bashrc or ~/.zshrc):"
echo "  source ~/.mnemon/remote.conf"
echo ""
echo "Then use mnemon commands as usual:"
echo "  mnemon remember \"test\" --cat general --imp 3"
echo "  mnemon recall \"test\""
echo ""
