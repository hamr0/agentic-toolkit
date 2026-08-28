# Changelog

All notable changes to agentic-toolkit are recorded here. Format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versions are **retro-fitted** from commit history; dates are
ballpark, grouped by milestone rather than per-commit.

## [Unreleased]

## [1.17.0] — 2026-08-28

Mirrored from liteagents 2.19.0.

### Changed
- **`docs/index.md` rows now list each doc's H2 headings, one per line, with a line range,
  in all four kits.** Previously each row carried only an H1, a line count, and a link —
  now each H2 gets its own indented line with a `(Lstart–end)` range, reusing the same
  `headings()`/`fenceMask()` boundaries `scan` already writes to `outline.json`, so an
  agent can find and slice-read a section without opening the doc. `## Archive` rows stay
  H1-only — an archived doc is frozen history, not a live section to route into.
- **`/remember` step 7 self-heals `docs/index.md` every run, in all four kits.** Any drift
  `due` reports — new/moved/changed/deleted, not only the >=5-doc DUE threshold — now also
  re-runs `index-flat` (script only, no model call), so the index stays current between
  full `/docs-builder reorg` passes instead of waiting for one.
- **`AGENT_RULES.md` demoted from an `@`-include to a plain path pointer, in all four
  kits.** It was wired into the config file as an `@`-reference, which hot-loads the whole
  file into every session even though it is documented as "not hot context." `MEMORY.md`
  stays `@`-referenced (it is hot); `AGENT_RULES.md` is now a plain path line, read only
  when designing or building something new.

## [1.16.0] — 2026-08-27

### Added
- **Fedora setup guide: CPU turbo fix for tuned's `powersave` profile**
  (`tools-fedora/setup/FEDORA_SETUP.md`) — new Post-Install section documenting a
  performance cap that presents as browser/network trouble rather than a CPU problem.
  tuned's `powersave` profile sets `no_turbo=1` and pins `scaling_max_freq` to the base
  clock; on the i7-8665U that drops a 4800MHz turbo ceiling to 1900MHz with cores idling at
  400–800MHz, while temperatures stay ~44°C so it never looks like thermal throttling. The
  visible symptoms are stuttering video (Firefox's Data Decoder spiking to ~90% CPU), jerky
  image-heavy pages, and general sluggishness that survives every browser-side fix — found
  after ruling out DNS/ad-blocking, VA-API hardware decode, the AV1 codec, and disk. Fix is
  `sudo tuned-adm profile balanced`; measured result was 400–800MHz → ~3000MHz actual and
  1900 → 4800MHz ceiling. Section includes diagnosis and verification commands, a BIOS-level
  fallback when `no_turbo` stays `1`, rollback, and two false alarms called out explicitly
  (`scaling_governor` still reading `powersave` is `intel_pstate`'s normal default; the cap
  partly re-engages on battery). A matching CPU-throttle check was added to the guide's
  Troubleshooting block.
- **`ELI5` output style** (`ai/customize/config/ELI5.md`) — a Claude Code output style that asks for plain, minimal answers (small words, short sentences, at most two options when a decision is needed, exact paths/commands preserved).
- **`STE100` output style** (`ai/customize/config/STE100.md`) — a Claude Code output style based on ASD-STE100 Simplified Technical English: short sentences, one instruction each, active voice, common words, condition-first phrasing, exact paths/commands.

## [1.15.0] — 2026-08-26

Mirrored from liteagents 2.18.0.

### Changed
- **`/remember`'s antigen step redesigned to classify-then-count, in all four kits.** The
  LLM now makes one classification judgment per cluster (`drop` | existing `ag-NNN` |
  `new:<theme>` with a classifier-authored one-line rule) — everything else (hash union,
  dedup, promotion, rendering, checking) moved into deterministic code
  (`friction.cjs count`/`render`/`check`/`migrate-attempts`). Root cause: a 15-repo audit
  found MEMORY.md's Antigens section hand-drifted from the ledger in 14/15 repos, from the
  model writing the same rule text in three places and doing hash/dedup arithmetic in prose.
  New invariants I6-new (render(ledger) byte-equal to MEMORY.md's Antigens section) and I7
  (`rule` == `attempts[last].rule`), plus an adopted-date gate so pre-fix evidence can't count
  toward `recurred_while_hot`. `remember.md` rewritten as literal commands to run, not prose
  to interpret.

### Fixed
- **`friction.cjs check` exited 0 when I6-new was NOT EQUAL** — only I7 could fail it, so an
  automated caller saw a pass while MEMORY.md was hand-drifted from the ledger. Now exits 1 on
  either invariant failing.
- **`observing`→`hot` promotion wrote no history line and left `attempts[last].adopted` at
  the candidate date**, so a conversation from before the rule went hot could wrongly count
  toward `recurred_while_hot` on the next run. Promotion now appends
  `promoted to hot (N sessions)` and re-stamps `adopted` to the run date.
- **`/remember` could append near-duplicate episodes when re-processing already-filed
  stashes.** Step 4b's episode rule now dedups before appending — merge into the existing
  entry (by content, not title) instead of adding a second copy.
- **A newly-created antigen entry's `rule` text was a literal placeholder string, not real
  content.** The 4a classifier now emits the one-line rule alongside a `new:<theme>` label in
  the same judgment; a `new:` cluster with `sessions >= 2` and no rule is reported as
  malformed and creates nothing — never falls back to placeholder text.
- **friction's severity axis was degenerate — every cluster it ever emitted was severe.**
  Clusters are seeded only on an observed reaction, and the severe test accepted the same
  signals used to seed the cluster in the first place. Measured 69/69 severe on a real
  3170-session corpus. Severe now means intensity (a curse, an interrupt cascade, or a tool
  error corroborating the reaction); a plain correction is mild.
- **docs-builder: the config pointer search line and the JSON state directory drifted across
  repos.** `CLAUDE.md`'s docs pointer now uses the same search line as `docs/index.md` itself
  (was pointing at a stale `docs/README.md` reference); `docs/.docs-builder/` — regenerated,
  per-clone machine state — is now gitignored on first run rather than landing in history by
  accident of whichever repo ran `apply-reorg` first.
- **24 more docs-builder/`/remember` spec-vs-script defects**, from an audit of both specs
  against their scripts: `docs/.docs-builder/*` state resolved against the cwd while
  `index.md`/ledger/config resolved against the repo root, splitting state when run from
  anywhere but the root (now both resolve under the repo root at one chokepoint); a picker
  flow that never stamped the ledger, so `due` said NOT due forever; friction falling through
  to extract on the previous run's stale analysis when a scan found no sessions, clobbering
  `antigen_clusters.json` (now a distinct exit code, no fallthrough); plus assorted stale
  cross-references and wording. `/docs-builder` also could not find its own script when run
  outside this repo — it now locates itself relative to its own command directory, the same
  fix `/remember` already had for `friction.cjs`.

## [1.14.0] — 2026-08-25

Mirrored from liteagents 2.17.1.

### Added
- **docs-builder v3 in all four kits** — `discover` now *proposes* a bucket per file
  (`product` / `logs` / `archive`, with `oversized` a separate boolean flag, not a bucket)
  and stops; a classification interview fills in `bucket`, and only then does `apply-reorg`
  move anything. The risk was never the model's judgement, it was a silent move — so the gate
  is the fix. `reconcile`, `due` and `archive-cleanup` folded into the `reorg` front door.
- **`cleanup <file>` — splitting is opt-in and per-file.** It measures, prints the cost, and
  stops for an interview; `cleanup-apply` runs only once `labels.json` exists with exactly one
  `core:true` theme. The core page keeps the original basename and returns to the original
  document's own directory; the original is archived byte-identical, never edited.
- **`search`** — zero-dependency BM25 over the corpus. Measured against reading the split
  corpus whole: a tie (~73K tokens either way), so splitting is justified by recall, not cost.

### Fixed
- **Four move-chokepoint bugs**, each reproduced against the shipped script before being
  fixed: a plan row containing `../` could move — and **delete** — a file from outside the
  repo via the copy+unlink fallback; `archive README.md` archived the README because
  `PROTECTED_NAMES` was enforced at two call sites but not at the chokepoint; `cleanup-apply`
  died mid-split because `archive()` called `process.exit(2)` on a follow-up failure while
  running in-process; and a symlink under `docs/` pointing outside the repo passed the new
  path-confinement check, because `path.resolve()` does not dereference. All four now guarded
  in `doArchive`.
- **One index** — `index-flat` is the sole writer of `docs/index.md`; the themed per-split
  index was removed after it silently overwrote a 37-row corpus map with its own 7 rows.
- **`/remember`: one conversation counts once.** A fork or resume writes the same conversation
  to several session files and the ledger was counting files. Sessions are now unioned on
  shared message uuids (`sessions` authoritative, `session_ids` evidence), and the ledger
  seeds a new entry only at `sessions >= 2`.

- **`AGENT_RULES.md`'s TOC linked a nonexistent anchor** in the droid, opencode and ampcode
  kits: entry 9 pointed at `#claudemd-stub` while the heading it names is `## AGENTS.md Stub`
  / `## AGENT.md Stub`. This tree happened to carry the correct anchor and the *wrong*
  settings path (`.claude/settings.json` in droid's rules) — each side right about a
  different line. Fixed upstream first, then propagated, so both are correct here now.

### Changed
- `docs/docs-builder-README.md` and `docs/remember-README.md` refreshed from upstream — the
  copies here still described v2 ("eleven subcommands", dated 2026-08-21).
- All four subagent kits are now byte-identical to liteagents 2.17.1 (`node_modules` and
  `variants.json` excluded) — the whole tree was diffed, not just the ported feature.

## [1.13.0] — 2026-08-22

Mirrored from liteagents 2.16.0.

### Added
- **docs-builder v2** in all four subagent kits — a bundled `docs-builder.cjs` (vanilla Node,
  zero deps, eleven subcommands) that does every mechanical step, so the model is used only
  for proposing themes and writing pages. Includes **Mode 0 reorg** (`discover` /
  `apply-reorg`) to classify a whole corpus, plus `search`, `lint`, `ledger`, and `due`.
  The script is byte-identical across claude / droid / opencode / ampcode.
- **Bare `/docs-builder` asks instead of guessing** — three options via `AskUserQuestion`:
  First run, Docs drift, Clean archive. An argument skips the question. "First run" carries
  two stops: one guarding correctness (review the classification before anything is
  `git mv`'d), one guarding cost (see the oversized list and its price before any split).
- `/remember` step 7: a detect-only, crash-isolated docs reconcile check.
- `docs/docs-builder-README.md`, linked from the README.

### Changed
- **docs-builder moved from a Claude skill to a Claude command.** Claude is now 11 subagents
  + **8 skills + 10 commands** (was 9 + 9); the other three kits stay at 18 commands. A
  same-named skill and command would collide, so `claude/skills/docs-builder/` was removed.
- `package.json` description: 17 -> 18 commands per tool.

### Fixed
- **`friction.js` -> `friction.cjs` in all four kits.** A `.js` file cannot be `require()`d
  in any project whose `package.json` declares `"type": "module"` — it throws before the
  first line runs. This kit ships into arbitrary target repos, so the extension is a
  portability requirement, not a style choice.
- **Reorg could move files it promised never to move.** The never-move list existed only as
  prose; the code protected three names at the top level of `docs/` and recursed into
  dot-dirs and `node_modules/`. Now enforced by `PROTECTED_NAMES` at any depth, with a
  dot-dir / `node_modules` skip.
- **`REPO`-vs-cwd path split, 8 sites.** Run from outside the repo, the archive key-sync
  silently no-opped, the citations gate LOUD-SKIPped so `validate` returned PASS on bad
  citations, failure state split across two directories, and `apply-reorg` died right after
  a successful `discover`.
- **`/docs-builder` did not load on opencode at all** — `opencode.jsonc` pointed at a
  `SKILL.md` that never existed in that kit. Also dropped a stale `subagent-spawning` entry.
- Missing `argument-hint:` frontmatter (no parameter hint rendered) and `allowed-tools:`.
- `logOp` ENOENT, `bm25Rank` crash on a missing source file, `search` result-count clamping.

### Removed
- **Guardrails section from `AGENT_RULES.md`.** It documented a Claude-Code-only `PreToolUse`
  hook and pointed at a `guardrails.py` that does not ship in either repo — unusable guidance
  in three of the four kits. The Always / Ask / Never rules it justified remain as binding
  prose, with a pointer to mirror them into whatever allow/ask/deny list a tool provides.
- Stale v1 `docs-builder/templates.md` from the three non-Claude kits.
- **`ai/customize/config/guardrails.py`** and the Guardrails section in
  `ai/customize/config/AGENT_RULES.md` (a second, standalone copy that the subagentic sync
  did not cover). The script was never tracked in git here — nor in liteagents — so
  `AGENT_RULES.md`'s claim that the reference implementation "ships in this repo" was false
  in both places. Generic uses of the word *guardrails* elsewhere (the model-tier heading in
  `stash.md`/`remember.md`, the HR subagent, the vibecoding guide) are unrelated and were
  left alone.

### Documentation
- `subagentic-manual.md` claimed Ampcode ships a `skills/` directory (it does not) and
  under-counted Droid/OpenCode at 17 commands. All four kits ship 11 subagents; only Claude
  splits capabilities into skills + commands.
- `AGENT_RULES.md` footer pointed at `.claude/memory/AGENT_RULES.md`, a directory renamed to
  `remember/`; the three non-Claude copies also pointed at Claude's path.
- Per-tool config filename swept through the non-Claude kits: `CLAUDE.md` -> `AGENT.md`
  (ampcode) / `AGENTS.md` (droid, opencode).

---

## [1.12.1] — 2026-08-07

Repo-hygiene and tooling housekeeping — no functional changes.

### Changed

- **Statusline context indicator switched from an ASCII bar to a colored percentage.** `ai/customize/config/statusline-command.sh` replaced the 20-char `[==== ]` context-usage bar with a compact ` | NN%` readout that colors by pressure — green `<25%`, orange `<35%`, red otherwise. Synced from the live `~/.claude/statusline-command.sh`.
- **Agent/IDE scratch gitignored and de-tracked.** `.gitignore` now default-denies every dot-directory (`.*/`), re-admitting only what ships (`.github/`). Per-machine agent/IDE state (`.claude/`, `.litectx/`, `.idea/`, …) regenerates locally and only added noise and churn; any already-committed copies are removed from tracking (local files kept on disk). Repo hygiene only.
- **`node_modules/` gitignored.** No rule existed, unlike liteagents; a stray `node_modules/` under the bundled live-canvas-channel plugin showed as untracked noise. Nothing was previously tracked, so no de-tracking was needed.

## [1.12.0] — 2026-08-04

Dependency security fixes mirrored from `liteagents@2.15.3`.

### Security
- Merges Dependabot #14/#13: hono 4.13.0 (closes residual moderate ReDoS,
  GHSA-8j4g-w8fx-2239), ip-address 10.4.0 (3 high SSRF/trust-boundary
  advisories). Also applies `npm audit fix` for fast-uri 3.1.5 (high,
  GHSA-7p8r-x3mc-p8w7) — not yet proposed as a separate Dependabot PR.
  Transitive deps of the bundled live-canvas-channel plugin's MCP SDK.
  Plugin audit: 3 → 0 vulnerabilities.

## [1.11.0] — 2026-07-13

Hot-memory pipeline change mirrored from `liteagents@2.15.0`.

### Changed
- **`/stash` delegates the write-up to a mid-tier-model subagent** (mirror from liteagents).
  The session drafts the raw content inline (only it holds conversation context), then hands
  off to a mid-tier-model subagent to expand and write the formatted stash file — dispatched
  in the background where the tool supports it, falling back to writing inline otherwise.
  Applied identically across all four packages.
- **`subagentic-manual.md`** documents the new mechanism in its Hot Memory section.

## [1.10.0] — 2026-07-10

Hot-memory pipeline changes mirrored from `liteagents@2.14.0` and `liteagents@2.14.1`.

### Added
- **`/remember` bootstraps a standards-guide template** (mirror from liteagents). A new
  `AGENT_RULES.md` (an AI agent collaboration/coding-standards guide) ships bundled next to
  `friction.js` in all four packages. On first `/remember` run in a project, if
  `<tool-dir>/remember/AGENT_RULES.md` doesn't already exist, it's copied from the bundled
  template — never overwritten again after that, so local edits persist. When present, it's
  injected into the agent config via its own independent marker pair
  (`<!-- AGENT_RULES:START/END -->`), separate from the MEMORY.md block and framed as a
  guide to consult when building something new — not hot context loaded every session.

### Changed
- **`/remember` extraction is parallel and model-agnostic** (mirror from liteagents). Step
  2's per-stash extraction calls are now spawned as concurrent subagent calls instead of one
  at a time. Every hardcoded `sonnet` mention (steps 2, 3, 4a) is replaced with "the mid-tier
  model" — a new Guardrails note explains the intent (capable of semantic judgment,
  cheaper/faster than the top reasoning tier; Sonnet is the Claude example, not a
  requirement) so the instructions work unmodified across Claude/opencode/ampcode/droid
  regardless of which models each tool has configured.
- **`subagentic-manual.md`** documents both changes in its Hot Memory section.

## [1.9.0] — 2026-07-08

Hot-memory pipeline changes mirrored from `liteagents@2.13.0` (plus the
2.12.x-era mirrors that were sitting in Unreleased).

### Added
- **Antigen ledger (`/remember` step 4c)** (mirror from liteagents). Every behavioral rule now carries an evidence trail in `<tool-dir>/remember/ledger.json`: which mistake-class it targets (`class_hints` dedup key), the evidence that promoted it, and every phrasing ever tried (`attempts` — failed attempts are the rejected-edit buffer, never re-proposed). A class that fires again *while its rule is loaded* increments `recurred_while_hot`: at 2 the phrasing is marked failed and rephrased; after 2 failed phrasings the antigen is **ESCALATED** — removed from hot, recorded as a Fact, flagged for a human decision. Failure detection without statistics; instructions-only (no new code), identical across all four packages.
- **`/remember` writes its run report** to `<tool-dir>/remember/report.md` (latest snapshot, overwritten each run).

### Changed
- **Pipeline consolidated to two dirs, each owned by its command** (mirror from liteagents): `<tool-dir>/stash/` (`/stash`) and `<tool-dir>/remember/` (MEMORY.md, ledger.json, report.md, `.processed`, transient `friction/` output). Was three (`stash/`, `friction/`, `memory/`). `/remember` performs a one-time loud migration: pipeline files move, user-owned files in the old `memory/` stay put, stale friction output is discarded (always regenerated fresh).
- **Claude's bundled dir joins the naming convention:** `claude/commands/friction/friction.js` → `claude/commands/remember/friction.js` — a command's helper dir is now named after the owning command in all four packages (the other three were renamed earlier, still in Unreleased below).
- **`context-builder` reads/injects `<tool-dir>/remember/MEMORY.md`** (was `.../memory/MEMORY.md`) across all four packages; `/stash`'s consolidation-nudge backlog count reads `.../remember/.processed`; `subagentic-manual.md` path references updated.
- **Friction cluster ranking breaks equal-recurrence ties by intensity** (mirror from liteagents). Antigen/episode clusters were ordered by tier then recurrence, with equal-recurrence ties left to incidental order — so a mild reaction could outrank a far more intense one that recurred equally. Added a final tiebreak on median peak friction (already computed): the more intense reaction ranks first. Ranking-only — never promotes across the severity × recurrence 2×2 (a loud one-off stays an episode). Applied across all four tool packages (claude, droid, opencode, ampcode).
- **docs: `friction-README.md` → `remember-README.md`** (mirror from liteagents) — refreshed for the two-dir layout + ledger; README pointer updated.

### Fixed
- **Non-Claude helper dir renamed `friction/` → `remember/`** (opencode, ampcode, droid). These tools expect a command's bundled directory to share the command's name; `friction.js` is run by `/remember`, so it now lives in `remember/friction.js` (was the mismatched `friction/`). remember.md's bundle-path reference updated to match.

## [1.8.0] — 2026-07-03

### Added
- **`/release` command across all four tool packages** (claude, droid, opencode, ampcode). An end-to-end feature-delivery *orchestrator* that does not re-implement checks — it runs the existing gates (`/ship`, `/security`, `/diff-review`) under `/verify-done` discipline, then performs the release actions. Split by a hard gate: everything before is safe/read-only (preflight branch resolution, verify with fresh evidence + coverage table); everything after rewrites history and is confirmed step by step (docs update, semver bump, commit, push, PR, merge, tag). Publish stays manual (`workflow_dispatch` by design). Usage: `/release [branch]` — requires a feature branch, never releases `main`. Registered in `opencode.jsonc`; catalogs in each `AGENT(S)/CLAUDE.md` and `subagentic-manual.md` bumped (Claude/Amp 8→9 commands, Droid/OpenCode 17→18).
- **`live-canvas` recategorized on Amp** from a command to a subagent in `ampcode/AGENT.md` (batch mode only on Amp).

### Changed
- `.litectx/` (local litectx index DB) added to `.gitignore`.

## [1.7.0] — 2026-06-16

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
