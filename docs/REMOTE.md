# Remote Database Configuration

This branch adds support for hosting the Mnemon database on a remote server via SSH.

## Setup

### 1. Install Mnemon on Remote Server

SSH into your Ubuntu server and install mnemon:

```bash
ssh agentdoc@192.168.180.127
# On the remote server:
go install github.com/mnemon-dev/mnemon@latest
# Or build from source
```

### 2. Configure Local Client

Set environment variables to enable remote mode:

```bash
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113
export MNEMON_REMOTE_PORT=22  # Optional, defaults to 22
```

Or create a configuration file `~/.mnemon/remote.conf`:

```bash
MNEMON_REMOTE_HOST=192.168.180.127
MNEMON_REMOTE_USER=agentdoc
MNEMON_REMOTE_PASSWORD=js20220113
MNEMON_REMOTE_PORT=22
```

### 3. Install sshpass (Required)

The remote mode uses `sshpass` for password authentication:

**Ubuntu/Debian:**
```bash
sudo apt-get install sshpass
```

**macOS:**
```bash
brew install sshpass
```

**Windows (Git Bash/WSL):**
```bash
# In WSL:
sudo apt-get install sshpass
```

## Usage

Once configured, all mnemon commands will automatically execute on the remote server:

```bash
# Remember - stores on remote server
mnemon remember "Important decision" --cat decision --imp 5

# Recall - queries remote database
mnemon recall "decision"

# All other commands work the same way
mnemon status
mnemon log
```

## How It Works

1. When `MNEMON_REMOTE_HOST` is set, the client enters "remote mode"
2. All commands are forwarded to the remote server via SSH
3. The remote server executes the command locally
4. Results are returned to the local client

## Architecture

```
Local Client                    Remote Server (192.168.180.127)
┌─────────────┐                ┌──────────────────────┐
│             │                │                      │
│  mnemon CLI │───SSH/sshpass──▶│  mnemon CLI         │
│             │                │  ~/.mnemon/          │
│             │◀───JSON────────│  (SQLite database)   │
└─────────────┘                └──────────────────────┘
```

## Security Notes

- Password authentication is used for simplicity
- For production, consider using SSH key-based authentication
- The password is passed via environment variable (not stored in code)
- Consider using SSH config with key-based auth for better security

## Future Improvements

- [ ] Support SSH key-based authentication
- [ ] Add connection pooling/caching
- [ ] Implement HTTP API server mode (more efficient than SSH)
- [ ] Add TLS support for API mode
- [ ] Support multiple remote servers (load balancing)
