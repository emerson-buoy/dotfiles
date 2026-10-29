# ~/.zshrc is a symlink to this file (see install.sh)

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Local values and secrets, never committed (see dotfiles.env.example)
[ -f ~/.dotfiles.env ] && { set -a; source ~/.dotfiles.env; set +a; }

export NODE_OPTIONS='--trace-deprecation'
export EDITOR="vim"

alias meld="open -W -a Meld $@"
alias python="python3"
alias pip="pip3"

source ~/scripts/aliases/aliases-git.sh
source ~/scripts/aliases/aliases-utils.sh
source ~/scripts/aliases/aliases-react-native.sh
source ~/scripts/aliases/aliases-personal.sh
source ~/scripts/aliases/aliases-code.sh
source ~/scripts/aliases/aliases-strings.sh
source ~/scripts/aliases/aliases-android.sh
source ~/scripts/aliases/aliases-folders.sh
source ~/scripts/aliases/aliases-docker.sh
source ~/scripts/aliases/aliases-linear.sh

# Local-only aliases (gitignored)
for f in ~/scripts/aliases/*.local.sh(N); do source "$f"; done

# SQLITE settings for M1
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PYTHON=/opt/homebrew/bin/python3
export LDFLAGS="-L/opt/homebrew/opt/sqlite/lib"
export CPPFLAGS="-I/opt/homebrew/opt/sqlite/include"

# NVM settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Android Dev
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-25.jdk/Contents/Home"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
# Android Dev

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

export PATH="$(brew --prefix ruby)/bin:$PATH"

eval "$(~/.local/bin/mise activate)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
