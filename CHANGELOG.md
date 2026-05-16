# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-05-16

### Added

- Initial macOS port of [edglz/dev-workspace](https://github.com/edglz/dev-workspace).
- `Brewfile` with ~80 packages: modern CLI replacements (eza, bat, ripgrep, fd, sd, git-delta, difftastic, zoxide, dust, duf, xh, doggo, btop, procs, hyperfine, tealdeer, jaq, yq, dasel, fzf, lazygit, just, watchexec, gping, trippy, tokei); runtimes (node, bun, pnpm, deno, python@3.12, go, mise, gradle, maven, Temurin 21); cloud (ngrok, cloudflared, rclone); API (httpie, grpcurl); DB clients (libpq/psql, redis, mysql-client, mongosh, supabase); Kubernetes (kubectl, k9s, kubectx, helm, stern, dive, minikube, kind); IaC (terraform, pulumi); mobile (cocoapods, fastlane, xcodes, swiftlint, swiftformat, ios-deploy, watchman, android-platform-tools, scrcpy); fonts (MesloLGS NF, JetBrains Mono NF, Fira Code NF).
- `install.sh` idempotent bootstrap covering Homebrew, Brewfile, Oh My Zsh, Powerlevel10k, zsh plugins, pipx globals (httpie, posting, pgcli), npm globals (wrangler, @expo/cli, @anthropic-ai/claude-code), symlinks for `~/.zshrc`, `~/.p10k.zsh`, `~/.config/ghostty/config`, and `~/.claude/settings.json`.
- `zshrc` profile with modern-CLI aliases, plugin set tailored to backend/docker/mobile/Claude Code dev, and shell functions `ws`/`cheat`/`cheat-search`/`rules`/`paths`/`aliases-modern` that mirror the Windows profile.
- `p10k.zsh` Powerlevel10k config replicating the Oh My Posh workspace theme: cyan path, yellow git (magenta dirty, red behind, cyan ahead), dark-gray execution time threshold 500 ms, right-prompt node/python/go versions, transient prompt `❯`.
- `ghostty/config` with MesloLGS NF font, Tokyo Night palette, background blur, sensible splits/keybinds, shell integration zsh.
- `settings.template.json` for Claude Code with ~100 allow / ~60 ask Bash rules tuned for the macOS toolchain (brew, pod, fastlane, xcrun, xcodebuild, swift, adb, fastboot, scrcpy, colima, etc.). No deny rules. `attribution.commit` and `attribution.pr` empty.
