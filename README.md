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
- [Claude Code](https://claude.ai/code) installed (recommended for reconciliation — see below)

### 2. Clone

```sh
git clone https://github.com/hughryan/neuromac-cli.git ~/dev/neuromac-cli
cd ~/dev/neuromac-cli
```

### 3. Install packages

```sh
brew bundle
```

### 4. Apply configs (recommended: Claude Code)

The cleanest way to adopt these configs is to let Claude Code reconcile them against your existing setup:

```sh
cd ~/dev/neuromac-cli
claude
```

Then tell Claude:

> I want to adopt neuromac-cli. Read the CLAUDE.md file in this repo and help me reconcile the configs with my existing setup.

Claude will inspect your current dotfiles, identify conflicts, and guide you through the merge — preserving your personal settings while applying the neuromancer theme and tooling.

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

## What this does NOT include

Things that are intentionally excluded (add them yourself or use a personal dotfiles layer on top):

- Language version managers for specific stacks (nvm, pyenv, etc.)
- Cloud SDK integrations (gcloud, AWS, etc.)
- Kubernetes / Terraform / Docker tooling
- SSH configuration
- Any personally identifying information
