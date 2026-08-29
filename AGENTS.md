# neuromac-cli — AI agent adoption guide

This file tells an AI coding agent (Claude Code, Codex, Cursor, etc.) how to help a new user adopt neuromac-cli on their machine.

## What this repo is

A portable macOS CLI toolkit with a unified cyberpunk "neuromancer" theme across:
- Ghostty terminal
- Helix editor
- Starship prompt
- bat, eza, fzf, zoxide, git-delta

No personal data. No cloud SDK config. No language-specific tooling. Safe to adopt on any developer machine.

## Your task when invoked

The user wants to adopt neuromac-cli. Help them reconcile the configs in this repo with their existing local setup. Do NOT blindly overwrite — read their current state first, identify conflicts, and guide them through the merge.

## Step-by-step approach

### 1. Audit existing configs

Check which of these exist and read their current content:
- `~/Library/Application Support/Code/User/settings.json`
- `~/.config/ghostty/config`
- `~/.config/ghostty/themes/neuromancer`
- `~/.config/helix/config.toml`
- `~/.config/helix/themes/neuromancer.toml`
- `~/.config/starship.toml`
- `~/.gitconfig`
- `~/.gitignore_global`
- `~/.zshenv`
- `~/.zshrc`

### 2. Audit installed packages

Run `brew list` and compare against the Brewfile in this repo. Tell the user what's missing.

### 3. Identify conflicts

For each config that already exists, diff it against the version in this repo. Highlight:
- Settings the user has that aren't in neuromac-cli (keep these)
- Settings that conflict (need a decision)
- Missing sections that neuromac-cli adds (safe to add)

### 4. Apply changes

- For **VS Code**: check if VS Code is installed. If so, symlink `config/vscode-settings.json` to `~/Library/Application Support/Code/User/settings.json`. If the user already has a settings.json, merge — keep their personal preferences (tab size, autoSave, extension settings, language overrides) and apply the neuromancer color/token blocks and font. The required keys are `workbench.colorTheme`, `workbench.colorCustomizations`, `editor.tokenColorCustomizations`, `editor.fontFamily`, `editor.fontLigatures`.

- For **new configs** (nothing currently exists): symlink directly.
- For **zshrc**: do NOT replace. Source the neuromac-cli zshrc from the existing one:
  ```zsh
  source ~/dev/neuromac-cli/config/zshrc
  ```
  Place this near the top, before their personal config. Remove any duplicated settings (fzf config, zoxide, starship init — neuromac-cli handles all of these). If they alias `ls` to eza or `cat` to bat, recommend removing those aliases and explain why (see "Why `ls` and `cat` are not aliased" below).
- For **gitconfig**: symlink neuromac-cli's gitconfig as `~/.gitconfig`, then create `~/.gitconfig-personal` with the user's `[user]` block. The neuromac-cli gitconfig `[include]`s this file.
- For **Ghostty config**: if they have personal settings (window size, working directory, etc.), preserve them. The theme and font settings can be adopted directly.
- For **Helix**: safe to replace if they don't have customizations. If they do, merge the theme and key settings.
- For **Starship**: symlink neuromac-cli's `starship.toml` as `~/.config/starship.toml`. This config intentionally has no language modules — they are stack-specific and must be added by the user (see "Language modules" below).

### 5. Font

Check if MonaspaceNeonNF is installed:
```sh
ls ~/Library/Fonts/MonaspaceNeonNF* 2>/dev/null || fc-list | grep -i "monaspace neon"
```

If missing, it should have been installed by `brew bundle`. If not, guide them to install the `font-monaspice-nerd-font` cask or download from https://github.com/githubnext/monaspace/releases.

### 6. AI CLI tool theme

If the user has Claude Code or another AI CLI tool installed, instruct them to set its theme to **ANSI Dark** (or equivalent). This makes the tool use the terminal's neuromancer palette instead of its own hardcoded colors.

- **Claude Code**: run `/theme` and select **ANSI Dark**
- Other tools: look for an "ANSI", "terminal", or "system" theme option

### 7. Verify

After applying:
- Open a new Ghostty window and confirm the neuromancer theme loads
- Run `hx` and confirm the theme applies
- Run `eza -la --git` and confirm icons and git status render
- Run `git diff` in any repo to confirm delta is active
- Press Ctrl+R and confirm fzf's history search opens
- Run `./scripts/verify-config.sh` from the repo — it should report `0 failed`
- If Claude Code is installed: confirm it's using ANSI Dark theme

## Key config locations in this repo

```
config/
  vscode-settings.json          # VS Code neuromancer theme + font (symlink or merge)
  ghostty/
    config                    # terminal settings
    themes/neuromancer        # 16-color ANSI palette
  helix/
    config.toml               # editor settings
    themes/neuromancer.toml   # full syntax theme
  starship.toml               # prompt config
  zshrc                       # shell (source this, don't replace)
  zshenv                      # EDITOR/VISUAL vars
  gitconfig                   # git settings (includes ~/.gitconfig-personal)
  gitignore_global            # global gitignore
  vimrc                       # minimal vim fallback
scripts/
  verify-config.sh            # smoke test: run after changing config/zshrc
Brewfile                      # all packages
AGENTS.md                     # this file (CLAUDE.md symlinks here)
```

## Language modules for Starship

The neuromac-cli `starship.toml` has no language version modules. This is intentional — language modules depend on version managers (pyenv, nvm, uv, rbenv, etc.) and misconfigured shims cause prompt hangs.

When helping a user adopt neuromac-cli, **ask them which languages and version managers they use**, then add the appropriate modules to their `~/.config/starship.toml`.

Full module reference: https://starship.rs/config/

### Adding a module

1. Add the module name to the `format` string (e.g. `$python`)
2. Add the module config block. Use neuromac-cli theme colors:
   - Python/warnings: `#ffe066` (neon amber)
   - Node.js/Go: `#50ffaa` (neon green)
   - Rust/errors: `#ff6090` (neon pink)
   - Kubernetes/Docker: `#4db8ff` (neon blue)
   - Terraform: `#e07aff` (neon purple)

### Common module configs

```toml
[python]
symbol = " "
style  = "bold #ffe066"
format = "[${symbol}${pyenv_prefix}(${version})( \\($virtualenv\\))]($style) "

[nodejs]
symbol = " "
style  = "bold #50ffaa"
format = "[$symbol$version]($style) "

[golang]
symbol = " "
style  = "bold #44f5e5"
format = "[$symbol$version]($style) "

[rust]
symbol = " "
style  = "bold #ff6090"
format = "[$symbol$version]($style) "

[terraform]
symbol = "󱁢 "
style  = "bold #e07aff"
format = "[$symbol$workspace]($style) "

[kubernetes]
symbol   = "⎈ "
style    = "bold #4db8ff"
format   = "[$symbol$context( \\($namespace\\))]($style) "
disabled = false

[docker_context]
symbol = " "
style  = "bold #4db8ff"
format = "[$symbol$context]($style) "
```

### Version manager gotchas

- **uv**: does not set `PYENV_VERSION`. The `pyenv_prefix` field in the Python module will be empty — that's fine.
- **nvm**: lazy-loaded nvm won't expose a Node version to starship unless nvm is fully initialized. Consider eager-loading nvm or using asdf for Node.

## Why `ls` and `cat` are not aliased

This repo installs `eza` and `bat` but does **not** alias them over `ls` and
`cat`. This is deliberate. Do not "helpfully" add those aliases back, and if a
user already has them, recommend removing them.

Shadowing a coreutil affects every shell that sources the config, not just an
interactive one — zsh expands aliases in non-interactive shells too (unlike
bash). So the alias reaches scripts, CI jobs, and AI CLI agents driving the
shell, none of which have a TTY. `eza` breaks in three ways under exactly those
conditions:

1. **A bare `ls` hangs forever.** Given no path argument, eza reads file names
   from stdin even without `--stdin`. Interactively stdin is a TTY so it lists
   the directory; when stdin is a pipe it blocks until the caller times out.
   With stdin closed it instead prints nothing and exits 0 — silently reporting
   a directory as empty. ([eza#1568](https://github.com/eza-community/eza/issues/1568))
2. **`ls <file>` errors.** `--icons` takes an *optional* value, so it swallows
   the next positional argument: `ls config` becomes
   `error: invalid value 'config' for '--icons [<WHEN>]'`. Writing
   `--icons=auto` avoids it. Same for `--classify`/`-F`, `--color`,
   `--hyperlink`, `--absolute`.
   ([eza#1864](https://github.com/eza-community/eza/issues/1864))
3. **Flags silently mean different things.** `-h` is `--header`, not
   human-readable. `-S` is block size, not sort-by-size. `-G` is grid, not
   no-group. `-t` and `-s` now require a value, so `ls -lt` errors. `-n`, `-o`,
   `-g`, `-m`, `-u`, `-T` all differ from GNU/BSD `ls`, and `-p`, `-c`, `-k`,
   `-Q` do not exist. A single `-a` omits `.`/`..`, unlike real `ls`.
   ([eza#1740](https://github.com/eza-community/eza/issues/1740))

`bat` degrades more gracefully — it drops to plain output when not on a TTY —
but it is still not `cat`: it formats errors differently, refuses some binary
input, and is slower. The same reasoning applies.

If a user wants short forms in their own interactive shell, that belongs in
their personal config, guarded on `[[ -o interactive ]]`, with the attached
value form:

```zsh
if [[ -o interactive ]]; then
  alias l='eza --icons=auto'
  alias ll='eza --icons=auto -la --git'
fi
```

## What NOT to touch

- The user's language version managers (nvm, pyenv, rbenv, etc.)
- Cloud SDK configurations
- SSH keys or agent config
- Any existing work in `~/dev` or other project directories
- VS Code settings (not managed by this repo)
