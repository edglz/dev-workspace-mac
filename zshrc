# dev-workspace-mac — zsh profile
# Entry points: ws | cheat | rules | paths | aliases-modern
# Source order: this file -> Oh My Zsh -> plugins -> p10k.zsh

# ── Powerlevel10k instant prompt (must stay near the top) ─────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Homebrew on PATH (Apple Silicon first) ────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Resolve workspace root from the symlink at ~/.zshrc -> .../zshrc
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd -- "$(dirname -- "${(%):-%x}")" && pwd)}"
# When sourced via symlink, %x is ~/.zshrc; follow it.
if [[ -L "${(%):-%x}" ]]; then
  WORKSPACE_ROOT="$(cd -- "$(dirname -- "$(readlink "${(%):-%x}")")" && pwd)"
fi
export WORKSPACE_ROOT

# ── Oh My Zsh ─────────────────────────────────────────────────────────────
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Homebrew keeps /opt/homebrew/share group-writable so multiple admin users
# share a prefix without sudo. zsh's compinit treats g+w dirs as "insecure"
# and refuses to load completions from them until they are chmod'd, but the
# permission is intentional — silence the check instead of fighting brew.
export ZSH_DISABLE_COMPFIX=true

# Powerlevel10k as theme (installed via Homebrew tap and via Oh My Zsh custom)
# Prefer the brew-managed copy; fall back to a custom clone if present.
if [[ -d "$ZSH/custom/themes/powerlevel10k" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
elif [[ -f "$(brew --prefix powerlevel10k 2>/dev/null)/powerlevel10k.zsh-theme" ]]; then
  ZSH_THEME=""   # we source brew's copy below
else
  ZSH_THEME="robbyrussell"
fi

# Curated plugin set for backend / docker / mobile / Claude Code dev.
plugins=(
  git
  gh
  docker
  docker-compose
  kubectl
  helm
  terraform
  golang
  node
  npm
  yarn
  python
  pip
  pyenv
  rbenv
  brew
  macos
  vscode
  fzf
  z
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Bring fzf-tab in after compinit (OMZ runs compinit during oh-my-zsh.sh)
if [[ -d "$ZSH/custom/plugins/fzf-tab" ]]; then
  source "$ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh"
fi

# Brew-installed plugins (in case OMZ-custom clones are missing)
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
FPATH="$(brew --prefix 2>/dev/null)/share/zsh-completions:$FPATH"

# Powerlevel10k (brew copy) if not loaded via OMZ
if [[ -z "$ZSH_THEME" || "$ZSH_THEME" == "robbyrussell" ]]; then
  P10K_FILE="$(brew --prefix powerlevel10k 2>/dev/null)/powerlevel10k.zsh-theme"
  [[ -f "$P10K_FILE" ]] && source "$P10K_FILE"
fi

# ── Modern CLI aliases (parity with the Windows profile) ──────────────────
alias ls='eza'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons --git'
alias l='eza --icons --git'
alias cat='bat --paging=never'
alias less='bat'
alias grep='rg'
alias find='fd'
alias top='btop'
alias ps2='procs'
alias dig='doggo'
alias diff='delta'
alias man='tldr'
alias du='dust'
alias df='duf'
alias ping='gping'
alias traceroute='trip'
alias jq='jaq'           # keep classic available as `command jq` if needed

# GNU coreutils on PATH without the g-prefix (after brew install coreutils)
# Uncomment if you really want GNU ls overriding BSD ls system-wide.
# PATH="$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin:$PATH"

# ── Safer destructive ops ─────────────────────────────────────────────────
alias rm='trash'             # send to Trash via Homebrew "trash"

# ── Git shortcuts (in addition to OMZ git plugin) ─────────────────────────
alias g='git'
alias lg='lazygit'

# ── Docker / k8s shortcuts ────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'

# ── Tool initializers ─────────────────────────────────────────────────────
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"            # provides z
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v fzf      >/dev/null && eval "$(fzf --zsh 2>/dev/null || true)"
command -v thefuck  >/dev/null && eval "$(thefuck --alias 2>/dev/null)"

# ── PATH essentials (mobile, GNU tools, pipx, Cargo, Go bin) ──────────────
typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$(brew --prefix 2>/dev/null)/opt/libpq/bin"
  "$(brew --prefix 2>/dev/null)/opt/mysql-client/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.pub-cache/bin"
  "$HOME/Library/Android/sdk/platform-tools"
  "$HOME/Library/Android/sdk/emulator"
  $path
)
export PATH

# Android SDK (Android Studio default location)
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Java: prefer brew's Temurin 21
if [[ -d "/Library/Java/JavaVirtualMachines/temurin-21.jdk" ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
fi

# ── Tool catalog (parity with $WorkspaceTools) ────────────────────────────
# Format per line: name|category|replaces|description|example
typeset -ga WORKSPACE_TOOLS=(
  'eza|Modern|ls|Listing with colors, icons, Git status|eza --icons --git -la'
  'bat|Modern|cat|Cat with syntax highlighting and paging|bat README.md'
  'rg|Modern|grep|Ripgrep: 10-100x faster, respects .gitignore|rg "TODO" src/'
  'fd|Modern|find|Modern find: fast, regex-friendly|fd ".ts$"'
  'sd|Modern|sed|Intuitive find and replace (JS/Python regex)|sd "old" "new" file.txt'
  'delta|Modern|diff|Git diff with syntax and side-by-side|delta a.txt b.txt'
  'zoxide|Modern|cd|Jump to directories by frequency (z proj)|z myrepo'
  'dust|Modern|du|Visual disk usage with bars and tree|dust -d 2'
  'duf|Modern|df|Pretty df with per-device table|duf'
  'doggo|Modern|dig|DNS client with DoH/DoT, JSON, colors|doggo example.com MX'
  'btop|Modern|top|TUI system monitor with GPU and mouse|btop'
  'procs|Modern|ps|Colored process table with search|procs node'
  'hyperfine|Modern|time|Statistical benchmark (warmup + runs)|hyperfine "ls" "eza"'
  'tldr|Modern|man|tldr-pages: practical examples instantly|tldr tar'
  'jaq|Modern|jq|jq in Rust, faster and stricter|jaq ".items[]" data.json'
  'yq|Modern|jq(yaml)|YAML processor with jq-like syntax|yq ".version" pkg.yml'
  'dasel|Modern|jq|Multi-format query: JSON/YAML/TOML/XML/CSV|dasel -f config.toml ".server.port"'
  'fzf|Modern|-|Universal fuzzy finder|fzf'
  'lazygit|Modern|git UI|Full TUI for Git: stage, commit, rebase, merge|lazygit'
  'just|Modern|make|Modern task runner with justfile|just build'
  'watchexec|Modern|watch|Re-run command when files change|watchexec -e ts "npm test"'
  'gping|Modern|ping|Ping with real-time graph|gping google.com'
  'trip|Modern|traceroute|Trippy: traceroute/mtr TUI multi-protocol|trip google.com'
  'tokei|Modern|wc -l|Count lines of code grouped by language|tokei .'
  'node|Runtime|-|Node.js runtime (includes npm)|node app.js'
  'bun|Runtime|node/npm|Runtime + bundler + installer, 9-30x faster than npm|bun install'
  'pnpm|Runtime|npm|Symlinked package manager (saves GB on monorepos)|pnpm install'
  'deno|Runtime|node|TypeScript-first runtime, secure, native ESM|deno run main.ts'
  'python|Runtime|-|Python 3 + pip|python3 -m venv .venv'
  'go|Runtime|-|Go compiler|go build ./...'
  'java|Runtime|-|OpenJDK 21 (Eclipse Temurin LTS)|java -version'
  'gradle|Runtime|maven|JVM build tool (Kotlin/Java)|gradle build'
  'mvn|Runtime|-|Maven: classic JVM build/dependency tool|mvn package'
  'mise|Runtime|nvm/pyenv|Multi-version manager (Node/Python/Go/Ruby)|mise use node@20'
  'gh|VCS|-|GitHub CLI: PRs, issues, releases, gh copilot|gh pr create'
  'cloudflared|Cloud|-|Cloudflare tunnel (free, no limits)|cloudflared tunnel --url http://localhost:3000'
  'rclone|Cloud|rsync|Sync to S3/GCS/R2/Drive/Dropbox + 70 services|rclone sync ./local s3:bucket'
  'wrangler|Cloud|-|Cloudflare Workers/Pages/KV/R2/D1 CLI|wrangler deploy'
  'http|API|curl|HTTPie classic (Python) - complements xh|http GET httpbin.org/get'
  'posting|API|postman|Modern TUI API client (Textual), YAML requests|posting'
  'grpcurl|API|curl(grpc)|Curl for gRPC services with reflection|grpcurl -plaintext localhost:50051 list'
  'mongosh|DB|-|Official Mongo shell with autocomplete|mongosh "mongodb://localhost"'
  'pgcli|DB|psql|Postgres REPL with autocompletion|pgcli postgres://user@host/db'
  'psql|DB|-|Postgres official client (from libpq)|psql -h host -U user db'
  'mysql|DB|-|MySQL client (from mysql-client)|mysql -h host -u user -p'
  'redis-cli|DB|-|Redis CLI|redis-cli -h host -p 6379'
  'supabase|DB|-|Local Postgres + Auth + Storage + Edge Functions|supabase start'
  'kubectl|K8s|-|Official Kubernetes client|kubectl get pods -A'
  'k9s|K8s|kubectl UI|K8s TUI dashboard: pods, logs, exec, port-forward|k9s'
  'kubectx|K8s|-|Fast switch between K8s clusters|kubectx prod'
  'kubens|K8s|-|Fast switch between K8s namespaces|kubens kube-system'
  'helm|K8s|-|Kubernetes package manager (charts)|helm install nginx bitnami/nginx'
  'stern|K8s|kubectl logs|Tail multi-pod logs with regex and colors|stern app-'
  'dive|K8s|-|Inspect Docker image layers|dive my-image:latest'
  'kind|K8s|-|Local K8s cluster in Docker containers|kind create cluster'
  'docker|Container|-|Docker Desktop (Linux containers on macOS)|docker run hello-world'
  'terraform|IaC|-|IaC standard: AWS/GCP/Azure/Cloudflare|terraform apply'
  'pulumi|IaC|terraform|IaC with TS/Python/Go instead of HCL|pulumi up'
  'flutter|Mobile|-|Flutter SDK (includes dart) for cross-platform|flutter run'
  'expo|Mobile|-|Expo CLI for React Native (cloud build via EAS)|npx expo start'
  'cocoapods|Mobile|-|iOS dependency manager (pod install)|pod install'
  'fastlane|Mobile|-|Release automation for iOS/Android|fastlane ios beta'
  'xcodes|Mobile|-|Install + manage multiple Xcode versions|xcodes installed'
  'swiftlint|Mobile|-|Swift static analysis (linting)|swiftlint'
  'swiftformat|Mobile|-|Opinionated Swift formatter|swiftformat .'
  'ios-deploy|Mobile|-|Install + debug iOS apps on real devices via CLI|ios-deploy --bundle app.ipa'
  'watchman|Mobile|-|File watcher (React Native / Metro)|watchman watch-list'
  'adb|Mobile|-|Android Debug Bridge|adb devices'
  'scrcpy|Mobile|-|Mirror + control Android device from desktop|scrcpy'
  'glow|Misc|cat|Render Markdown with color in terminal|glow README.md'
  'brew|Misc|-|macOS package manager|brew install <tool>'
  'trash|Misc|rm|Send files to Trash instead of unlink|trash old.log'
  'powerlevel10k|Misc|-|Zsh prompt theme (see ~/.p10k.zsh)|p10k configure'
)

# ── Functions: ws / cheat / cheat-search / rules / paths / aliases-modern ─

ws_color() {
  case "$1" in
    cyan)   printf '\033[36m' ;;
    green)  printf '\033[32m' ;;
    yellow) printf '\033[33m' ;;
    magenta)printf '\033[35m' ;;
    gray)   printf '\033[90m' ;;
    red)    printf '\033[31m' ;;
    reset)  printf '\033[0m' ;;
  esac
}

_ws_field() {
  # _ws_field <line> <1|2|3|4|5>  → returns the Nth |-separated field
  local line="$1" n="$2" IFS='|'
  local -a parts=("${(@s.|.)line}")
  printf '%s' "${parts[$n]}"
}

cheat() {
  emulate -L zsh
  local tool="${1:-}"
  if [[ -n "$tool" ]]; then
    local line
    for line in "${WORKSPACE_TOOLS[@]}"; do
      [[ "$(_ws_field "$line" 1)" == "$tool" ]] || continue
      printf '\n  %s%s%s  %s[%s]%s  replaces %s%s%s\n' \
        "$(ws_color cyan)" "$(_ws_field "$line" 1)" "$(ws_color reset)" \
        "$(ws_color magenta)" "$(_ws_field "$line" 2)" "$(ws_color reset)" \
        "$(ws_color gray)" "$(_ws_field "$line" 3)" "$(ws_color reset)"
      printf '  %s\n' "$(_ws_field "$line" 4)"
      printf '  %s$ %s%s\n\n' "$(ws_color green)" "$(_ws_field "$line" 5)" "$(ws_color reset)"
      return 0
    done
    print -u2 "No tool named '$tool'. Run \`cheat\` for the catalog."
    return 1
  fi

  local cat name installed
  local -A by_cat
  for line in "${WORKSPACE_TOOLS[@]}"; do
    cat="$(_ws_field "$line" 2)"
    name="$(_ws_field "$line" 1)"
    by_cat[$cat]+="$name "
  done

  print
  print "  $(ws_color cyan)WORKSPACE TOOLS$(ws_color reset)"
  print "  $(ws_color gray)Run \`cheat <name>\` for description + example$(ws_color reset)"
  print
  for cat in ${(ko)by_cat}; do
    printf '  %s%-9s%s %s\n' \
      "$(ws_color yellow)" "$cat" "$(ws_color reset)" "${by_cat[$cat]}"
  done
  print
}

cheat-search() {
  emulate -L zsh
  local kw="${1:?usage: cheat-search <keyword>}"
  local line hit=0
  for line in "${WORKSPACE_TOOLS[@]}"; do
    if [[ "$line" == *"$kw"* ]]; then
      printf '  %s%-12s%s [%s] %s\n' \
        "$(ws_color cyan)" "$(_ws_field "$line" 1)" "$(ws_color reset)" \
        "$(_ws_field "$line" 2)" "$(_ws_field "$line" 4)"
      hit=1
    fi
  done
  (( hit )) || { print -u2 "No matches for '$kw'"; return 1; }
}

aliases-modern() {
  emulate -L zsh
  print
  print "  $(ws_color cyan)ACTIVE MODERN-CLI ALIASES$(ws_color reset)"
  print
  local a
  for a in ls ll la lt l cat grep find top ps2 dig diff curl man du df ping traceroute jq lg k kx kn d dc g; do
    local def="$(alias -- "$a" 2>/dev/null)"
    [[ -z "$def" ]] && continue
    printf '  %s%-10s%s -> %s\n' \
      "$(ws_color green)" "$a" "$(ws_color reset)" \
      "${def#$a=}"
  done
  print
}

rules() {
  emulate -L zsh
  local f="$HOME/.claude/settings.json"
  if [[ ! -f "$f" ]]; then
    print -u2 "settings.json not found at $f"
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    print -u2 "Install jq to use \`rules\`: brew install jq"
    return 1
  fi
  print
  print "  $(ws_color cyan)CLAUDE PERMISSION RULES$(ws_color reset)"
  print "  $(ws_color gray)$f$(ws_color reset)"
  print
  local allow ask deny
  allow=$(jq '.permissions.allow | length' "$f")
  ask=$(jq   '.permissions.ask   | length' "$f")
  deny=$(jq  '.permissions.deny  | length // 0' "$f")
  printf '  %sallow%s %3d\n' "$(ws_color green)"  "$(ws_color reset)" "$allow"
  printf '  %sask%s   %3d\n' "$(ws_color yellow)" "$(ws_color reset)" "$ask"
  printf '  %sdeny%s  %3d\n' "$(ws_color red)"    "$(ws_color reset)" "$deny"
  print
  print "  $(ws_color green)ALLOW$(ws_color reset)  (auto-approved):"
  jq -r '.permissions.allow[]' "$f" | sed 's/^/    /'
  print
  print "  $(ws_color yellow)ASK$(ws_color reset)    (confirm before running):"
  jq -r '.permissions.ask[]'   "$f" | sed 's/^/    /'
  print
}

paths() {
  emulate -L zsh
  local rows=(
    "Workspace root|$WORKSPACE_ROOT"
    "Zsh profile|$HOME/.zshrc"
    "P10k theme|$HOME/.p10k.zsh"
    "Oh My Zsh|$ZSH"
    "Ghostty config|$HOME/.config/ghostty/config"
    "Claude settings|$HOME/.claude/settings.json"
    "Claude memory dir|$HOME/.claude/projects"
    "Brewfile|$WORKSPACE_ROOT/Brewfile"
    "Brew prefix|$(brew --prefix 2>/dev/null)"
  )
  print
  printf '  %sPATHS%s\n\n' "$(ws_color cyan)" "$(ws_color reset)"
  local row key path exists
  for row in "${rows[@]}"; do
    key="${row%%|*}"; path="${row#*|}"
    if [[ -e "$path" ]]; then exists="$(ws_color green)✓$(ws_color reset)"
    else                      exists="$(ws_color gray)·$(ws_color reset)"
    fi
    printf '  %s  %-18s %s\n' "$exists" "$key" "$path"
  done
  print
}

workspace() {
  emulate -L zsh
  print
  print "  $(ws_color cyan)WORKSPACE$(ws_color reset)"
  print "  $(ws_color gray)=========$(ws_color reset)"
  print

  local total=${#WORKSPACE_TOOLS}
  local -A by_cat
  local line name cat probe installed_total=0
  for line in "${WORKSPACE_TOOLS[@]}"; do
    name="$(_ws_field "$line" 1)"
    cat="$(_ws_field "$line" 2)"
    probe="$name"
    case "$name" in
      expo)   probe="npx" ;;
      java)   probe="java" ;;
      bun)    probe="bun" ;;
    esac
    if command -v "$probe" >/dev/null 2>&1; then
      by_cat[$cat]+="$(ws_color green)$name$(ws_color reset) "
      (( installed_total++ ))
    else
      by_cat[$cat]+="$(ws_color gray)$name$(ws_color reset) "
    fi
  done

  printf '  %sTools (%d / %d installed)%s\n' "$(ws_color gray)" "$installed_total" "$total" "$(ws_color reset)"
  for cat in ${(ko)by_cat}; do
    printf '    %s%-9s%s %s\n' "$(ws_color yellow)" "$cat" "$(ws_color reset)" "${by_cat[$cat]}"
  done

  print
  print "  $(ws_color yellow)Profile commands$(ws_color reset)"
  print "    ws              Workspace overview (this view)"
  print "    cheat           Tool catalog by category"
  print "    cheat <tool>    Description and example for one tool"
  print "    cheat-search k  Filter the catalog by keyword"
  print "    rules           Claude Code permission rules summary"
  print "    paths           Profile, settings, brew, memory locations"
  print "    aliases-modern  Active modern-CLI aliases"
  print "    z <fragment>    Jump to dir by frequency (zoxide)"
  print "    lg              Lazygit"
  print "    k9s             Kubernetes TUI"
  print

  if [[ -f "$HOME/.claude/settings.json" ]] && command -v jq >/dev/null 2>&1; then
    local a b
    a=$(jq '.permissions.allow | length' "$HOME/.claude/settings.json")
    b=$(jq '.permissions.ask   | length' "$HOME/.claude/settings.json")
    printf '  %sClaude permissions%s  allow=%d  ask=%d\n\n' \
      "$(ws_color yellow)" "$(ws_color reset)" "$a" "$b"
  fi
}
alias ws=workspace

# ── Welcome banner (top-level interactive only, not when WORKSPACE_QUIET=1) ─
# Runs fastfetch once on a fresh terminal (or `exec zsh`) and prints the
# workspace ready line right below it. SHLVL=1 guards against nested shells
# (`zsh` inside zsh, sub-shells launched by scripts) so the big banner does
# not re-print every time something spawns a child zsh.
if [[ -o interactive && -z "${WORKSPACE_QUIET:-}" && "${SHLVL:-1}" -eq 1 ]]; then
  command -v fastfetch >/dev/null && fastfetch
  printf '%sWorkspace ready.%s Try %sws%s (overview), %scheat%s (tools), %srules%s (perms).\n' \
    "$(ws_color gray)" "$(ws_color reset)" \
    "$(ws_color cyan)" "$(ws_color reset)" \
    "$(ws_color cyan)" "$(ws_color reset)" \
    "$(ws_color cyan)" "$(ws_color reset)"
fi

# ── Powerlevel10k user config ─────────────────────────────────────────────
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
