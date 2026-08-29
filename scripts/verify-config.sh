#!/usr/bin/env zsh
#
# Smoke test for config/zshrc.
#
# Guards two properties that are invisible in ordinary terminal use and so tend
# to regress silently:
#
#   1. Nothing in the config shadows a coreutil. zsh — unlike bash — expands
#      aliases in non-interactive shells, so an `alias ls=eza` reaches scripts,
#      CI, and AI CLI agents. eza then reads stdin when given no path argument
#      (eza#1568, hangs on a pipe), swallows the next argument after bare
#      `--icons` (eza#1864), and rejects `-t`/`-s` without a value (eza#1740).
#   2. zle/prompt/history integrations load for interactive shells only, and
#      not at all for non-interactive ones.
#
# Usage: ./scripts/verify-config.sh   (exit 0 = all good)

set -u
setopt no_aliases  # the harness itself must never inherit what it is testing

REPO_ROOT=${0:A:h:h}
ZSHRC="$REPO_ROOT/config/zshrc"
ALARM_SECS=10

[[ -r $ZSHRC ]] || { print -u2 "verify-config: cannot read $ZSHRC"; exit 2 }

# A private ZDOTDIR keeps the user's own ~/.zshrc (which layers personal config
# on top of this repo) out of the results. ZDOTDIR governs .zshenv too, so the
# empty .zshenv is what isolates non-interactive shells.
SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT INT TERM
: > "$SANDBOX/.zshenv"
print -r -- "source ${(q)ZSHRC}" > "$SANDBOX/.zshrc"

cd "$REPO_ROOT"

typeset -i passed=0 failed=0 skipped=0 hangs=0

section() { print -r -- ""; print -r -- "$1" }
ok()      { print -r -- "  PASS  $1"; (( passed  += 1 )) }
fail()    { print -r -- "  FAIL  $1"; (( failed  += 1 )) }
skip()    { print -r -- "  SKIP  $1"; (( skipped += 1 )) }

# Runs zsh under the sandbox ZDOTDIR with a watchdog, setting RUN_OUT, RUN_ERR,
# RUN_STATUS and RUN_BYTES (stdout length).
#
#   run_zsh plain <code>        non-interactive; <code> runs after the config is
#                               sourced explicitly, since `zsh -c` reads no rc file
#   run_zsh interactive <code>  interactive; the sandbox .zshrc sources the config
#
# macOS ships no timeout(1). perl's alarm survives the exec, so a command that
# blocks is killed by SIGALRM and reported as exit 142 — the one failure mode
# worth distinguishing, since a hung shell wedges every caller behind it.
run_zsh() {
  local mode=$1 code=$2
  local -a shell_argv
  case $mode in
    plain)       shell_argv=(zsh -c "source ${(q)ZSHRC}"$'\n'"$code") ;;
    interactive) shell_argv=(zsh -ic "$code") ;;
  esac
  perl -e 'alarm shift; exec @ARGV' "$ALARM_SECS" \
    env ZDOTDIR="$SANDBOX" "${shell_argv[@]}" \
    > "$SANDBOX/out" 2> "$SANDBOX/err" < /dev/null
  RUN_STATUS=$?
  RUN_BYTES=$(wc -c < "$SANDBOX/out")
  RUN_OUT=$(< "$SANDBOX/out")
  RUN_ERR=$(< "$SANDBOX/err")
  (( RUN_STATUS == 142 )) && (( hangs += 1 ))
  return 0
}

# Reads a `##K key=value` line out of RUN_OUT. Interactive shells interleave
# terminal escapes with their output, so match leniently rather than anchoring.
probe_val() { print -r -- "$RUN_OUT" | sed -n "s/.*##K $1=//p" | tail -1 }


# ── A. No alias shadows a coreutil in a non-interactive shell ────────────────
section "A. non-interactive shell defines no coreutil aliases"

# Aliases are expanded at parse time, so a plain `ls` on a line the parser had
# already read would not see one defined by the sourced config. Inspect the
# alias tables directly here, and force a reparse with eval in section B.
run_zsh plain '
  for a in ls la lt tree cat; do
    (( ${+aliases[$a]} + ${+galiases[$a]} )) && print -r -- "##K ALIAS=$a"
  done
  (( ${+aliases[mkdirp]} )) && print -r -- "##K MKDIRP=1"
'
if (( RUN_STATUS == 142 )); then
  fail "sourcing config/zshrc HUNG (killed after ${ALARM_SECS}s)"
elif (( RUN_STATUS != 0 )); then
  fail "sourcing config/zshrc exited $RUN_STATUS: $RUN_ERR"
else
  for name in ls la lt tree cat; do
    if print -r -- "$RUN_OUT" | grep -q "##K ALIAS=$name\$"; then
      fail "\`$name\` is aliased — it must not shadow the coreutil"
    else
      ok "\`$name\` is not aliased"
    fi
  done
  # Positive control: without it, a config that failed to source passes vacuously.
  if [[ $(probe_val MKDIRP) == 1 ]]; then
    ok "\`mkdirp\` alias present (config really was sourced)"
  else
    fail "\`mkdirp\` alias missing — config/zshrc did not load, other results are meaningless"
  fi
fi


# ── B. Everyday commands work non-interactively ──────────────────────────────
section "B. everyday commands succeed with output, non-interactively"

for cmd in 'ls' 'ls -la' 'ls config' 'ls -lt' 'ls -lh README.md' 'cat Brewfile'; do
  run_zsh plain "eval ${(q)cmd}"   # eval forces the reparse that expands aliases
  if (( RUN_STATUS == 142 )); then
    fail "\`$cmd\` HUNG (killed after ${ALARM_SECS}s — a command is reading stdin)"
  elif (( RUN_STATUS != 0 )); then
    fail "\`$cmd\` exited $RUN_STATUS: ${RUN_ERR:-no stderr}"
  elif (( RUN_BYTES == 0 )); then
    fail "\`$cmd\` exited 0 but printed nothing"
  else
    ok "\`$cmd\` exited 0 with output"
  fi
done


# ── C. The harness can still fail ────────────────────────────────────────────
section "C. a known-bad command still fails"

run_zsh plain 'eval "ls definitely-nonexistent-path"'
if (( RUN_STATUS == 142 )); then
  fail "\`ls definitely-nonexistent-path\` HUNG (killed after ${ALARM_SECS}s)"
elif (( RUN_STATUS == 0 )); then
  fail "\`ls definitely-nonexistent-path\` exited 0 — these assertions prove nothing"
else
  ok "\`ls definitely-nonexistent-path\` exited $RUN_STATUS"
fi


# ── D. Interactive shells still load their integrations ──────────────────────
section "D. interactive shell loads prompt, history and completion integrations"

run_zsh interactive '
  print -r -- "##K PROMPT_LEN=${#PROMPT}"
  print -r -- "##K PRECMD=${precmd_functions[*]}"
  print -r -- "##K AUTOSUGGEST=${+functions[_zsh_autosuggest_start]}"
  print -r -- "##K ZOXIDE=${+functions[z]}"
  print -r -- "##K ATUIN=${+functions[_atuin_search_widget]}"
  print -r -- "##K HAVE_STARSHIP=${+commands[starship]}"
  print -r -- "##K HAVE_ZOXIDE=${+commands[zoxide]}"
  print -r -- "##K HAVE_ATUIN=${+commands[atuin]}"
  [[ -r $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
    && print -r -- "##K HAVE_AUTOSUGGEST=1" || print -r -- "##K HAVE_AUTOSUGGEST=0"
'
if (( RUN_STATUS == 142 )); then
  fail "interactive shell HUNG (killed after ${ALARM_SECS}s)"
elif (( RUN_STATUS != 0 )); then
  fail "interactive shell exited $RUN_STATUS: $RUN_ERR"
else
  # Each integration is skipped, not failed, when its tool is not installed.
  if [[ $(probe_val HAVE_STARSHIP) == 1 ]]; then
    (( $(probe_val PROMPT_LEN) > 0 )) \
      && ok "PROMPT is set" || fail "PROMPT is empty — starship did not initialise"
    [[ $(probe_val PRECMD) == *prompt_starship_precmd* ]] \
      && ok "prompt_starship_precmd is in \$precmd_functions" \
      || fail "prompt_starship_precmd missing from \$precmd_functions"
  else
    skip "starship not installed (PROMPT, prompt_starship_precmd)"
  fi

  if [[ $(probe_val HAVE_AUTOSUGGEST) == 1 ]]; then
    [[ $(probe_val AUTOSUGGEST) == 1 ]] \
      && ok "_zsh_autosuggest_start is defined" \
      || fail "_zsh_autosuggest_start is not defined"
  else
    skip "zsh-autosuggestions not installed (_zsh_autosuggest_start)"
  fi

  if [[ $(probe_val HAVE_ZOXIDE) == 1 ]]; then
    [[ $(probe_val ZOXIDE) == 1 ]] \
      && ok "\`z\` is a function" || fail "\`z\` is not a function — zoxide did not initialise"
  else
    skip "zoxide not installed (\`z\`)"
  fi

  if [[ $(probe_val HAVE_ATUIN) == 1 ]]; then
    [[ $(probe_val ATUIN) == 1 ]] \
      && ok "_atuin_search_widget is defined" \
      || fail "_atuin_search_widget is not defined"
  else
    skip "atuin not installed (_atuin_search_widget)"
  fi
fi


# ── E. Non-interactive shells load none of them ──────────────────────────────
section "E. non-interactive shell loads none of those integrations"

run_zsh plain '
  print -r -- "##K PROMPT_LEN=${#PROMPT}"
  print -r -- "##K PRECMD=${precmd_functions[*]}"
  print -r -- "##K ZOXIDE=${+functions[z]}"
'
if (( RUN_STATUS != 0 )); then
  fail "non-interactive probe exited $RUN_STATUS: $RUN_ERR"
else
  [[ -z $(probe_val PRECMD) ]] \
    && ok "\$precmd_functions is empty" \
    || fail "\$precmd_functions is populated: $(probe_val PRECMD)"
  [[ $(probe_val PROMPT_LEN) == 0 ]] \
    && ok "PROMPT is empty" || fail "PROMPT is set ($(probe_val PROMPT_LEN) chars)"
  [[ $(probe_val ZOXIDE) == 0 ]] \
    && ok "\`z\` is not a function" || fail "\`z\` is defined outside an interactive shell"
fi


# ── F. Sourcing the config is side-effect free ───────────────────────────────
section "F. sourcing the config changes no cwd and prints nothing"

run_zsh plain ':'
if (( RUN_STATUS != 0 )); then
  fail "sourcing config/zshrc exited $RUN_STATUS: $RUN_ERR"
elif (( RUN_BYTES != 0 )); then
  fail "sourcing config/zshrc wrote $RUN_BYTES bytes to stdout: $RUN_OUT"
else
  ok "sourcing config/zshrc writes nothing to stdout"
fi

run_zsh plain 'print -r -- "##K PWD=$PWD"'
if (( RUN_STATUS != 0 )); then
  fail "cwd probe exited $RUN_STATUS: $RUN_ERR"
elif [[ $(probe_val PWD) == $REPO_ROOT ]]; then
  ok "sourcing config/zshrc leaves the working directory unchanged"
else
  fail "sourcing config/zshrc changed cwd to $(probe_val PWD)"
fi


# ── Summary ──────────────────────────────────────────────────────────────────
print -r -- ""
print -r -- "${passed} passed, ${failed} failed, ${skipped} skipped"
(( hangs > 0 )) && print -r -- "${hangs} shell(s) HUNG and were killed after ${ALARM_SECS}s"
(( failed == 0 )) || exit 1
