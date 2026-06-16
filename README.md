# Agentic Toolkit

<p align="center">
  <img src="https://img.shields.io/github/package-json/v/hamr0/agentic-toolkit?label=version&color=2a4f8c" alt="version (auto from package.json)">
  <img src="https://img.shields.io/badge/license-Apache%202.0-2a4f8c" alt="license: Apache 2.0">
</p>

AI development subagents for Claude Code, OpenCode, Droid, and Amp — plus Linux
setup scripts for a terminal dev environment (tmux, Neovim/LazyVim, zsh, fzf,
lazygit, Kitty/Ghostty).

---

## What's inside

- **Subagent kits** (`ai/subagentic/`) — 11 role-based agents plus skills and
  slash-commands, ready to drop into each tool. See the
  [Subagent Manual](ai/subagentic/subagentic-manual.md).
- **Linux dev-tool setup** (`tools-debian/`, `tools-fedora/`) — per-distro
  scripts and guides to install and configure a terminal dev environment.
- **Customization** (`ai/customize/`) — BYOK keys, a Claude Code LLM/MCP
  switcher, Ollama configs, and agent guidelines.
- **Marketplace** (`ai/marketplace/`) — curated subagents, plugins, skills, MCP
  servers, and workflows.

## Install the subagents

```bash
# NPM (recommended) — interactive installer, auto-updates
npx liteagents

# or copy manually for your tool
cp -rv ai/subagentic/claude/*   ~/.claude/           # Claude Code
cp -rv ai/subagentic/opencode/* ~/.config/opencode/  # OpenCode
cp -rv ai/subagentic/droid/*    ~/.factory/          # Droid
cp -rv ai/subagentic/ampcode/*  ~/.config/amp/       # Amp
```

Invoke an agent with `@agent-name` (Claude/OpenCode/Amp) or
`invoke droid agent-name` (Droid); run commands with `/command-name`.

## Set up Linux dev tools

```bash
# pick your distro, then follow the interactive menu
./tools-fedora/dev_tools_menu.sh    # Fedora
./tools-debian/dev_tools_menu.sh    # Debian / Ubuntu
```

The menu installs and configures CLI tools, editors, and terminals. Per-tool
guides (tmux, LazyVim, zsh, fzf, lazygit, Kitty, Ghostty) live alongside the
scripts.

## Structure

```
ai/
  subagentic/   # agent kits: claude, opencode, droid, ampcode (+ manual)
  customize/    # byok, claude-switcher, ollama, config, skill-to-command
  marketplace/  # curated subagents, plugins, skills, mcp, workflows
tools-debian/   # Linux dev-tool setup (Debian / Ubuntu)
tools-fedora/   # Linux dev-tool setup (Fedora)
docs/           # guides
```

## Docs

- [Subagent Manual](ai/subagentic/subagentic-manual.md) — agents, token loads, progressive disclosure
- [Vibecoding 101](docs/vibecoding-101-guide.md) — beginner's guide to AI-powered development
- [Hot-memory pipeline](docs/friction-README.md) — how `/stash` and `/remember` work (friction runs inside `/remember`)
- [Agent Guidelines](ai/customize/config/AGENT_RULES.md) — AI collaboration guardrails

---

Apache 2.0 — see [LICENSE](LICENSE).
