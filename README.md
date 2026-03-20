# neuromac-cli

A portable cyberpunk CLI toolkit for macOS. Dark void aesthetics, neon resonance, zero cruft.

**Includes:**
- **Ghostty** — terminal with custom neuromancer theme
- **Helix** — modal terminal editor, neuromancer-themed
- **Starship** — fast, minimal prompt with neuromancer colors
- **bat** — syntax-highlighted `cat` replacement
- **eza** — modern `ls` with icons and git status
- **git-delta** — beautiful git diffs with neuromancer colors
- **fzf** — fuzzy finder (Ctrl+R history, Ctrl+T file picker)
- **zoxide** — smart `cd` that learns your habits (`z` command)
- **asdf** — universal version manager
- **jq / yq** — JSON and YAML processing
- **Monaspace Neon NF** — the font that makes it all look right
- **zsh-autosuggestions + zsh-syntax-highlighting** — shell quality of life

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
| neon pink | `#ff6090` | Rust, errors |
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

If you use `uv` or another tool that doesn't set `PYENV_VERSION`, you may need:
```sh
export PYENV_VERSION=system  # in ~/.zshenv or your personal zshrc
```

---

## What this does NOT include

Things that are intentionally excluded (add them yourself or use a personal dotfiles layer on top):

- Language version managers (nvm, pyenv, uv, rbenv, etc.)
- Language version modules in Starship (add these yourself — see above)
- Cloud SDK integrations (gcloud, AWS, etc.)
- Kubernetes / Terraform / Docker tooling
- SSH configuration
- Any personally identifying information
