#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Mirrors p10k.zsh line-1: cyan path (last 3 segments) + git + runtime versions
# Receives Claude Code JSON on stdin.

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"

# ── ANSI helpers ────────────────────────────────────────────────────────────
reset='\033[0m'
cyan='\033[36m'
yellow='\033[33m'
magenta='\033[35m'
red='\033[31m'
green='\033[32m'
bold='\033[1m'

# ── Path: agnoster-short — keep last 3 segments, abbreviate parents ─────────
shorten_path() {
  local dir="$1"
  # Replace $HOME prefix with ~
  dir="${dir/#$HOME/~}"
  # Split on /
  IFS='/' read -ra parts <<< "$dir"
  local total=${#parts[@]}
  if [ "$total" -le 3 ]; then
    printf '%s' "$dir"
    return
  fi
  # Keep last 3 segments; abbreviate each earlier segment to its first char
  local result=""
  for (( i=0; i<total-3; i++ )); do
    seg="${parts[$i]}"
    if [ -z "$seg" ]; then
      result+="/"
    elif [ "$seg" = "~" ]; then
      result+="~/"
    else
      result+="${seg:0:1}/"
    fi
  done
  # Trim trailing slash before joining last 3
  result="${result%/}"
  local tail="${parts[*]: -3}"
  tail="${tail// //}"
  if [ -n "$result" ]; then
    printf '%s/%s' "$result" "$tail"
  else
    printf '%s' "$tail"
  fi
}

path_display=$(shorten_path "$cwd")

# ── Git segment ──────────────────────────────────────────────────────────────
git_segment=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  fi

  # ahead / behind (suppress lock contention)
  read -r ahead behind < <(
    git -C "$cwd" rev-list --count --left-right "@{upstream}...HEAD" 2>/dev/null \
      | awk '{print $2, $1}' || echo "0 0"
  )
  ahead=${ahead:-0}
  behind=${behind:-0}

  # dirty check: staged, unstaged, untracked
  dirty=0
  if ! git -C "$cwd" diff --quiet 2>/dev/null; then dirty=1; fi
  if ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then dirty=1; fi
  if [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then dirty=1; fi

  # Pick color per p10k formatter logic
  if [ "$behind" -gt 0 ]; then
    git_color="$red"
  elif [ "$ahead" -gt 0 ]; then
    git_color="$cyan"
  elif [ "$dirty" -eq 1 ]; then
    git_color="$magenta"
  else
    git_color="$yellow"
  fi

  #  branch glyph (nerd-font; falls back gracefully in plain terminals)
  git_text=" ${branch}"
  [ "$dirty" -eq 1 ] && git_text+=" *"
  [ "$ahead"  -gt 0 ] && git_text+=" ↑${ahead}"
  [ "$behind" -gt 0 ] && git_text+=" ↓${behind}"

  git_segment="${git_color}${git_text}${reset}"
fi

# ── Runtime versions (right-side, file-triggered) ───────────────────────────
runtime_parts=()

# Node — package.json anywhere up the tree
if [ -f "$cwd/package.json" ] && command -v node >/dev/null 2>&1; then
  node_ver=$(node --version 2>/dev/null)
  [ -n "$node_ver" ] && runtime_parts+=("${green}node ${node_ver}${reset}")
fi

# Python — requirements.txt or .python-version
if { [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/.python-version" ]; } && command -v python3 >/dev/null 2>&1; then
  py_ver=$(python3 --version 2>/dev/null | awk '{print $2}')
  [ -n "$py_ver" ] && runtime_parts+=("${yellow}py ${py_ver}${reset}")
fi

# Go — go.mod
if [ -f "$cwd/go.mod" ] && command -v go >/dev/null 2>&1; then
  go_ver=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
  [ -n "$go_ver" ] && runtime_parts+=("${cyan}go ${go_ver}${reset}")
fi

# ── Assemble ─────────────────────────────────────────────────────────────────
left="${cyan}${path_display}${reset}"
[ -n "$git_segment" ] && left+="  ${git_segment}"

right=""
if [ "${#runtime_parts[@]}" -gt 0 ]; then
  right=$(IFS='  '; printf '%s' "${runtime_parts[*]}")
fi

if [ -n "$right" ]; then
  printf '%b  %b\n' "$left" "$right"
else
  printf '%b\n' "$left"
fi
