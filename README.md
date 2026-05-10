# Agentic Toolkit

<p align="center">
  <img src="https://img.shields.io/github/package-json/v/hamr0/agentic-toolkit?label=version&color=2a4f8c" alt="version (auto from package.json)">
  <img src="https://img.shields.io/badge/license-Apache%202.0-2a4f8c" alt="license: Apache 2.0">
</p>

**Your Gateway to Vibecoding: AI-Powered Development Made Simple**

Discover proven tools and structured frameworks to start vibecoding as a non-technical or semi-technical user. Get essential scripts for Linux environments, learn through Vibecoding 101, and deploy ready-made AI subagents to accelerate your development workflow.

Featuring structured thinking frameworks, skills, and plugins that guide your AI collaboration for better results.

👉 [Start Learning Vibecoding 101](docs/vibecoding-101-guide.md) - Essential guide for beginners

---

## Core Value: Structured AI Development Made Simple

**Lightweight, structured subagents that enforce sequential task execution with built-in verification** - not just natural language prompting.

### Feature Overview

| Category | Component | Description |
|----------|-----------|-------------|
| **Agents** | 11 Role-Based Specialists | Orchestrator, QA, Dev, Architect, UX, Feature Planner, Market Researcher, Context Builder plus 3-phase workflow agents (1-create-prd, 2-generate-tasks, 3-process-task-list) |
| **Skills** | 11 Core Workflows | systematic-debugging, test-driven-development, verification-before-completion, testing-anti-patterns, root-cause-tracing, condition-based-waiting, brainstorming, code-review, skill-creator, docs-builder, live-canvas |
| **Commands** | 12 Development Tools | debug, explain, friction, git-commit, optimize, refactor, remember, review, security, ship, stash, test-generate |
| **Workflows** | 3-Phase Development | PRD Creation → Task Generation → Sequential Execution with automatic routing through digraph state machines |
| **Architecture** | Token Efficient | Progressive disclosure loads ~950 tokens for agent stubs, expands only when invoked |
| **Installation** | Multiple Options | Manual copy-paste (`cp -r ai/subagentic/claude/* ~/.claude/`) or NPM (`npx liteagents`) |
| **Verification** | Built-in Quality Gates | TDD enforcement, verification gates before completion, systematic debugging frameworks |

### Complete & Self-Sufficient

Works standalone out of the box. Optional: Add [Superpowers](https://github.com/obra/superpowers) framework for auto-triggering behavioral constraints if desired.

**[Full Subagent Manual](ai/subagentic/subagentic-manual.md)** | **[Install Now](#-quick-start)**

---

## 🚀 Quick Start

### Option 1: NPX (Recommended - No Installation)

```bash
npx liteagents
```

### Option 2: NPM Global Install

```bash
# Install globally (never use sudo)
npm install -g liteagents

# If permission errors, configure npm first:
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Run installer
liteagents
```

### Option 3: Manual Installation

```bash
# Clone the repository
git clone https://github.com/hamr0/agentic-toolkit.git && cd agentic-toolkit

# Install subagents for your platform (choose one)
cp -rv ai/subagentic/claude/* ~/.claude/          # Claude Code
cp -rv ai/subagentic/opencode/* ~/.config/opencode/  # OpenCode
cp -rv ai/subagentic/droid/* ~/.factory/         # Droid
cp -rv ai/subagentic/ampcode/* ~/.config/amp/    # Amp
```

[Vibecoding 101](docs/vibecoding-101-guide.md) | [Subagent Manual](ai/subagentic/subagentic-manual.md) | [Development Tools](tools/dev_tools_menu.sh)

---

## 📁 What's Included

### Development Tools
- **Interactive Installer**: `tools/dev_tools_menu.sh` - Choose and install Linux tools (Tmux, Neovim, etc.)
- **Automation Scripts**: Pre-configured setups for development environments
- **Complete Guide**: `tools/tools_guide.md` - Documentation for all tools

### Vibecoding 101 Guide
- **Beginner's Course**: `docs/vibecoding-101-guide.md` - Step-by-step guide for non-technical users
- **Core Concepts**: Tool selection, AI collaboration, avoiding common pitfalls
- **Practical Examples**: Real-world vibecoding scenarios and best practices

### Subagent Kits - Platform Support

**Installation Options**:
- **Manual**: `cp -rv ai/subagentic/<platform>/* <install-path>/` (see table below)
- **NPM Package**: `npx liteagents` - Auto-updates, no cloning ([repo](https://github.com/hamr0/liteagents))
- **[📖 Subagentic Manual](ai/subagentic/subagentic-manual.md)** - Token loads, progressive disclosure, complete reference

| Platform | Agents | Skills/Commands      | Install Path | Project Path | Source Path |
|----------|--------|----------------------|--------------|--------------|-------------|
| **Claude Code** | 11 agents | 11 skills + 12 commands + live-canvas-channel plugin | `~/.claude/` | `./.claude/` | `ai/subagentic/claude/` |
| **OpenCode** | 11 agents | 23 commands          | `~/.config/opencode/` | `./.opencode/` | `ai/subagentic/opencode/` |
| **Droid** | 11 droids | 23 commands          | `~/.factory/` | `./.factory/` | `ai/subagentic/droid/` |
| **Amp** | 11 agents | 11 skills + 12 commands | `~/.config/amp/` | `./.amp/` | `ai/subagentic/ampcode/` |

**Usage**: Invoke with `@agent-name` or `As agent-name, ...` (Claude/OpenCode/Amp) or `invoke droid agent-name` (Droid). Commands via `/command-name`.

### Curated Resources
- **AI Marketplace** (`ai/marketplace/`): 90+ reusable subagents (droids), plugins, skills, 200+ MCP servers, workflows
- **Ollama Local LLM** (`ai/customize/ollama`): Ollama configuration for OpenCode/Droid
- **Claude Code Switcher** (`ai/customize/claude-switcher`): Use GLM LLM/MCP on Claude Code
- **BYOK Config** (`ai/customize/byok`): Use Synthetic, GLM on OpenCode/Droid
- **Agent Best Practices** (`ai/customize/config`): Agent tweaks and guidelines

### 🔗 Optional: Superpowers Integration

Agentic Toolkit is **complete and self-sufficient**. Optionally add [Superpowers](https://github.com/obra/superpowers) for auto-triggering behavioral constraints (TDD must run first, verification before completion, fresh subagent isolation per task).

---

## 📂 Directory Structure

```
agentic-toolkit/
├── ai/
│   ├── subagentic/              # Subagent kits for all platforms
│   │   ├── claude/              # 11 agents + 11 skills + 12 commands + live-canvas-channel plugin
│   │   ├── opencode/            # 11 agents + 23 commands
│   │   ├── droid/               # 11 droids + 23 commands
│   │   └── ampcode/             # 11 agents + 11 skills + 12 commands
│   ├── customize/               # Platform customization configs
│   │   ├── byok/                # Bring Your Own Key configs
│   │   ├── claude-switcher/     # Claude Code LLM/MCP switcher
│   │   ├── config/              # Agent best practices
│   │   ├── memcp/               # Memory MCP server
│   │   ├── ollama/              # Local LLM configs
│   │   └── skill-to-command/    # Skill conversion tools
│   └── marketplace/             # Curated AI resources
│       ├── agents/              # 90+ specialized subagents
│       └── workflows/           # Workflow patterns
├── tools/                       # Development utilities
│   ├── dev_tools_menu.sh        # Interactive installer
│   ├── master_tmux_setup.sh     # Tmux automation
│   ├── master_neovim_setup.sh   # Neovim automation
│   └── tools_guide.md           # Tools documentation
├── docs/                        # Documentation
│   └── vibecoding-101-guide.md  # Beginner's guide
└── env/                         # Environment configs
```

---

## 🎯 Who Is This For?

This toolkit is designed for anyone wanting to maximize AI-powered development:

✅ **Vibecoders** - Non-coders building with AI  
✅ **Semi-technical users** - Some coding background, learning to leverage AI  
✅ **Technical non-coders** - Strong technical knowledge without coding experience  
✅ **Developers** - Wanting structured, proven AI workflows  
✅ **Teams** - Needing standardized AI collaboration patterns

**[Vibecoding 101 Guide](docs/vibecoding-101.md)** - Learn how to build software with AI without being a traditional coder.

---

## 📖 Documentation

- [Vibecoding 101](docs/vibecoding-101.md) - Beginner's guide to AI-powered development
- [Subagent Manual](ai/subagentic/subagentic-manual.md) - Complete agent reference with token loads
- [Tools Guide](tools/tools_guide.md) - Development tools documentation
- [Agent Guidelines](ai/customize/config/AGENT_RULES.md) - AI collaboration guardrails

---

## 🆘 Support & Community

### Getting Help
- ⭐ **[Star this repo](https://github.com/hamr0/agentic-toolkit)** for updates
- 💬 **[Join Discord](https://discord.gg/SDaSrH3J8d)** for vibecoding support
- 🐛 **[GitHub Issues](https://github.com/hamr0/agentic-toolkit/issues)** for bug reports
- 💡 **[GitHub Discussions](https://github.com/hamr0/agentic-toolkit/discussions)** for questions

---

## 🤝 Contributing

We welcome contributions! See **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** for guidelines.

### Quick Guide
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

**What to contribute**: Subagent improvements, tool scripts, documentation

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for the vibecoding community** | [LinkedIn](https://linkedin.com/in/hamr)

Ready to vibecode? Follow the Quick Start above!
