# Remote Database Branch

This branch (`remote-db`) adds support for hosting the Mnemon database on a remote server via SSH.

## What's New

- **Remote execution via SSH**: All mnemon commands can execute on a remote server
- **Transparent operation**: No changes to command syntax - just set environment variables
- **Centralized database**: Multiple clients can share the same remote database
- **Simple configuration**: One-time setup with environment variables

## Quick Start

### 1. Install on Remote Server

```bash
ssh agentdoc@192.168.180.127
go install github.com/mnemon-dev/mnemon@latest
```

### 2. Configure Local Client

```bash
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113
```

### 3. Use Normally

```bash
mnemon remember "test" --cat general --imp 3
mnemon recall "test"
```

## Documentation

- [English Documentation](docs/REMOTE.md)
- [中文文档](docs/zh/REMOTE.md)

## Changes

### New Files

- `internal/remote/ssh.go` - SSH configuration management
- `internal/remote/execute.go` - Remote command execution
- `cmd/remote_helper.go` - Command forwarding helper
- `scripts/setup_remote.sh` - Interactive setup script
- `docs/REMOTE.md` - English documentation
- `docs/zh/REMOTE.md` - Chinese documentation

### Modified Files

- `cmd/root.go` - Added remote mode flags and configuration
- `cmd/remember.go` - Added remote execution support
- `cmd/recall.go` - Added remote execution support
- `cmd/link.go` - Added remote execution support
- `cmd/forget.go` - Added remote execution support
- `cmd/status.go` - Added remote execution support
- `CLAUDE.md` - Updated with remote mode information

## Requirements

- **sshpass**: Required for password authentication
  - Ubuntu/Debian: `sudo apt-get install sshpass`
  - macOS: `brew install sshpass`
  - Windows: Install in WSL or Git Bash

## Architecture

```
Local Client                    Remote Server
┌─────────────┐                ┌──────────────────────┐
│             │                │                      │
│  mnemon CLI │───SSH/sshpass──▶│  mnemon CLI         │
│             │                │  ~/.mnemon/          │
│             │◀───JSON────────│  (SQLite database)   │
└─────────────┘                └──────────────────────┘
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MNEMON_REMOTE_HOST` | Remote server address | Yes |
| `MNEMON_REMOTE_USER` | SSH username | Yes |
| `MNEMON_REMOTE_PASSWORD` | SSH password | Yes |
| `MNEMON_REMOTE_PORT` | SSH port (default: 22) | No |

## Testing

```bash
# Test remote connection
mnemon status

# Test remember
mnemon remember "test insight" --cat general --imp 3

# Test recall
mnemon recall "test"
```

## Future Improvements

- [ ] SSH key-based authentication
- [ ] HTTP API server mode (more efficient)
- [ ] Connection pooling
- [ ] TLS support
- [ ] Load balancing across multiple servers

## Merging to Main

This branch is ready to merge when:
1. Remote execution is tested on Ubuntu server
2. Documentation is reviewed
3. Security considerations are addressed

## Contact

For questions or issues, please open an issue on GitHub.
