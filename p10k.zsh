# dev-workspace-mac — Powerlevel10k config
# Single-line prompt emulating the robbyrussell look:
#   left:    ➜  folder git:(branch) ✗  [exec time if >500ms]
#   right:   node, python, go versions (file-triggered)
#   colors:  green ➜ on success / red ➜ on failure
#            cyan folder + cyan git:() wrapper + red branch + yellow ✗ when dirty
#            cyan ↑N when ahead / red ↓N when behind
#   transient: ➜  on accepted lines
#
# Tweak with `p10k configure` if you want the full wizard.

# Silence the first-run wizard; this config is intentionally compact.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Wipe any prior p10k state.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # ── Segments ────────────────────────────────────────────────────────────
  # Single-line, robbyrussell-style: ➜ first, then folder, then git:(branch).
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    prompt_char
    dir
    vcs
    command_execution_time
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    node_version
    python_version
    go_version
  )

  # ── Style basics ────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_RULER_CHAR=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '

  # ── dir (path) — cyan, only the current folder (robbyrussell %c) ────────
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=0
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_HOME_ICON=
  typeset -g POWERLEVEL9K_HOME_SUB_ICON=
  typeset -g POWERLEVEL9K_FOLDER_ICON=
  typeset -g POWERLEVEL9K_ETC_ICON=

  # ── vcs (git) — robbyrussell-style `git:(branch)` wrapper ─────────────
  # Wrapper in cyan, branch in red, yellow ✗ when dirty,
  # cyan ↑N when ahead, red ↓N when behind.
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-aheadbehind)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=red
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=gray

  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    local branch="${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_COMMIT[1,8]}}"
    local res="%F{cyan}git:(%F{red}${branch}%F{cyan})%f"
    if (( VCS_STATUS_HAS_UNSTAGED || VCS_STATUS_HAS_STAGED || VCS_STATUS_HAS_UNTRACKED )); then
      res+=" %F{yellow}✗%f"
    fi
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" %F{cyan}↑${VCS_STATUS_COMMITS_AHEAD}%f"
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" %F{red}↓${VCS_STATUS_COMMITS_BEHIND}%f"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'

  # ── command_execution_time — dark gray, threshold 500ms ────────────────
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0.5
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=242
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ── prompt_char — green ➜ on success, red ➜ on failure ────────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=green
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '

  # ── Right-prompt runtime versions ───────────────────────────────────────
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=green
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION='node'

  typeset -g POWERLEVEL9K_PYTHON_VERSION_FOREGROUND=yellow
  typeset -g POWERLEVEL9K_PYTHON_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PYTHON_VERSION_VISUAL_IDENTIFIER_EXPANSION='py'

  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_GO_VERSION_VISUAL_IDENTIFIER_EXPANSION='go'

  # ── Transient prompt — just ❯ on accepted lines ─────────────────────────
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # ── Instant prompt: quiet (we trust our config) ─────────────────────────
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # ── Disable hot reload for speed ────────────────────────────────────────
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # Don't run `p10k configure` automatically.
  if (( ! $+functions[p10k] )) || ! p10k display '*/status' >/dev/null 2>&1; then
    :
  fi
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
