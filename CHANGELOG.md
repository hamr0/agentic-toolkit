# Changelog

All notable changes to agentic-toolkit are recorded here. Format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versions are **retro-fitted** from commit history; dates are
ballpark, grouped by milestone rather than per-commit.

## [Unreleased]

### Infrastructure
- Root `package.json` added (private; metadata only — this repo
  is multi-language, package.json is for the version badge and
  npm-style tooling integration).
- README badges (version + license, plato-style; #2a4f8c).

## [1.2.0] — 2026-02-13

Documentation hardening pass: tone moved from "preferences" to
"standards"; testing strategy rewritten with battle-tested best
practices; development philosophy (POC-first, vanilla-first,
lightweight) added; tech-stack tables collapsed to a minimal
environment section; agent rules restructured for coherence with
a `CLAUDE.md` stub.

### Changed
- Agent rules restructured: coherence pass + `CLAUDE.md` stub.
- Testing strategy rewritten with battle-tested best practices.
- Tone hardened from preferences to standards.
- Tech stack tables → minimal environment section.

### Added
- Development philosophy doc: POC-first, vanilla-first,
  lightweight.

### Removed
- Replit references from dev-workflow docs.
- AI tools section from README; Radix UI moved to correct table.

## [1.1.0] — 2026-01-24

Post-1.0 polish: `liteagents` extracted to its own repo; `stash`
command added across all platforms; Kitty terminal installer +
config; minor frontmatter and provider-rename refinements.

### Added
- `stash` command across all platforms (Claude / Opencode /
  Ampcode / Droid).
- Kitty terminal installer script + working config + menu
  integration.
- npm global install documented as recommended installation
  method.

### Changed
- Subagentic frontmatter: `id` → `name`; `title` removed from
  agent frontmatter (continuation of 1.0's auto-discovery).
- Removed Superpowers / BMAD references; cleaned obsolete hooks
  and stale README files from the Claude package.
- Skill count corrected: 21 → 20 after subagent-spawning skill
  removed.

### Extracted
- **`liteagents`** — extracted to its own repo (`hamr0/liteagents`)
  after the rename. agentic-toolkit and liteagents now sit
  alongside each other rather than nested.

## [1.0.0] — 2026-01-18

**Stable cut.** Agent consolidation 15 → 14 → 11; skills
consolidation 22 → 11; commands stable at 10. Phase 9 manifest
update finalizes the inventory. Frontmatter-based auto-discovery
replaces central manifests so agents/skills/commands self-register
from their own metadata.

### Changed
- Agents: 15 → 11. Each renamed; digraph flow definitions added.
- Skills: 22 → 11. Removed 13 non-core skills.
- Commands: 10 essential slash commands (debug, explain,
  git-commit, optimize, refactor, review, security, ship,
  stash, test-generate).
- Subagentic architecture: frontmatter-based auto-discovery.

### Added
- Phase 9 manifest files: skills/commands inventory.
- Standardized command/skill descriptions with argument hints.

### Removed
- Task-template references from all `subagentic-manual.md` files.

## [0.9.0] — 2026-01-17

**Phases 6-8.** Self-verification, task-type detection, and TDD
auto-trigger. Verification stops being optional — every
non-trivial task triggers it.

### Added
- Self-verification gate (Phase 6).
- Task-type detection (Phase 7).
- TDD auto-trigger (Phase 8).

## [0.8.0] — 2026-01-17

**Phases 2-5.** Subagent isolation, TDD hints, document
verification. Synced across all platforms.

### Added
- Subagent isolation (Phase 2).
- TDD hints (Phase 3).
- Document verification (Phases 4-5).
- Per-package sync across Claude / Opencode / Ampcode / Droid.

## [0.7.0] — 2026-01-17

**Phase 1: Universal Verification Gate.** Every agent runs through
a verification step before completing tasks.

### Added
- Universal verification gate.

## [0.6.0] — 2026-01-17

**Phase 0 cleanup.** Removed 13 non-core skills + commands from
disk; cleaned references; renamed all agents and added digraph
flow definitions; added the essential slash-command set.

### Removed
- 13 non-core skills + commands.
- Stale resources and references.

### Changed
- All agents renamed; digraph flows added to each.

### Added
- Essential slash commands (initial set).

## [0.5.0] — 2025-Q4

Droid CLI support lands. 90+ droids configured for Droid CLI BYOK
(bring-your-own-keys); custom-model config + README updates.
Marketplace skills + plugins reorganized; BMAD references cleaned;
npm package configuration completed (Task 1.0). Subagents directory
structure simplified.

### Added
- Droid CLI subagents package (`subagents/droid/`).
- 90+ droid agents + custom-model config (BYOK).
- Marketplace skills + plugins.
- "Awesome Claude tools" section + Droid + Synthetic references.
- Amp commands + skills documentation.
- npm package configuration (Task 1.0).

### Changed
- Subagents directory structure simplified.
- BMAD references cleaned up.
- Resources path fixed for `opencode.jsonc`.
- AGENTS.md updated with command set.

## [0.4.0] — 2025-10-28

Provider rename + bloat reduction + docs scaffolding. Subagents
moved to provider-named directories (`claude/`, `opencode/`,
`ampcode/`); ampcode kit reduced from ~113MB to ~80KB; AGENT_RULES
relocated under `ai/`. Documentation: CONTRIBUTING, FAQ, vibecoding-101
placeholder, awesome-llm-skills link.

### Changed
- Subagent layout: `ai/subagents/{claude,opencode,ampcode}/`.
- AGENT_RULES → `ai/AGENT_RULES.md`.
- Ampcode kit: 113MB → 80KB.
- README: equal treatment of all 3 kits; merge conflicts resolved;
  consistent naming.

### Added
- `docs/CONTRIBUTING.md`.
- `docs/FAQ.md`.
- `docs/vibecoding-101.md` placeholder.
- Awesome LLM skills reference link.

## [0.3.0] — 2025-10-28

Subagentic manual + multi-provider scaffolding. Templates and
agent files optimized for cross-provider use; Ampcode kit added
alongside Claude / Opencode.

### Added
- `subagentic-manual.md` (cross-provider integration guide).
- Ampcode subagents kit.

### Changed
- Path harmonization across providers.
- Templates and agent files optimized.

## [0.2.0] — 2025-10-28

Initial cleanup of the migrated repo. Multi-provider scaffolding
(Claude + Opencode), README rewrites, path normalization.

### Changed
- Path normalization across Claude/Opencode kits.
- README rewritten for the agentic-toolkit shape.

## [0.1.0] — 2025-10-26

Initial migration from forked `agent-dev-suite` repo. Restructured
into the agentic-toolkit shape; README + initial docs in place.

### Added
- Initial subagents structure migrated from `agent-dev-suite`.
- Initial README + docs.
