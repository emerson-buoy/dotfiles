# .dotfiles (MacOS) Development Toolkit

A collection of productivity tools and aliases for macOS development workflow.

## Required Software

- [Homebrew](https://brew.sh/)
- [ZSH](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/) (optional)
- [jq](https://formulae.brew.sh/formula/jq)
- [ffmpeg](https://formulae.brew.sh/formula/ffmpeg#default)
- [Google Chrome](https://www.google.com/chrome/)
- [Git](https://git-scm.com/download/mac)
- [Node.js](https://nodejs.org/en/download/)
- [NVM](https://github.com/nvm-sh/nvm)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/)

## Features

### Git Workflow
- Comprehensive git aliases and utilities
- Branch management and status checks
- Automated commit and push commands
- Diff utilities and branch cleanup
- Custom git configurations

### Development Tools
- Multi-language support (TypeScript, JavaScript, Python, Go)
- React Native development utilities
- Android development tools
- Docker management commands
- Backend development helpers
- String manipulation tools
- Python linting and utilities
- VSCode configurations

### AI and Productivity
- OpenAI/Claude integration
- AI-assisted development tools
- Project-specific shortcuts
- Folder navigation helpers
- Apple-specific utilities

## Installation

This repo is the live copy: it lives at `~/scripts` and your shell uses it directly.

1. Clone it: `git clone https://github.com/emersondemetrio/dotfiles.git ~/scripts`
2. Install required software (plus [Go](https://go.dev/))
3. Create your local values file: `cp ~/scripts/dotfiles.env.example ~/.dotfiles.env` and fill it in
4. Run `~/scripts/install.sh` (add `-n` for a dry run)

`install.sh` is safe to re-run (alias `dotinstall`). It:

- builds the Go tools in `src/go`
- makes scripts executable
- creates the Python venv in `.venv` from `src/python/requirements.txt`
- symlinks `~/.zshrc` and the Cursor settings, keybindings and snippets into this repo, backing up what was there to `~/.dotfiles-backup/`
- installs missing Cursor extensions from `vs-settings/cursor-extensions.txt`
- warns about values missing from `~/.dotfiles.env`
- installs a pre-commit hook that blocks commits containing any value from `~/.dotfiles.env`

## Secrets and local stuff

Nothing private is ever committed, not even encrypted.

- `~/.dotfiles.env`: tokens and machine values, created by hand, sourced by `zshrc.sh`. Aliases use them as `$VARS`.
- `aliases/*.local.sh`: gitignored aliases for work or this machine only, sourced if present.

## Day to day

- Edit files in `~/scripts` directly, then commit. Symlinked config (zshrc, Cursor) is the same file.
- `dotext` refreshes the Cursor extension list.
- `dotcheck` runs the leak check by hand.


## Directory Structure

```
.
├── aliases/                  # Shell aliases
│   ├── aliases-android.sh    # Android development aliases
│   ├── aliases-docker.sh     # Docker management
│   ├── aliases-git.sh        # Git workflow
│   ├── aliases-ai.sh        # AI tools integration
│   ├── aliases-python.sh    # Python development
│   ├── aliases-utils.sh     # General utilities
│   └── ... (other aliases)
├── src/                     # Source files
│   ├── typescript/         # TypeScript utilities
│   ├── js/                # JavaScript utilities
│   ├── python/            # Python scripts
│   ├── sh/                # Shell scripts
│   └── go/                # Go utilities
├── vs-settings/            # VSCode configurations
├── android-release-suite/  # Android release tools
├── zshrc.sh               # ~/.zshrc symlinks here
├── dotfiles.env.example   # Names of the values in ~/.dotfiles.env
└── install.sh             # Setup, runs src/go/dotinstall
```
