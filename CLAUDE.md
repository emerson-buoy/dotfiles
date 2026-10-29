# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A macOS developer productivity toolkit: shell aliases, multi-language utility scripts (Go, Python, JS/TS, Shell), Android release tools, and VS Code/Cursor IDE settings. Not an application — a personal dotfiles/scripts repo.

## Key Files & Entry Points

- **zshrc.sh** — `~/.zshrc` symlinks here. Sources `~/.dotfiles.env`, all alias files and any `aliases/*.local.sh`.
- **install.sh** — Runs `src/go/dotinstall`: builds tools, venv, symlinks config, installs the pre-commit leak check.
- **dotfiles.env.example** — Names of the local values; the real `~/.dotfiles.env` is never committed.
- **aliases/** — Shell aliases organized by category (git, docker, android, python, backend, etc.).
- **src/** — Utility scripts by language: `sh/`, `js/`, `python/`, `go/`, `typescript/`.
- **vs-settings/** — VS Code/Cursor settings backup (settings.json, keybindings, snippets, extensions).
- **android-release-suite/** — Android build/release tooling using bundletool.

## Common Commands

### Install / update the machine setup
```sh
./install.sh      # -n for a dry run
```

### Build Go utilities
```sh
cd src/go && ./build.sh
```

### Run Python AI tool
```sh
python3 src/python/ai.py chat "your question"
python3 src/python/ai.py translate "text"
python3 src/python/ai.py explain "code snippet"
```

### Run JS utilities
```sh
node src/js/time.js              # Show time across timezones
node src/js/dash-case.js "someString"
node src/js/list-aliases.js      # List all aliases
```

### Install VS Code/Cursor extensions
```sh
cd vs-settings && ./install-extensions.sh
```

## Architecture Notes

### Aliases system
All `aliases/*.sh` files are sourced by `zshrc.sh`. The `.gitignore` excludes company-specific alias files (e.g. `aliases-company.sh`). When adding a new alias category, create `aliases/aliases-<category>.sh` and add a source line to `zshrc.sh`.

### Python AI tool (`src/python/ai.py`)
Supports both OpenAI (GPT-4) and Ollama (local LLM). Mode is selected by CLI argument: `chat`, `translate`, `grammar`, `syntax`, `explain`.

### Go utilities (`src/go/`)
Standalone programs compiled via `build.sh`. Utilities for string case conversion (camelCase ↔ snake_case) and salary calculations.

### JS utilities (`src/js/`)
Plain Node.js scripts — no build step required. `time.js` shows current time in São Paulo, San Francisco, Munich, and local timezone.

### Secrets
Never commit secrets, not even encrypted. Values live in `~/.dotfiles.env` (hand-made) and are used as `$VARS`. Work-only aliases go in gitignored `aliases/*.local.sh`. The pre-commit hook (`dotinstall check`) blocks staged files containing any `.env` value.
