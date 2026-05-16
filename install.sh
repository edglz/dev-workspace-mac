#!/usr/bin/env bash
# Idempotent installer for dev-workspace-mac. Re-running is safe.
#
#   git clone https://github.com/edglz/dev-workspace-mac.git
#   cd dev-workspace-mac
#   ./install.sh
#
# Flags: --skip-brew --skip-pip --skip-npm --skip-zsh --skip-ghostty --skip-settings
#
# What it does:
#   1. Installs Homebrew if missing (needs sudo password once).
#   2. brew bundle --file=./Brewfile
#   3. Installs Oh My Zsh (unattended) if missing.
#   4. Installs zsh plugins: autosuggestions, syntax-highlighting, completions, fzf-tab.
#   5. Installs Powerlevel10k (via brew tap formula) and links the theme.
#   6. pip --user: httpie posting pgcli.
#   7. npm -g: wrangler @expo/cli @anthropic-ai/claude-code.
#   8. Symlinks zshrc, p10k.zsh, ghostty/config to your home.
#   9. Merges settings.template.json into ~/.claude/settings.json (backs up first).

set -euo pipefail

SKIP_BREW=false
SKIP_PIP=false
SKIP_NPM=false
SKIP_ZSH=false
SKIP_GHOSTTY=false
SKIP_SETTINGS=false

for arg in "$@"; do
  case "$arg" in
    --skip-brew)     SKIP_BREW=true ;;
    --skip-pip)      SKIP_PIP=true ;;
    --skip-npm)      SKIP_NPM=true ;;
    --skip-zsh)      SKIP_ZSH=true ;;
    --skip-ghostty)  SKIP_GHOSTTY=true ;;
    --skip-settings) SKIP_SETTINGS=true ;;
    -h|--help)
      sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"

c_cyan=$'\033[36m'; c_green=$'\033[32m'; c_gray=$'\033[90m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_reset=$'\033[0m'
step() { printf '%s==> %s%s\n' "$c_cyan" "$1" "$c_reset"; }
done_msg() { printf '%s    ok:   %s%s\n' "$c_green" "$1" "$c_reset"; }
skip() { printf '%s    skip: %s%s\n' "$c_gray" "$1" "$c_reset"; }
warn() { printf '%s    warn: %s%s\n' "$c_yellow" "$1" "$c_reset"; }
fail() { printf '%s    fail: %s%s\n' "$c_red" "$1" "$c_reset"; exit 1; }

# ── 1. Homebrew ───────────────────────────────────────────────────────────
if ! $SKIP_BREW; then
  step "Homebrew"
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Apple Silicon vs Intel paths
  if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d /usr/local/Homebrew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null || fail "brew not on PATH after install"
  done_msg "brew available ($(brew --version | head -1))"

  step "Brewfile"
  brew bundle --file="$ROOT/Brewfile"
  done_msg "Brewfile applied"
fi

# ── 2. Oh My Zsh ──────────────────────────────────────────────────────────
if ! $SKIP_ZSH; then
  step "Oh My Zsh"
  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  if [[ ! -d "$ZSH" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  done_msg "Oh My Zsh at $ZSH"

  step "Zsh plugins"
  ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
  declare -a plugins=(
    "https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    "https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions"
    "https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab"
  )
  for entry in "${plugins[@]}"; do
    url="${entry% *}"; dir="${entry##* }"
    if [[ -d "$dir/.git" ]]; then
      git -C "$dir" pull --quiet --ff-only || warn "could not update $(basename "$dir")"
      skip "$(basename "$dir") already present"
    else
      git clone --depth=1 --quiet "$url" "$dir"
      done_msg "$(basename "$dir")"
    fi
  done

  step "Symlink zshrc + p10k.zsh"
  for src in zshrc p10k.zsh; do
    target="$HOME/.$src"
    if [[ -e "$target" && ! -L "$target" ]]; then
      cp "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
      warn "backed up existing ~/.$src"
    fi
    ln -sf "$ROOT/$src" "$target"
    done_msg "~/.$src -> $ROOT/$src"
  done
fi

# ── 3. pip --user installs ────────────────────────────────────────────────
if ! $SKIP_PIP; then
  step "pip --user installs"
  PY="$(command -v python3 || true)"
  if [[ -z "$PY" ]]; then
    skip "python3 not on PATH"
  else
    # Modern pip refuses --user against Homebrew Python without --break-system-packages.
    # pipx is the recommended path; we install pipx via brew, then use it.
    if ! command -v pipx >/dev/null 2>&1; then
      brew install pipx
      pipx ensurepath >/dev/null
    fi
    # httpie comes from Homebrew (binary `http`); pipx only handles tools without a brew formula.
    for pkg in posting pgcli; do
      if pipx list --short 2>/dev/null | grep -q "^$pkg "; then
        skip "$pkg (pipx)"
      else
        pipx install "$pkg"
      fi
    done
    done_msg "posting, pgcli (via pipx)"
  fi
fi

# ── 4. npm globals ────────────────────────────────────────────────────────
if ! $SKIP_NPM; then
  step "npm globals"
  if ! command -v npm >/dev/null 2>&1; then
    skip "npm not on PATH"
  else
    npm install -g --silent wrangler @expo/cli @anthropic-ai/claude-code >/dev/null 2>&1 \
      || warn "npm global install reported a non-zero exit (often harmless)"
    done_msg "wrangler, @expo/cli, @anthropic-ai/claude-code"
  fi
fi

# ── 5. Ghostty config ─────────────────────────────────────────────────────
if ! $SKIP_GHOSTTY; then
  step "Ghostty config"
  GHOSTTY_DIR="$HOME/.config/ghostty"
  mkdir -p "$GHOSTTY_DIR"
  target="$GHOSTTY_DIR/config"
  if [[ -e "$target" && ! -L "$target" ]]; then
    cp "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
    warn "backed up existing $target"
  fi
  ln -sf "$ROOT/ghostty/config" "$target"
  done_msg "$target -> $ROOT/ghostty/config"
fi

# ── 6. Claude Code settings.json ──────────────────────────────────────────
if ! $SKIP_SETTINGS; then
  step "Claude settings.json"
  mkdir -p "$HOME/.claude"
  target="$HOME/.claude/settings.json"
  template="$ROOT/settings.template.json"

  if [[ -f "$target" ]]; then
    cp "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
    done_msg "backup -> $target.bak.*"
    # Merge: template wins for attribution + permissions, current keeps everything else.
    if command -v jq >/dev/null 2>&1; then
      tmp="$(mktemp)"
      jq -s '
        .[0] as $cur | .[1] as $tpl
        | $cur
        | .attribution = $tpl.attribution
        | .permissions = $tpl.permissions
      ' "$target" "$template" > "$tmp" && mv "$tmp" "$target"
      done_msg "merged into $target"
    else
      cp "$template" "$target"
      done_msg "replaced (jq missing) -> $target"
    fi
  else
    cp "$template" "$target"
    done_msg "created $target"
  fi
fi

echo
printf '%sDone.%s Open a new terminal (or `exec zsh`) and run %sws%s.\n' \
  "$c_green" "$c_reset" "$c_cyan" "$c_reset"
printf '%sFirst run of p10k may show a config wizard — just answer "n" to it; the bundled config is already linked.%s\n' \
  "$c_gray" "$c_reset"
