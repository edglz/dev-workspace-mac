# dev-workspace-mac — Brewfile
# Idempotent. Run with: brew bundle --file=./Brewfile
# Mirrors the Scoop manifest in edglz/dev-workspace, adapted for macOS.

# ── Taps ──────────────────────────────────────────────────────────────────
tap "homebrew/bundle"
tap "homebrew/services"
tap "hashicorp/tap"
tap "oven-sh/bun"
tap "supabase/tap"
tap "romkatv/powerlevel10k"

# ── Modern CLI (drop-in replacements) ─────────────────────────────────────
brew "eza"          # ls
brew "bat"          # cat
brew "ripgrep"      # grep
brew "fd"           # find
brew "sd"           # sed
brew "git-delta"    # diff (pager)
brew "difftastic"   # diff (structural) — binary: difft
brew "zoxide"       # cd
brew "dust"         # du
brew "duf"          # df
brew "xh"           # curl
brew "doggo"        # dig — modern DNS client (replaces ogham/dog, no longer maintained)
brew "btop"         # top
brew "procs"        # ps
brew "hyperfine"    # time / benchmarks
brew "tealdeer"     # man — binary: tldr
brew "jaq"          # jq
brew "yq"           # jq for YAML
brew "dasel"        # multi-format query
brew "fzf"          # fuzzy finder
brew "lazygit"      # git TUI
brew "just"         # make
brew "watchexec"    # watch
brew "gping"        # ping
brew "trippy"       # mtr/traceroute — binary: trip
brew "tokei"        # cloc

# ── Runtimes ──────────────────────────────────────────────────────────────
brew "node"
brew "oven-sh/bun/bun"
brew "pnpm"
brew "deno"
brew "python@3.12"
brew "go"
brew "mise"         # nvm/pyenv/rbenv replacement
brew "gradle"
brew "maven"

# ── VCS / GitHub ──────────────────────────────────────────────────────────
brew "gh"
brew "git"          # newer than Apple Git
brew "git-lfs"

# ── Cloud / tunnels ───────────────────────────────────────────────────────
brew "ngrok/ngrok/ngrok"
brew "cloudflared"
brew "rclone"

# ── API tooling ───────────────────────────────────────────────────────────
brew "httpie"       # http
brew "grpcurl"

# ── DB clients ────────────────────────────────────────────────────────────
brew "libpq", link: true   # psql without the server
brew "redis"               # includes redis-cli
brew "mysql-client"
brew "mongosh"
brew "supabase/tap/supabase"

# ── Kubernetes ────────────────────────────────────────────────────────────
brew "kubernetes-cli"      # kubectl
brew "k9s"
brew "kubectx"             # ships kubens too
brew "helm"
brew "stern"
brew "dive"
brew "minikube"
brew "kind"

# ── IaC ───────────────────────────────────────────────────────────────────
brew "hashicorp/tap/terraform"
brew "pulumi/tap/pulumi"

# ── Mobile / iOS / Android ────────────────────────────────────────────────
brew "cocoapods"            # iOS native + React Native
brew "fastlane"             # iOS/Android release automation
brew "xcodes"               # Xcode version manager
brew "swiftlint"
brew "swiftformat"
brew "ios-deploy"
brew "watchman"             # React Native + Metro file watcher
brew "android-platform-tools"  # adb, fastboot
brew "scrcpy"               # Android screen mirror

# ── Mac-native quality-of-life ────────────────────────────────────────────
brew "coreutils"            # GNU ls/date/etc as g-prefixed binaries
brew "gnu-sed"              # gsed
brew "gnu-tar"              # gtar
brew "findutils"            # gfind, gxargs
brew "grep"                 # ggrep (GNU)
brew "wget"
brew "curl"
brew "tree"
brew "ncdu"
brew "htop"
brew "jq"                   # ubiquitous classic, complements jaq
brew "gnupg"
brew "mas"                  # Mac App Store CLI
brew "mackup"               # backup config files to cloud
brew "trash"                # safer rm — sends to Trash

# ── Misc ──────────────────────────────────────────────────────────────────
brew "glow"                 # markdown viewer
brew "romkatv/powerlevel10k/powerlevel10k"  # prompt theme
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-completions"

# ── Casks ─────────────────────────────────────────────────────────────────
cask "docker"                            # Docker Desktop (per user choice)
cask "flutter"                           # Flutter SDK
cask "temurin@21"                        # Eclipse Temurin JDK 21 LTS
cask "font-meslo-lg-nerd-font"           # required by Powerlevel10k
cask "font-jetbrains-mono-nerd-font"     # nice alt for editors
cask "font-fira-code-nerd-font"          # backup
# Ghostty is assumed already installed; uncomment if you want brew to manage it:
# cask "ghostty"
