# Changelog

All notable changes to agentic-toolkit are recorded here. Format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versions are **retro-fitted** from commit history; dates are
ballpark, grouped by milestone rather than per-commit.

## [Unreleased]

### Changed
- **`/friction` collapsed into `/remember`; hot-memory pipeline is now two commands (`/stash → /remember`)** (mirrored from liteagents). `/remember` runs `friction.js` itself (best-effort) against the tool's global sessions root — resolved from an editable, never-prompt probe list baked into `remember.md` (Claude/Droid/Amp/opencode + Codex/Antigravity; add your own at the top) — then consolidates. A no-sessions miss is surfaced loudly, never silently skipped. `/stash` now nudges toward `/remember` at ≥5 unprocessed stashes (derived count, no counter file). Each package's `/remember` writes the memory into its own agent config (`CLAUDE.md` / `AGENTS.md` / `AGENT.md`). Standalone `/friction` command removed across all four tool dirs (the `friction.js` script stays). Counts, catalogs, `subagentic-manual.md`, `opencode.jsonc`, `docs/friction-README.md`, and README updated.

### Fixed
- **`friction.js` no longer crashes on a single malformed JSONL line** (mirrored from liteagents). The four tool copies under `ai/subagentic/*/.../friction/` parsed session logs and `friction_raw.jsonl` with bare `.map(line => JSON.parse(line))` — one corrupt line aborted the whole run. A new `parseJsonl(raw, source)` helper skips bad lines with a one-line stderr warning (line number + source) and keeps the good records; the whole-file `friction_analysis.json` read is now wrapped in try/catch (reports the file, exits 1).
- **`ai/subagentic/subagentic-manual.md` restored after a range-sed corruption inherited from the 1.6.0 mirror.** The corruption originated upstream in liteagents (a range-sed with end-pattern `test-generate$` matched far past its intended scope and overwrote ~310 lines with duplicates of the "Simple Commands" bullet) and rode along to this repo when the file was copied in commit `bda2c0c`. Restored from the cleaned liteagents version; all renames and count updates intact.

### Removed
- **`ai/customize/memcp/`** — the experimental MCP memory server (semantic-search persistent memory for Claude Code). Internal tooling, not published. Removal clears the open Dependabot alert for `uuid < 11.1.1` (the only direct/indirect dep using uuid in this repo). README references in the `ai/customize/` description and the `Structure` block updated.

## [1.6.0] — 2026-06-16

Subagentic command set consolidated and verify-then-fix loops baked into
the claim-shaped commands. Five 3-word skill slugs renamed to 2-word
slugs. `/review` renamed to `/diff-review` to avoid collision with the
Anthropic-official `code-review` plugin. Synced from `liteagents@2.9.0+`.

### Changed
- **`/review` → `/diff-review`** across all four tool packages
  (claude, droid, opencode, ampcode). Avoids the name collision with the
  Anthropic-official `code-review` plugin's `review` skill. The renamed
  command absorbed the old `/code-review` (which had been workflow
  ceremony for *requesting* reviews from a subagent) and now accepts a
  file, branch (e.g. `/diff-review main` diffs `merge-base(main, HEAD)..HEAD`),
  or explicit range (`main..HEAD`).
- **Claim-shaped commands now verify → fix → ask.** `/diff-review`,
  `/security`, `/optimize`, `/test-generate` all re-ground each cited
  `file:line` before acting, auto-fix only confirmed + unambiguous +
  no-contract-change findings, and stop to ask on uncertain claims,
  multi-shape fixes, downstream-affecting changes, security primitives,
  or "dead code" that may be intentionally kept. `/diff-review` ends
  with a **Ready to merge? Yes / No / With fixes** verdict.
- **`/refactor` now runs the tests after the edit** (lightweight pattern:
  the user's input is the claim; tests are the verifier). Detects the
  project's test command, runs it scoped to the affected area, reports
  pass/fail. On failure stops and asks (revert / patch / update test)
  rather than auto-reverting or pushing forward silently.
- **`/test-generate` rewritten as a generate-and-verify-it-bites loop.**
  Discovers existing framework (refuses to add a new runner), generates,
  **runs the new tests**, and marks each one **biting** or **superficial**
  by mentally swapping in a broken impl. Superficial tests (`expect(true).toBe(true)`,
  mock-asserting-itself, setup-masked passes) count as a failure to ship.
- **Skills renamed to short 2-word slugs.**
  `systematic-debugging` → `debug-method` (4-phase framework, with its
  4 pressure-test scenarios + creation log preserved).
  `root-cause-tracing` → `trace-back` (with its `find-polluter.sh`
  bisection helper preserved).
  `testing-anti-patterns` → `test-traps` (now includes timing/polling
  as Anti-Pattern 6 after the condition-based-waiting fold).
  `test-driven-development` → `tdd-flow`. `verification-before-completion` → `verify-done`.
  Resulting cluster reads scannably: `debug-method / trace-back / verify-done`
  and `tdd-flow / test-generate / test-traps`.
- **`condition-based-waiting` folded into `test-traps`** as Anti-Pattern 6:
  Timeout-Based Waiting. Promotes the timing/polling guidance to
  auto-trigger coverage (was previously manual-trigger only). Its
  `example.ts` helper (`waitForEvent` / `waitForEventCount` / `waitForEventMatch`)
  moves with it and is referenced from AP6.
- **`installer/cli.js` banner derives counts from `package.json.description`**
  — was hardcoded as `"11 agents + 23 commands per tool"` and drifted
  silently. Now parses `11 specialized agents and 18 commands`
  from the description, so the banner auto-tracks whenever the count
  changes. Fallback values prevent crash on regex miss.

### Removed
- **`/code-review`** (was workflow ceremony for *requesting* reviews;
  mostly overlapped `/diff-review`). Use `/diff-review` instead —
  `/diff-review main` for branch-vs-main, no args for staged/working-tree.
- **`/debug`** — was a thin echo of the `systematic-debugging` skill.
  The renamed skill (`debug-method`) carries the real workflow with its
  pressure-test scenarios.
- **`/explain`** — 11 lines of "explain this code" with no real
  constraints. The model does this naturally from a plain prompt.
- **`/git-commit`** — Claude Code has built-in commit handling; the
  other three tools don't need a thin wrapper either. Use natural-language
  prompts instead.

### Counts
- Claude: 9 skills + 9 commands (was 11 skills + 12 commands).
- Droid / Opencode / Ampcode: 18 commands per tool (was 23 commands).
- `package.json` description updated to reflect the new totals.

## [1.5.5] — 2026-06-16

### Changed
- **README simplified** (210 → 75 lines) to match the repo — AI
  subagent kits for four tools plus per-distro Linux dev-tool setup
  (`tools-debian`/`tools-fedora`). Dropped the marketing hero and the
  Documentation / Support & Community / Contributing / License sections
  (kept a one-line license note), and fixed dead links: the removed
  `tools/` paths, the deleted `CONTRIBUTING.md`, and the
  `vibecoding-101.md` filename typo.

## [1.5.0] — 2026-05-26

Friction memory pipeline redesigned; ships the previously-unreleased
`/security`, `/ship`, and `/git-commit` hardening; prunes stale docs.

### Added
- **`docs/friction-README.md`** — canonical guide to the stash →
  friction → remember (hot-memory) pipeline.

### Changed
- **`/friction` redesigned: antigens come from observed user
  reactions, not machine proxies** — clusters by what the user *said*
  (content/phrase overlap) instead of `(signal, tool_pattern)`;
  recurrence × severity drives the suggested artifact; only patterns
  recurring across 5+ sessions load into hot memory. Pasted SSH/shell
  output is no longer mistaken for friction, and profanity counts only
  when it's aimed at the agent. Applied across all four platforms.
- **`/remember` rewritten to consolidate from friction's short quotes,
  never raw logs** — classifies agent-vs-self, drops self-corrections,
  merges paraphrases, tiers antigens by recurrence, and surfaces
  `self_suspect` for confirmation. MEMORY section renamed
  `Preferences` → `Antigens`.
- **`/security` command hardened** across all four platforms
  (Claude, Opencode, Ampcode, Droid). Replaces the five generic
  categories with "the recurring six" — secrets in the repo,
  tenant isolation, rate limiting, error handling past the happy
  path, authorization beyond authentication (IDOR), and
  inefficient data access (N+1) — plus an expanded "also scan
  for" list (injection, trust boundaries, config, dependencies).
  Output is now coverage-auditable: it reports which classes were
  checked clean and which are N/A, not just the hits. Adds
  read-only git/rg tooling (`git log`, `git grep`, `rg`) to
  `allowed-tools`.
- **`/ship` command hardened** across all four platforms. Now
  detects the stack first (npm / pyproject / go.mod / Cargo /
  Makefile) and runs only checks that exist, reporting each as
  pass / fail / N/A. Adds security-relevant gates (ownership +
  role authorization, rate limiting, data-access scoping/scaling)
  and broadens `allowed-tools` across stacks (pnpm, yarn, pytest,
  python, go, cargo, make).
- **`/git-commit` (Claude) `allowed-tools` syntax fix** —
  `Bash(git *)` → `Bash(git:*)` to match Claude Code's matcher
  format.
- **README cleaned of emoji** — removed decorative emoji from
  headings, inline links, and list markers for a plain-text,
  professional presentation. Emoji bullet lists ("Who Is This
  For?", "Support & Community") converted to standard markdown
  bullets; "Built with ❤️" now reads "Built with love"; fixed the
  `#quick-start` anchor link that had depended on the heading emoji.

### Removed
- **Pruned nine stale planning/spec docs** from `docs/` (agent
  consolidation/cleanup plans, split summary, digraph notes,
  subagents-and-skills, verification-and-isolation pattern, FAQ,
  CONTRIBUTING) — superseded or merged into the README/guide.
- Dead scaffolding in `friction.js`: the unused `overlap()` helper,
  the `MIN_KW`/`MIN_INTER` constants, the unread `selfCount`
  (superseded by `anySelf`), and the empty `top_files` field with its
  unreachable renderer.

### Infrastructure
- Root `package.json` added (private; metadata only — this repo
  is multi-language, package.json is for the version badge and
  npm-style tooling integration).
- README badges (version + license, plato-style; #2a4f8c).

## [1.4.0] — 2026-05-18

`live-canvas` matures: simpler overlay, robust channel server,
JSON mode writes to disk. The live-canvas-channel MCP plugin (v0.5.0)
gains explicit lifecycle tools, a capability gate that prevents
silent feedback loss, and automatic takeover when a prior Claude
session is holding the port.

### Added
- **Channel server: lazy port binding via MCP tools** —
  `channel_open`, `channel_close`, and `batch_open`. Port 8788 is
  only bound when the skill explicitly calls one. Plain Claude
  sessions stay idle; multiple sessions can coexist with `/mcp`
  green without racing for the port.
- **Channel server: parent-flag capability gate** —
  `channel_open` inspects the parent `claude` process's command
  line and refuses to bind from sessions launched without
  `--dangerously-load-development-channels`. Before this, a plain
  `claude` could win the port and silently drop every notification
  (POST 200 but no `<channel>` tag) — the "nothing landed" black
  hole. Cross-platform: Linux `/proc/<ppid>/cmdline`, macOS/BSD
  `ps -p <ppid> -o args=`, Windows `wmic`.
- **Channel server: automatic sibling takeover** — when
  `channel_open` finds port 8788 held by another instance of the
  same plugin running as the same uid, it takes over (SIGTERM,
  rebind, SIGKILL fallback). The taken-over pid is returned as
  `took_over` so the skill can announce it. Foreign processes are
  still refused with `{status: "in_use", holder_pid}` — the plugin
  won't kill anything it doesn't own.
- **JSON mode writes to disk** — channel server gains a
  `POST /feedback-jsonl` route that appends submissions to
  `<project>/.claude-design/feedback.jsonl`. Skill calls
  `batch_open` (no flag gate) and sets the overlay's
  `batchEndpoint` accordingly. Falls back to the legacy browser
  download only when the MCP isn't running.
- **SKILL.md Case D — explicit relaunch instructions** — when
  the tool returns `no_channel_capability`, the skill prints the
  exact `live-claude` command instead of a generic "Live mode
  unavailable" error.
- **Lab banner template** — new `templates/lab-banner.html`
  ("temporary review surface") replaces the old per-mode banners.
  Mode-agnostic, paste-once.

### Changed
- **Vanilla overlay everywhere** — deleted the React-specific
  feedback components (~2300 lines). `overlay-vanilla.js` (one
  file, plain DOM, zero deps) now works in every supported
  framework, including React/Next.js/Vite via `<script>` +
  `useEffect`.
- **User-facing rename "Batch" → "JSON"** — the non-Live mode is
  called "JSON mode" everywhere user-facing.
- **Demo relocated to `dev/`** — `templates/demo/post-variants.html`
  was never copied during real runs. Moved to `dev/post-variants.html`
  at the skill root in each platform package.
- **Explicit mode pick** — skill asks Live vs JSON via
  `AskUserQuestion` every run instead of silently auto-detecting.
- **SKILL.md mode-selection: replaced `curl /health` probe with
  the `mcp__live-canvas__channel_open` tool call.** The tool's
  structured result (`opened` / `already_listening` / `in_use` /
  `no_channel_capability` / `took_over`) is authoritative.

### Fixed
- **Channel server shutdown race** — `server.close()` is async
  but `process.exit()` was synchronous; stale processes held port
  8788 indefinitely after the MCP host disconnected, breaking
  `/reload-plugins` and subsequent sessions. Now uses a `closing`
  guard and lets `server.close()` callback drive exit (500ms
  unref'd ceiling).
- **Overlay mode badge stale on re-expand** — collapsing and
  re-expanding the overlay showed the wrong mode name after a
  runtime live→batch fallback. Badge text now refreshes from
  `state.mode` on every re-expand.
- **`setup.sh` sudo guard** — bails when run with `sudo` instead
  of silently installing into `/root/.claude/plugins/`.
- **Silent channel black-hole when a plain `claude` won the port
  race** — fixed by the capability gate above; the failure mode
  can no longer occur.

### Removed
- React-specific feedback templates (`templates/feedback-react/`)
  in all platform packages.
- `INTEGRATION_NOTES.md` (draft notes superseded by README + SKILL).

## [1.3.0] — 2026-05-10

`live-canvas` skill lands across all four platforms — design UI
variations with click-to-annotate browser feedback. Claude Code
ships a companion `live-canvas-channel` MCP plugin that enables
live mode (each overlay Save streams into the session in real
time); other platforms run in batch mode only.

### Added
- `live-canvas` skill/command across Claude, Ampcode, Droid,
  Opencode (templates: vanilla overlay, React feedback components,
  demo variants).
- Claude Code: `live-canvas-channel` MCP plugin (marketplace +
  setup script) for live streaming feedback.
- `variants.json` across all platform packages.

### Changed
- Skills count: 10 → 11 (live-canvas).
- Droid/Opencode commands: 22 → 23 (live-canvas).
- `friction` command refreshed across all platforms.
- `subagentic-manual.md` and `README.md` updated to reflect new
  inventory + live-canvas channel plugin note.

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
