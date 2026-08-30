# neuromac-cli

A portable cyberpunk CLI toolkit for macOS. Dark void aesthetics, neon resonance, zero cruft.

**Includes:**
- **Ghostty** — terminal with custom neuromancer theme
- **Helix** — modal terminal editor, neuromancer-themed
- **VS Code** — neuromancer color + token theme, Monaspace Neon NF font
- **Starship** — fast, minimal prompt with neuromancer colors
- **bat** — syntax-highlighted file viewer (`bat FILE`)
- **eza** — modern directory lister with icons and git status (`eza -la --git`)
- **git-delta** — beautiful git diffs with neuromancer colors
- **fzf** — fuzzy finder (Ctrl+R history search, Ctrl+T file picker, path completion)
- **zoxide** — smart `cd` that learns your habits (`z` command)
- **asdf** — universal version manager
- **jq / yq** — JSON and YAML processing
- **Monaspace Neon NF** — the font that makes it all look right
- **zsh-autosuggestions + zsh-syntax-highlighting** — shell quality of life

> **Note:** `bat` and `eza` are installed but deliberately **not** aliased over
> `cat` and `ls`. They are not drop-in replacements, and shadowing coreutils
> breaks scripts, CI, and AI CLI agents that drive the shell. Invoke them by
> name. See [Why `ls` and `cat` are not aliased](AGENTS.md#why-ls-and-cat-are-not-aliased).

---

## Quick start

### 1. Prerequisites

- macOS (Apple Silicon — paths assume `/opt/homebrew`)
- [Homebrew](https://brew.sh) installed
- An AI coding agent installed (recommended for reconciliation — see below): [Claude Code](https://claude.ai/code), [Codex](https://openai.com/codex), Cursor, etc.

### 2. Clone

```sh
git clone https://github.com/hughryan/neuromac-cli.git ~/dev/neuromac-cli
cd ~/dev/neuromac-cli
```

### 3. Install packages

```sh
brew bundle
```

### 4. Apply configs (recommended: AI agent)

The cleanest way to adopt these configs is to let an AI coding agent reconcile them against your existing setup. Open this repo in Claude Code, Codex, or Cursor and say:

> I want to adopt neuromac-cli. Read the AGENTS.md file in this repo and help me reconcile the configs with my existing setup.

The agent will inspect your current dotfiles, identify conflicts, and guide you through the merge — preserving your personal settings while applying the neuromancer theme and tooling.

### 4b. Manual apply (advanced)

If you prefer to apply configs directly without reconciliation:

```sh
# VS Code
VSCODE_USER="$HOME/Library/Application Support/Code/User"
ln -sf "$(pwd)/config/vscode-settings.json" "$VSCODE_USER/settings.json"

# Ghostty
mkdir -p ~/.config/ghostty/themes
ln -sf "$(pwd)/config/ghostty/config"             ~/.config/ghostty/config
ln -sf "$(pwd)/config/ghostty/themes/neuromancer" ~/.config/ghostty/themes/neuromancer

# Helix
mkdir -p ~/.config/helix/themes
ln -sf "$(pwd)/config/helix/config.toml"               ~/.config/helix/config.toml
ln -sf "$(pwd)/config/helix/themes/neuromancer.toml"   ~/.config/helix/themes/neuromancer.toml

# Starship
ln -sf "$(pwd)/config/starship.toml" ~/.config/starship.toml

# Git (creates personal include file if it doesn't exist)
ln -sf "$(pwd)/config/gitconfig"        ~/.gitconfig
ln -sf "$(pwd)/config/gitignore_global" ~/.gitignore_global
touch ~/.gitconfig-personal  # add your [user] name/email here

# zsh
ln -sf "$(pwd)/config/zshenv" ~/.zshenv
# For zshrc: source this file from your existing ~/.zshrc rather than replacing it
echo 'source ~/dev/neuromac-cli/config/zshrc' >> ~/.zshrc
```

---

## Font

**Monaspace Neon NF** is installed via the `font-monaspice-nerd-font` cask in the Brewfile.

Manual download (if needed): https://github.com/githubnext/monaspace/releases

---

## gitconfig-personal

The included `gitconfig` uses `[include] path = ~/.gitconfig-personal` for your identity. Create that file:

```ini
[user]
    name = Your Name
    email = your@email.com
```

---

## Language version modules in Starship

The neuromac-cli Starship config intentionally omits language version modules (Python, Node, Go, Rust, etc.) — they depend on which version manager you use, and misconfigured shims can cause prompt hangs.

To add language modules, append them to your `~/.config/starship.toml` after the neuromac-cli config is applied. See the [Starship module docs](https://starship.rs/config/) for all available modules. All neuromac-cli colors are defined below as a reference for matching the theme:

| Color | Hex | Suggested use |
|---|---|---|
| neon cyan | `#00e8d8` | default / system |
| neon green | `#50ffaa` | Node.js, Go |
| neon amber | `#ffe066` | Python, warnings |
| neon red | `#ff2055` | errors, critical thresholds |
| neon pink | `#ff6090` | Rust, accents, identity |
| neon purple | `#e07aff` | Terraform, git branch |
| neon blue | `#4db8ff` | Kubernetes, Docker |

Example Python module (for pyenv or uv users):

```toml
# add to format string: $python
[python]
symbol = " "
style  = "bold #ffe066"
format = "[${symbol}${pyenv_prefix}(${version})( \\($virtualenv\\))]($style) "
```

---

## VS Code

neuromac-cli ships a `config/vscode-settings.json` that applies the neuromancer theme and font to VS Code. It requires two extensions (installed automatically via the Brewfile):

- **One Dark Pro** (`zhuangtongfa.material-theme`) — base theme, overridden with neuromancer colors
- **Material Icon Theme** (`pkief.material-icon-theme`) — file icons

The settings file covers theme, color customizations, token colors, and font. It intentionally omits personal editor preferences (tab size, autoSave, language-specific settings) — add those yourself on top.

---

## AI CLI tools

AI coding agents that run in the terminal (Claude Code, Codex CLI, etc.) need to be configured to use your terminal's color scheme rather than their own built-in theme. Without this, they render with colors that clash with the neuromancer palette.

**Claude Code** — ships a custom theme at `config/claude/themes/neuromancer.json`. It starts from Claude Code's built-in **ANSI Dark** preset (so the 16 ANSI slots come from the Ghostty palette) and overrides the named colour tokens Claude Code exposes on top — brighter body text than the terminal foreground, the purple assistant accent, the green/amber/pink status trio, cyan permission borders, deep green/pink diff backgrounds and palette-matched subagent colours.

```sh
mkdir -p ~/.claude/themes
ln -sf "$(pwd)/config/claude/themes/neuromancer.json" ~/.claude/themes/neuromancer.json
```

Then run `/theme` inside Claude Code and pick **Neuromancer**, or set `"theme": "custom:neuromancer"` in `~/.claude/settings.json`. Claude Code hot-reloads the file on edit, so tune colours live; if `~/.claude/themes/` did not exist when Claude Code started, restart it once. Token names are documented at https://code.claude.com/docs/en/terminal-config#create-a-custom-theme.

Other terminal AI tools typically have a similar setting — look for "ANSI", "terminal", or "system" theme options.

---

## Shell startup performance

The `config/zshrc` is optimized to keep shell startup fast:

- **Homebrew** — `brew shellenv` is guarded with a `HOMEBREW_PREFIX` check and skipped when already initialized (e.g. by `/etc/zprofile` in login shells), avoiding a Ruby subprocess on every shell start.
- **zsh-autosuggestions, zsh-syntax-highlighting, fzf** — compiled to `.zwc` bytecode on first load via `zcompile`; zsh sources the compiled version automatically on subsequent shells.
- **zoxide, starship** — init scripts are cached to `~/.cache/zsh/` (also compiled to `.zwc`) and regenerated automatically when the binary changes (e.g. after `brew upgrade`).
- **Interactive-only loading** — zle widgets, the prompt and history integrations load only when the shell is interactive. zsh runs `zshrc` for non-interactive shells too (scripts, CI, AI CLI agents), which cannot use any of it. This takes the config from 23.2ms to 4.65ms per shell, against a 4.51ms bare-zsh baseline.

Run `./scripts/verify-config.sh` to check all of this still holds. It asserts that nothing shadows a coreutil, that everyday commands work non-interactively without hanging, and that the interactive/non-interactive split is intact. These properties are invisible in ordinary terminal use, so they regress silently — an upstream tool change is enough to break them.

---

## What this does NOT include

Things that are intentionally excluded (add them yourself or use a personal dotfiles layer on top):

- Language version managers (nvm, pyenv, uv, rbenv, etc.)
- Language version modules in Starship (add these yourself — see above)
- Cloud SDK integrations (gcloud, AWS, etc.)
- Kubernetes / Terraform / Docker tooling
- SSH configuration
- Any personally identifying information
