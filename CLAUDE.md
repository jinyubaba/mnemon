# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mnemon is an LLM-supervised persistent memory system for AI agents. It's a single Go binary + SQLite that provides cross-session memory through a four-graph knowledge store (temporal, entity, causal, semantic edges). The host LLM acts as external supervisor making judgment calls (what to remember, how to link, when to forget), while the binary handles deterministic computation (storage, graph indexing, search, decay).

## Development Commands

**Build & Install:**
```bash
make build          # Build binary to ./mnemon
make install        # Build + install to $GOBIN
mnemon setup        # Interactive setup (run after install)
```

**Testing:**
```bash
make test           # Run E2E test suite (bash scripts/e2e_test.sh)
make unit           # Run Go unit tests (go test ./...)
make vet            # Run go vet static analysis
```

**Other:**
```bash
make clean          # Remove build artifacts and test data
make help           # Show all available targets
mnemon setup --eject  # Remove all integrations
```

## Architecture

**Entry Point:** `main.go` → `cmd.Execute()` (Cobra CLI)

**Core Packages:**

- `cmd/` — CLI commands (remember, recall, link, forget, setup, store, gc, etc.)
- `internal/model/` — Data models (Insight, Edge types)
- `internal/store/` — SQLite database layer (WAL mode, schema migrations)
- `internal/graph/` — Four-graph edge generation engine:
  - `temporal.go` — Temporal backbone + proximity edges
  - `entity.go` — Entity co-occurrence edges
  - `causal.go` — Causal keyword edges (because/therefore/etc)
  - `semantic.go` — Vector similarity edges (optional, requires Ollama)
  - `engine.go` — Orchestrates all edge generators on insight creation
- `internal/search/` — Recall pipeline:
  - `intent.go` — Intent detection (WHY/WHEN/ENTITY/GENERAL)
  - `recall.go` — Beam search graph traversal with RRF anchor fusion
  - `keyword.go` — Token-scored keyword search
  - `diff.go` — Deduplication and conflict detection
- `internal/embed/` — Optional vector embeddings via Ollama
- `internal/setup/` — Integration setup for Claude Code, OpenClaw, NanoClaw

**Key Algorithms:**

- **Write Pipeline:** `remember` → diff check (skip duplicates/replace conflicts) → store insight → graph engine generates 4 edge types → optional embedding
- **Read Pipeline:** `recall` → intent detection → RRF anchor fusion (keyword + optional vector) → beam search graph traversal → multi-factor re-ranking → return top-K
- **Lifecycle:** Effective Importance (EI) decay over time, access-count boosting, auto-pruning via `gc` command

## Key Design Patterns

**LLM-Supervised Pattern:** The host LLM orchestrates via CLI; the binary is stateless per-invocation. Memory operations happen through hooks (Prime, Remind, Nudge, Compact) that inject prompts at lifecycle points.

**Intent-Native Protocol:** Three primitives (`remember`, `link`, `recall`) map to LLM cognitive vocabulary, not database syntax. Output is structured JSON with signal transparency.

**Store Isolation:** Named stores via `--store` flag or `MNEMON_STORE` env var. Default store is `default`. Each store is an isolated SQLite database.

**Sub-Agent Delegation:** Memory writes don't happen in main conversation. Host LLM decides *what* to remember, then delegates `mnemon remember` execution to a lightweight sub-agent (saves tokens).

## Dependencies

- Go 1.24+
- `modernc.org/sqlite` — Pure Go SQLite (no CGo)
- `spf13/cobra` — CLI framework
- `google/uuid` — UUID generation
- Optional: Ollama with `nomic-embed-text` for vector embeddings

## Configuration

Environment variables:
- `MNEMON_DATA_DIR` — Base data directory (default: `~/.mnemon`)
- `MNEMON_STORE` — Named memory store for data isolation (default: `default`)
- `MNEMON_EMBED_ENDPOINT` — Ollama API endpoint (default: `http://localhost:11434`)
- `MNEMON_EMBED_MODEL` — Embedding model name (default: `nomic-embed-text`)

## Documentation

- `docs/DESIGN.md` — Philosophy, algorithms, integration design (split into 8 sub-files in `docs/design/`)
- `docs/USAGE.md` — CLI command reference
- `README.md` — Quick start, features, vision
- `scripts/e2e_test.sh` — E2E test suite (reference for command usage)
