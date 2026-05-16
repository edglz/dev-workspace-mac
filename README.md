# dev-workspace-mac

[![license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![zsh](https://img.shields.io/badge/zsh-5.9%2B-1abc9c?logo=gnubash&logoColor=white)](https://www.zsh.org/)
[![ghostty](https://img.shields.io/badge/terminal-Ghostty-7aa2f7)](https://ghostty.org/)

The macOS counterpart of [edglz/dev-workspace](https://github.com/edglz/dev-workspace): a reproducible Apple Silicon development environment built on **Homebrew + Oh My Zsh + Powerlevel10k + Ghostty**, with modern CLI replacements, runtimes for backend / mobile / Docker / Kubernetes, and a Claude Code permission policy that auto-approves safe commands and asks before destructive ones.

## Quick start

```bash
git clone https://github.com/edglz/dev-workspace-mac.git
cd dev-workspace-mac
./install.sh
```

Open a new Ghostty window (or `exec zsh`) and run `ws` for the workspace overview.

The installer is idempotent: rerun it any time. Use `--skip-brew`, `--skip-pip`, `--skip-npm`, `--skip-zsh`, `--skip-ghostty`, or `--skip-settings` to skip parts.

## What it sets up

- **Homebrew** (Apple Silicon `/opt/homebrew` or Intel `/usr/local`).
- **~80 packages via `Brewfile`** (modern CLI replacements, runtimes, Docker Desktop, Kubernetes, IaC, mobile toolchains, DB clients, Nerd Fonts).
- **3 Python tools via `pipx`**: `httpie`, `posting`, `pgcli`.
- **3 npm globals**: `wrangler`, `@expo/cli`, `@anthropic-ai/claude-code`.
- **Oh My Zsh** with 20+ plugins (git, gh, docker, kubectl, helm, terraform, node, python, golang, brew, macos, fzf, z, autosuggestions, syntax-highlighting, completions, fzf-tab).
- **Powerlevel10k** prompt (`p10k.zsh`) — two-line theme matching the Windows workspace palette (cyan paths, yellow git, magenta when dirty, gray timing).
- **Ghostty config** (`ghostty/config`) — MesloLGS NF font, Tokyo Night palette, blur, sensible splits/keybinds.
- **Claude Code `settings.json`** — Bash allow/ask rules tailored for macOS toolchain (brew, pod, fastlane, xcrun, adb, colima, etc.), no auto-attribution.

## Profile commands

| Command          | What it does                                        |
| ---------------- | --------------------------------------------------- |
| `ws`             | Workspace overview: tools, aliases, perms summary   |
| `cheat`          | Tool catalog grouped by category                    |
| `cheat <tool>`   | One tool with description and example               |
| `cheat-search k` | Filter the catalog by keyword                       |
| `rules`          | Claude Code allow/ask/deny rules summary            |
| `paths`          | Profile, settings, brew, memory locations           |
| `aliases-modern` | Active modern-CLI aliases                           |
| `z <fragment>`   | Jump to a directory by frequency (zoxide)           |
| `lg`             | Lazygit (Git TUI)                                   |
| `k9s`            | Kubernetes TUI                                      |

## Aliases

| Alias  | Target  | Replaces      |
| ------ | ------- | ------------- |
| `ls`   | `eza`   | `ls`          |
| `ll`   | `eza -l --icons --git` | `ls -l`           |
| `la`   | `eza -la --icons --git` | `ls -la`         |
| `lt`   | `eza --tree --level=2` | `tree`            |
| `cat`  | `bat`   | `cat`         |
| `grep` | `rg`    | `grep`        |
| `find` | `fd`    | `find`        |
| `top`  | `btop`  | `top`/`htop`  |
| `ps2`  | `procs` | `ps`          |
| `dig`  | `doggo` | `dig`         |
| `diff` | `difft` | `diff`        |
| `curl` | `xh`    | `curl`        |
| `man`  | `tldr`  | `man`         |
| `du`   | `dust`  | `du`          |
| `df`   | `duf`   | `df`          |
| `ping` | `gping` | `ping`        |
| `rm`   | `trash` | `rm` (safer — sends to Trash) |
| `jq`   | `jaq`   | `jq`          |
| `lg`   | `lazygit` | git UI      |
| `g`    | `git`   | shorter       |
| `d`    | `docker` | shorter      |
| `dc`   | `docker compose` | docker-compose |
| `k`    | `kubectl` | kube         |
| `kx`   | `kubectx` | switch ctx   |
| `kn`   | `kubens` | switch ns    |
| `z`    | zoxide  | `cd`          |

## Tools

| Category   | Tools |
| ---------- | ----- |
| Modern CLI | eza, bat, rg, fd, sd, delta, difft, zoxide, dust, duf, xh, doggo, btop, procs, hyperfine, tldr, jaq, yq, dasel, fzf, lazygit, just, watchexec, gping, trip, tokei |
| Runtime    | node, bun, pnpm, deno, python, go, java (Temurin 21), gradle, mvn, mise |
| VCS        | gh, git, git-lfs |
| Container  | docker, colima (optional) |
| Cloud      | ngrok, cloudflared, rclone, wrangler |
| API        | http (httpie), posting, grpcurl |
| DB         | mongosh, pgcli, psql, mysql, redis-cli, supabase |
| Kubernetes | kubectl, k9s, kubectx, kubens, helm, stern, dive, minikube, kind |
| IaC        | terraform, pulumi |
| Mobile     | flutter, expo, cocoapods, fastlane, xcodes, swiftlint, swiftformat, ios-deploy, watchman, adb, scrcpy |
| Misc       | glow, brew, mas, trash, powerlevel10k |

Run `cheat` for the full catalog with descriptions and examples.

## Claude Code rules

The `settings.template.json` configures permissions so Claude can run safe operations without prompting and asks before destructive ones.

| Effect | Rules | Behaviour                          |
| ------ | ----- | ---------------------------------- |
| allow  | ~100  | Auto-approved, no prompt           |
| ask    | ~60   | Always confirm before running      |
| deny   | 0     | Nothing fully blocked              |

Highlights:

- **allow**: every modern CLI, all runtimes, `git`, `gh`, `docker`, `colima`, every Kubernetes tool, `terraform`, `pulumi`, full iOS toolchain (`pod`, `fastlane`, `xcrun`, `xcodebuild`, `swift`, `swiftlint`), Android (`adb`, `fastboot`, `scrcpy`, `emulator`), `flutter`, `expo`, DB clients, `brew`, all profile commands.
- **ask**: `git reset`, `git push --force`, `git rebase`, `rm -rf`, `sudo`, `brew uninstall/cleanup/autoremove`, `terraform apply/destroy`, `pulumi up/destroy`, `kubectl delete`, `helm uninstall`, `docker rm/rmi/system prune`, `supabase db reset`, `rclone sync/delete/purge`, `flutter clean`, `pod deintegrate`, `xcrun simctl erase/delete`, `adb uninstall`, `npm publish`, `mas uninstall`, and other one-way operations.
- `attribution.commit` and `attribution.pr` are set to empty strings so commits and PR descriptions are not auto-trailered.

The Windows version's `rtk hook` is omitted (Windows-only proxy). Add your own `hooks.PreToolUse` if you want.

## Repository layout

```
dev-workspace-mac/
  README.md                       this file
  CHANGELOG.md                    release notes
  LICENSE                         MIT
  install.sh                      Idempotent installer
  Brewfile                        Homebrew formulae + casks
  zshrc                           zsh profile (sourced as ~/.zshrc)
  p10k.zsh                        Powerlevel10k theme (sourced as ~/.p10k.zsh)
  ghostty/
    config                        Ghostty config (symlinked to ~/.config/ghostty/config)
  settings.template.json          Claude Code settings template
  .gitignore
  .github/
    ISSUE_TEMPLATE/               bug + feature templates
    pull_request_template.md
```

## Re-sync after pulling

```bash
git pull
./install.sh                                            # full re-sync
./install.sh --skip-brew --skip-pip --skip-npm          # only refresh zsh/ghostty/settings
```

## Manual steps the installer does not cover

- Open Ghostty → **Settings → Font** if the new MesloLGS NF font does not appear after install; or relog so the font cache refreshes.
- Sign in to GitHub: `gh auth login`.
- Sign in to App Store + run `mas` once if you want App Store automation.
- Install **Xcode** from the Mac App Store (~14 GB) for iOS development, then `sudo xcodebuild -license accept`.
- Install **Android Studio** separately if you need the full SDK; `android-platform-tools` only ships `adb`/`fastboot`.
- Run `flutter doctor` after install to surface remaining SDK requirements.
- Run `p10k configure` if you want to interactively tweak the prompt; the bundled `p10k.zsh` is preset.
- Reboot once after first run so launchd picks up the new shell PATH everywhere.

## Why these choices?

- **Ghostty over iTerm/Alacritty**: GPU-accelerated, native macOS, sane defaults, config-as-file, very low CPU on Apple Silicon.
- **Oh My Zsh over Antigen/zinit**: ergonomics + ecosystem; plugins are well-curated and easy for newcomers to discover.
- **Powerlevel10k over Starship**: instant prompt, no daemon, near-identical visual to your existing `workspace.omp.json`.
- **Docker Desktop (per user choice)**: full GUI, k8s, integrates well with the rest of the stack. Swap to `colima` if you want CLI-only (`brew install colima`, then `colima start`).
- **pipx over `pip --user`**: Homebrew Python now rejects `pip install --user` without `--break-system-packages`; `pipx` is the official escape hatch.

## License

MIT. See [LICENSE](LICENSE).
