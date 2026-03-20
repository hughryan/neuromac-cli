# neuromac-cli — Claude Code adoption guide

This file tells Claude Code how to help a new user adopt neuromac-cli on their machine.

## What this repo is

A portable macOS CLI toolkit with a unified cyberpunk "neuromancer" theme across:
- Ghostty terminal
- Helix editor
- Starship prompt
- bat, eza, fzf, zoxide, git-delta

## Your task when invoked

The user wants to adopt neuromac-cli. Help them reconcile the configs in this repo with their existing local setup. Do NOT blindly overwrite — read their current state first, identify conflicts, and guide them through the merge.

## Step-by-step approach

### 1. Audit existing configs

Check which of these exist and read their current content:
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

- For **new configs** (nothing currently exists): symlink directly.
- For **zshrc**: do NOT replace. Source the neuromac-cli zshrc from the existing one:
  ```zsh
  source ~/dev/neuromac-cli/config/zshrc
  ```
  Place this near the top, before their personal config. Remove any duplicated settings (eza aliases, bat alias, fzf config, zoxide, starship init — neuromac-cli handles all of these).
- For **gitconfig**: symlink neuromac-cli's gitconfig as `~/.gitconfig`, then create `~/.gitconfig-personal` with the user's `[user]` block. The neuromac-cli gitconfig `[include]`s this file.
- For **Ghostty config**: if they have personal settings (window size, working directory, etc.), preserve them. The theme and font settings can be adopted directly.
- For **Helix**: safe to replace if they don't have customizations. If they do, merge the theme and key settings.
- For **Starship**: if they have a custom prompt, show them the neuromac-cli config and let them decide which modules to keep.

### 5. Font

Check if MonaspaceNeonNF is installed:
```sh
ls ~/Library/Fonts/MonaspaceNeonNF* 2>/dev/null || fc-list | grep -i "monaspace neon"
```

If missing, it should have been installed by `brew bundle`. If not, guide them to install the `font-monaspice-nerd-font` cask or download from https://github.com/githubnext/monaspace/releases.

### 6. Verify

After applying:
- Open a new Ghostty window and confirm the neuromancer theme loads
- Run `hx` and confirm the theme applies
- Run `ls` and confirm eza with icons works
- Run `git diff` in any repo to confirm delta is active

## Key config locations in this repo

```
config/
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
Brewfile                      # all packages
```

## What NOT to touch

- The user's language version managers (nvm, pyenv, rbenv, etc.)
- Cloud SDK configurations
- SSH keys or agent config
- Any existing work in `~/dev` or other project directories
- VS Code settings (not managed by this repo)
