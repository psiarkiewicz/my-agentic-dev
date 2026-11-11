This file provides guidance to Claude Code (claude.ai/code) and other coding agents when working with code in this repository. (`CLAUDE.md` in this repo is a symlink to this file.)

Keep this file current: when a statement here stops being true (project status, commands, conventions), fix it in the same change.

## Project Overview & Documents

**Documents, in reading order:**
- `GLOSSARY.md` — what the project is, why it is shaped this way, and the domain vocabulary and invariants that drive the design. Read it first.
- The specification, if the project has one — the authoritative source for rules, data models and test vectors. Its test vectors are the correctness bar: follow the rules it specifies rather than inferring them.
- `ARCHITECTURE.md` — living architectural summary, module/component hierarchy, state flow, data storage, and Mermaid diagrams. Updated after every ticket.
- `COMPREHENSIVE_QA_FLOW.md` — living end-to-end user verification guide covering all implemented features. Updated after every ticket.
- `USER_GUIDE.md` — living user-facing guide and manual, synchronized with any in-app documentation view (`<docs-view>`). Updated after every ticket touching UI, workflows, navigation, or domain rules.
- `DESIGN.md` (and `PRODUCT.md`, if present) — the visual design contract: design tokens, typography, components and the Stitch project it is synced with, plus the product context behind them. Read them before any UI or styling work.
- `docs/adr/` — Architecture Decision Records capturing key technical decisions.

<!-- When bootstrapping a repository, add these project-specific sections below:
     - Project status and commands: dev server, a `dev:agent` script that binds an OS-assigned port (e.g. `vite --port 0`) so parallel agents never collide, test runner, single-test invocation, lint and typecheck, and the script that regenerates generated docs (e.g. `docs:generate`).
     - Stack: one line naming the language, UI layer, state store, build tool, styling, persistence and test runner (with its DOM stand-in), and where the build output can be hosted.
     - Test fixtures: where the shared test helpers live (e.g. a `mountView()` fixture for component mount tests) and which section of `ARCHITECTURE.md` explains them.
     - What the app is, and its governing principle: the one idea that settles most design questions, with a "Do not build / Build instead" table.
     - Invariants that erode quietly during implementation, each with its reason (e.g. "every displayed value is editable", "derived values are computed on read, never stored", "every advertised keyboard shortcut and pointer interaction works end-to-end across real focus and transition states").
     - Core architecture: the seams (pure core, strategy interfaces) and the rule for where variation may live (e.g. "never branch on a variant id outside its strategy module").
     - Build order, when some layers must be hardened before others.
     - Design (UI projects): create `DESIGN.md` at the repo root and a Stitch project for the app, and record the project ID in `DESIGN.md` (see UI Design with Stitch).
     - Entries for the Known traps section below.
     Then run `/setup-matt-pocock-skills` to write `docs/agents/`: fold its Issue tracker and Triage labels lines into the `## Issue Tracker` section above (do not add `### Issue tracker` or `### Triage labels` under `## Agent Skills & Repository Conventions`), keep only the repo's tracker column in that table, and narrow `### Domain docs` below to the chosen layout. -->

## Living Architecture, User Guide & QA Documentation

Maintain **`ARCHITECTURE.md`**, **`COMPREHENSIVE_QA_FLOW.md`**, and **`USER_GUIDE.md`** at the repo root:
- **`ARCHITECTURE.md`** documents how the system actually works: module boundaries, component hierarchy, state flow, and data storage, accompanied by Mermaid diagrams.
- **`COMPREHENSIVE_QA_FLOW.md`** documents reproducible end-to-end user test flows across the application.
- **`USER_GUIDE.md`** (and any single-source in-app documentation module such as `src/docs/userGuideContent.ts`) documents how end users navigate and operate the application.
- **Mandatory agent requirement**: After completing every ticket (once per batch in Batch Mode), the agent **must update `ARCHITECTURE.md`, `COMPREHENSIVE_QA_FLOW.md`, and `USER_GUIDE.md`** to reflect newly added or modified components, stores, schemas, algorithms, and user-facing workflows.

## Issue Tracker

Tickets live in the repo's issue tracker: `docs/agents/issue-tracker.md` names it and gives its commands, and `docs/agents/triage-labels.md` maps the triage labels (by default `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). The workflow is the same on every tracker; only the artifacts differ. The sections below name tracker work with these terms:

| Term | Local markdown (`.scratch/<feature-slug>/`) | GitHub Issues |
|---|---|---|
| **Read** a ticket | `issues/<NN>-<slug>.md` | the issue body and its comments |
| **Comment** on a ticket | a note under the file's `## Comments` heading | an issue comment |
| **Resolve** a ticket | tick each completed subtask (`- [x]`), set `Status: resolved`, and commit the file with the ticket's change | tick each completed subtask in the issue body, and end the ticket's commit message with `Closes #<NN>`; the issue closes when that commit reaches `main` |
| A ticket's **batch** | a `Batch:` line naming the batch branch | a milestone named after the batch branch |
| A **plan**: one review's deepening candidates | a new `architecture-refactor-plan-<N>.md`, numbered one above the highest existing plan | a new issue labelled `architecture-plan` |
| The **roadmap**: the plan that sequences tickets into batches | a plan file (or `map.md`) with a Batches table and a *Batch Log* section | an `architecture-plan` (or `wayfinder:map`) issue holding the Batches table in its body and the *Batch Log* as comments |

On any other tracker, map each term in `docs/agents/issue-tracker.md`.

## Branch & Worktree Workflow for Tickets

Every ticket (or batch of tickets, see Batch Mode) must be implemented on an isolated branch or git worktree, never directly on `main`:
1. **Branch / Worktree per Ticket**:
   - Before starting work on a ticket, create a dedicated feature branch or git worktree branched from latest `main`:
     - Branch: `git checkout -b ticket-<NN>-<slug>`
     - Worktree: `git worktree add .worktrees/ticket-<NN> -b ticket-<NN>-<slug>`
2. **Development & verification on the branch**: **Read** the ticket for its scope and acceptance criteria, then do all implementation, tests and documentation updates on the branch, and run the complete Testing Gauntlet & Pre-Submit Verification there.
3. **Commit and hand off (Post-Implementation Gate — Hard Stop)**: commit everything gauntlet step 8 lists on the ticket branch, present the hand-off, and **STOP**. **DO NOT merge into `main`**: the branch stays unmerged until the user has tested it.
4. **Integration & Cleanup (User Directive Only)**:
   - Only merge or rebase onto `main` when the user has completed testing and explicitly requested the merge.
   - Clean up the worktree or delete the feature branch after merging.

## Testing Gauntlet & Pre-Submit Verification

**"Works" means "works when a human user tries it."** Every implementing agent (including ticket subagents) must self-test its features through the same controls, focus transitions, and real-time animation/loading states a human uses — never equating "internal store/API calls pass unit tests" with "the feature works". Before any ticket is marked complete or committed, the pre-submit verification gauntlet must pass completely (in Batch Mode, follow its per-ticket / per-batch split instead):
1. **Static Analysis, Typechecking & Linting**:
   - Run strict typechecking (e.g. `pnpm tsc --noEmit`) — zero errors.
   - Run the linter (e.g. `pnpm lint`) — zero errors and zero warnings.
2. **Full Regression Test Suite & Build**:
   - Run the full automated test suite (e.g. `pnpm test:run`), not just a single test file — all tests must pass.
   - Run the production build (e.g. `pnpm build`) to verify clean bundling and asset generation.
   - Tests assert behaviour through each module's interface: function results, rendered DOM under a DOM stand-in (e.g. happy-dom), store state. UI and input tests must exercise both pointer and `KeyboardEvent` paths across real focus states (focus on buttons, checkboxes/switches, `<select>`, text fields, and open drawers/dialogs), modifier chords (`Ctrl`/`Meta`/`Alt`, key-repeat), and active transitions/animations — not just programmatic store or action calls. Style and design-token rules live in the linter, because tests that grep production source text pin implementation and block refactors. Generated files (e.g. `USER_GUIDE.md`) come from an explicit script; tests compare them and leave the working tree untouched.
   - **Enter through the top boundary**: every user-visible feature needs at least one test that enters through real UI input (pointer/keyboard event → input controller → store/session → presenter/async queue → rendered DOM), because pure-function or store-dispatch tests stay green when presenters, bindings, or storage wrappers are unwired.
   - **Property-test explained derived values**: when the UI shows a derived value alongside its breakdown reasons (totals, modifiers, pricing, stat deltas), assert across varied states that `base + sum(contributions) === effective` and that every contribution resolves to a human label.
   - **Identity, fixtures, and user-facing copy**: never key persistent identity, visual variants, or UI status off array indices or human display names. Multi-item test fixtures must include at least 2 instances of the same type/name so display-name keying fails immediately. Add a catalog-completeness test asserting every data ID resolves to human copy with no raw `snake_case`, vague range words, or internal spec markers (`§`, `[R-…]`, `TV-…`).
   - **Shortcut parity and rapid-click fallback**: derive or test every rendered `[Key]` badge against the bindings source, assert no two actions active in the same mode share a key, and fall back `doubleTap` to `tap` when no double-tap action is bound so rapid clicks never drop inputs.
   - **Paid or side-effecting CLIs**: in `--dry-run` tests, inject a provider that throws on any network/API call; for long or paid batch jobs, checkpoint each item to disk (manifest + `.jsonl` log) so interrupted runs resume without repeating work.
   - **Typecheck tests immediately**: construct test states via shared typed fixture builders rather than hand-rolled object literals, and run `tsc --noEmit` plus the changed test file immediately after editing tests.
3. **Live Browser Verification via `chrome-devtools` MCP** (always run at least a dev-console smoke check once `index.html` exists; run full interaction and visual checks for all tickets touching UI, components, styles, input, client state, or persistence):
   - Start an isolated dev server on an OS-assigned port (the `dev:agent` script) as a background task, and read the bound `http://localhost:<port>/` URL from its output.
   - Open a dedicated tab (`new_page`, or `navigate_page` with an explicit `pageId`) at that URL.
   - Inspect `list_console_messages` and `list_network_requests` to check the dev console for errors and warnings (unhandled exceptions, console errors, console warnings, runtime registration failures, or failed network requests such as 404s) and fix anything that isn't expected.
   - **Self-test as a human user via real pointer and keyboard primitives** (`click`, `drag`, `fill`, `press_key`): exercise every affected mouse/pointer interaction *and* keyboard shortcut/navigation path (every bound key, shortcut badge/tooltip, `Escape`/`Enter`/`Space`, focus inside drawers/dialogs/controls, and inputs triggered mid-transition/animation before UI settles), verifying that every advertised control or shortcut is wired end-to-end and that drawers/non-text controls never swallow unrelated shortcuts via blanket `stopPropagation()` or retained focus. **Never** use `evaluate_script` DOM `.click()` synthesis or debug/store APIs to perform actions that have a UI mouse or keyboard control. *Narrow carve-out:* direct programmatic calls in `evaluate_script` are permitted strictly for read-only state/DOM assertions, deterministic seed/fixture setup, and headless/backend seams that intentionally have no UI mouse or keyboard surface.
   - **Execute the hand-off test recipe verbatim before closing the browser**: draft the user-facing manual test steps first and walk every step verbatim in `chrome-devtools` using real pointer/`press_key` inputs, so undocumented or hallucinated controls, labels, or shortcuts can never be reported as ready.
   - **Verify mobile, tablet-rail, and desktop layouts across every affected view** (and across **all** views when modifying shared shell, navigation, or global styles): use `emulate` (`viewport: "390x844x3,mobile,touch"` — required because OS window managers clamp `resize_page` above narrow mobile widths), `800×900` with any navigation sidebar expanded (tablet/rail), and `1440×900` (desktop), capturing `take_screenshot` at each breakpoint. Every checked view must satisfy: `document.documentElement.scrollWidth <= window.innerWidth` (zero horizontal overflow), readable control widths beside an open rail, off-canvas drawer open/backdrop-dismiss/`Escape`-dismiss/focus-return on narrow screens, and isolated content stacking (`isolation: isolate`) so positioned images, cards, and badges render beneath sticky headers and navigation drawers. Also inspect print/theme styles when touched; for a ticket built from a Stitch screen, compare screenshots against that screen and list any intentional deviations in the hand-off.
   - Kill the background dev-server task when verification completes, so no orphaned server outlives the session.
3a. **Scripted QA & Visual Evaluation (unattended)** (for all tickets touching UI, views, styles, input, images or client state; lets agents verify without a human in the loop):
   - Run the scripted QA command (e.g. `pnpm qa`): a Playwright run that walks every step of `COMPREHENSIVE_QA_FLOW.md`, asserts each step's expected state across both desktop (`1440×900`) and narrow mobile (`390×844`) viewports (plus `800×900` when testing sidebar layouts), and saves screenshots per step. Drive UI interactions with real Playwright pointer and keyboard calls (`page.mouse`, `page.click`, `page.fill`, `page.keyboard.press`) across both modalities and realistic focus/timing states, reserving any dev-only `window` debug API (stripped from production builds) for reading state, deterministic seeds/fixtures, and headless setup or seams that have no UI control. Every QA flow step added to `COMPREHENSIVE_QA_FLOW.md` gets a matching scripted step in the same ticket.
   - Run a **visual-evaluator subagent** on the screenshots. Give it the approved Stitch screens, `DESIGN.md` and a rubric: overlapping or clipped panels, content overlapping or leaving its container, missing images or visible placeholders where a real asset exists, unreadable text or contrast, state shown that contradicts the data, layout drift from the Stitch screen. It returns findings rated high / medium / low. Prefer this to pixel-diff screenshots, which break on every intentional design change.
   - Any **high** finding fails the gate: fix it and re-run. Medium and low findings go into the hand-off.
3b. **UI Verification Patterns (Automated QA Gates)** (enforce in the scripted QA suite so visual and interaction regressions fail mechanically):
   - **Full responsive range (wide desktop to mobile phone) and variable-content text**: test every screen and state across the full responsive viewport range from wide desktop down to mobile phone (e.g. `1920×1080` / `1440×900`, laptop `1366×768`, tablet `768×1024`, mobile `390×844` / `360×800`, unless the project's spec explicitly restricts supported form factors) plus a 20 px width sweep across breakpoints, cycling every option/enum and rendering the longest real data values. Assert `el.scrollWidth <= el.clientWidth + 1`, `el.scrollHeight <= el.clientHeight + 1`, `getComputedStyle(el).textOverflow !== 'ellipsis'`, and single-line height (`rect.height <= lineHeight * 1.65`) where intended. Never "fix" overflow on domain copy with `text-overflow: ellipsis` or `line-clamp`; reserve space by stacking variants in one CSS grid cell (`grid-area: 1 / 1`, inactive variants `visibility: hidden; aria-hidden="true"`), `min-inline-size` in `ch`, and `font-variant-numeric: tabular-nums`.
   - **Layout stability (`hadRecentInput` + landmark rects)**: record `PerformanceObserver` `layout-shift` entries **including `hadRecentInput: true`** (standard CLS ignores the 500 ms post-input window where selection, tab, and toggle shifts occur) *and* diff landmark `getBoundingClientRect()` boxes (`<= 0.5 px` tolerance, stripping pure 2D hover `translate` transforms) around every select, toggle, tab switch, hover, focus, drawer open/close, and 1-to-2-digit counter change, because `innerHTML` re-renders are invisible to `PerformanceObserver`. Selected/active states must never add unreserved `::before` glyphs or border widths, and staged panels must pre-reserve their secondary height.
   - **Worst-case container population and non-occlusion**: test fixed-width rails and cards with every optional button, stepper, and badge rendered simultaneously at the narrowest supported viewport (`scrollWidth <= clientWidth + 1`), and assert floating popovers/toolbars either auto-dismiss on selection or have zero bounding-box overlap with interactive canvas/target areas.
   - **Tooltips and canvas visibility**: use a single tooltip mechanism per element (assert `el.getAttribute('title') === null` whenever a custom tooltip or status callout is used), require `tabindex="0"` and `:hover, :focus-visible` parity on every tooltip trigger, and assert visibility via geometry and computed style (plus screenshot pixel-variance checks on `<canvas>` regions so flat fills cannot silently occlude textures).
   - **Staged reveals and spoiler discipline**: when an animation or async reveal hides a pre-computed result, redact unrevealed stages in the presenter/view-model layer rather than with CSS `visibility: hidden`. While spinning/loading, assert no future outcome appears in visible text, DOM child-node counts, logs, `[aria-live]`/`[role="status"]`/`[role="log"]`, or `[title]` attributes.
   - **Persistence round-trips and non-destructive quarantine**: run a `mutate → undo → mutate → page.reload() → resume` round-trip asserting state-hash and visual parity, keep non-active inspection stable during in-place edits, and verify that corrupt or newer-version saved data is quarantined (`needs-attention` with `Continue`/`Load` disabled and raw payload preserved) rather than silently overwritten.
   - **Data-derived expectations and `data-*` selectors**: derive expected item/asset counts and keys in QA from source data or manifests rather than hard-coded numbers, bind selectors to `data-*` contracts rather than display copy or CSS classes, and assert `!document.body.innerText.includes('§')` on every screen.
4. **Living Architecture, User Guide & Comprehensive QA Flow Check**:
   - [`ARCHITECTURE.md`](./ARCHITECTURE.md) must be updated with all newly added modules, components, stores, schemas, and Mermaid diagrams.
   - [`COMPREHENSIVE_QA_FLOW.md`](./COMPREHENSIVE_QA_FLOW.md) must be updated with end-to-end user test steps covering the newly implemented features.
   - [`USER_GUIDE.md`](./USER_GUIDE.md) (and its single-source content module) must be updated whenever any UI view, workflow, control, or domain rule changes; regenerate it with the docs script rather than editing the generated file by hand.
5. **Ticket Resolution**: **Resolve** the ticket (see Issue Tracker).
6. **Modern Web Guidance Audit** (for all frontend/UI/style tickets and bug fixes):
   - Cite the specific `modern-web-guidance` guide IDs consulted (e.g. `forms`, `css-layout`, `design-token-reactivity`) in the commit message or PR summary.
   - Verify that modern standard platform features (e.g. native `<dialog>`, Popover API, container queries, `:has()`, `:user-valid`, `<datalist>`) are used instead of legacy polyfills or ad-hoc custom JS.
7. **Post-Testing Architecture Deepening Review (`improve-codebase-architecture`)**:
   - After all checks (typecheck, lint, test suite, build, and `chrome-devtools` MCP verification) pass and **before** the Hard Stop:
     1. Run the `improve-codebase-architecture` skill (`.agents/skills/improve-codebase-architecture/SKILL.md`, informed by `.agents/skills/codebase-design/SKILL.md`) in a subagent scoped to the ticket's modified modules and hot spots.
        - **Boundary scan for templates and frameworks:** when the project is a reusable template, framework or shared layer with one or more consumers (e.g. an engine plus a sample game, a design system plus an app), the subagent also scans the **whole** shared layer for consumer-specific knowledge: consumer names and ids, consumer-only data shapes, constants, copy or storage keys, and shared code that only works for one consumer's flow. Every such leak is rated **high/strong whatever its size**. Leaks spread one import at a time and look "medium" one by one, so reviews scoped to modified modules let them pile up until the shared layer is no longer reusable.
        - A leak too big for one commit (it moves a seam) becomes a ticket in the next batch, never a "recorded for later" line. Back the rule with a mechanical check where possible: a lint rule banning consumer identifiers in the shared layers, and a test that runs a second, minimal consumer through the shared layer.
     2. Evaluate the subagent's report, remediating any immediate data-integrity or correctness bugs uncovered before the final commit. Favour candidates that deepen by deletion: implementing one removes the path it replaces in the same change, and each review applies the deletion test to modules earlier reviews introduced.
        - **Auto-implement high/strong candidates** without waiting for the user: one separate commit per candidate on the ticket or batch branch, followed by the full gauntlet (steps 1–3a). If any gate goes red, revert that commit and record the candidate in the plan or roadmap instead. Medium and low candidates are recorded, not implemented.
     3. Record the deepening candidates as a new **plan**. In Batch Mode, append them to the roadmap instead (see Batch Mode).
8. **User Testing Handoff Summary & Post-Implementation Gate (Hard Stop)**:
   - Conclude every ticket implementation by committing all verified changes (code, tests, `ARCHITECTURE.md`, `COMPREHENSIVE_QA_FLOW.md`, `USER_GUIDE.md` and its content module, and any ticket or plan files the tracker keeps in the repo) to the feature branch.
   - Present a tight, actionable output containing:
     1. The **Issue Implementation & Testing Handoff Summary** (what changed, verification results, step-by-step browser/end-to-end test recipes).
     2. The **Architecture Deepening Report & Recommendations** (summary table of the plan's candidates and the top recommendation).
     3. **Generic rule candidates**, when this ticket added or changed a rule in this file (see Upstream: my-agentic-dev).
   - **DO NOT merge into `main`**. Stop execution immediately after presenting the combined report and wait for the user to test and verify.

## Batch Mode (several tickets, one test cycle)

Run a **batch** when the user names one ("run batch 3") or a ticket range ("do 12–14"). Batches are defined in the **roadmap**'s Batches table, and each ticket records its batch (see Issue Tracker). A batch is the ticket workflow above with its fixed costs paid once:

1. **One branch for the batch**: `git checkout -b batch-<NN>-<slug>` from latest `main` (or `git worktree add .worktrees/batch-<NN> -b batch-<NN>-<slug>`). The tickets' batch gives the branch name.
2. **Tickets in batch order, one commit each**: implement the ticket, self-testing user-facing behaviour across real pointer and keyboard interactions, focus states, and transition/animation timing (not just internal store/API calls), then run the typecheck, the linter and the test files it touches. Frontend tickets still run the `modern-web-guidance` search before editing and cite the guide IDs in their own commit. A ticket is done when one commit holds its code and tests, the ticket is **Resolved**, and those checks are green.
3. **Once, after the last ticket**: run the full test suite and the production build, and one `chrome-devtools` session that checks the dev console for unexpected errors/warnings, verifies mobile (`390×844` via `emulate`), tablet-rail (`800×900`), and desktop (`1440×900`) layouts per gauntlet step 3, and walks every ticket's Verification section *plus* the exact combined hand-off test recipe as a human user via real pointer and `press_key` inputs (with the Step 3 narrow carve-out for headless-only seams), plus the scripted QA run and the visual evaluator (gauntlet step 3a). Then make one update of `ARCHITECTURE.md`, `COMPREHENSIVE_QA_FLOW.md` and `USER_GUIDE.md` covering the whole batch, and commit it as the batch's docs commit.
4. **Architecture review (gauntlet step 7), scoped to the batch's modified modules**: reconcile its candidates with the roadmap and drop the ones already ticketed. Auto-implement the high/strong ones as gauntlet step 7 describes. Append the rest, plus the batch's ticket statuses, to the roadmap's *Batch Log* in place of a new plan.
5. **One hand-off and hard stop (gauntlet step 8)**: a per-ticket summary, one combined test recipe, the architecture notes, and any generic rule candidates. The batch branch stays unmerged until the user has tested it.

**Stopping early**: when a ticket needs a user decision or outgrows its scope, keep the tickets already committed, **Comment** the blocker on that ticket and leave it unresolved, run steps 3–5 for what landed, and hand off.

**Defining batches** (when writing a roadmap):
- Group tickets that touch the same files and share a test surface.
- Keep each batch to roughly one session of work, and keep large seam-moving refactors in separate batches.
- Place every ticket after its blockers: in an earlier batch, or earlier in the same batch.
- Record a fallback split point for each heavier batch.

## Subagent & Worktree Execution Discipline

When orchestrating subagents or parallel worktrees on a ticket or batch:
- **Size worker tasks to fit turn budgets**: separate multi-file implementation + unit-test workers from full E2E QA + documentation closer workers. Full browser QA runs take 1–2 minutes per invocation; a worker that edits 5+ files and hits one layout or overflow failure in E2E QA will hit its turn cap mid-fix. Workers must iterate with scoped checks (`tsc --noEmit`, single-file test run, single-suite QA) before running the full gauntlet.
- **Commit per ticket and keep model routing flexible**: commit after every resolved ticket (`T-id`) so a turn cap or API quota reset never loses completed work, and dispatch subagents with inherited/default model routing rather than pinning every worker to a single model family.
- **Worktree path isolation and closeout sequence**: subagents running in a git worktree must resolve all reads and edits inside their worktree root (never the parent checkout) and report repo-relative `MODIFIED_FILES` from `git status --short`. Close worktrees in strict order: (1) wait for the subagent to terminate, (2) verify its worktree is clean, (3) `git worktree remove <path>` and `git worktree prune`, and (4) check out the feature/batch branch in the user's primary workspace so the user can test immediately.
- **Protect authoritative specifications**: treat specification documents as read-only for implementation workers unless the ticket explicitly asks for a spec change or new test vector; audit `MODIFIED_FILES` after every worker run and revert unauthorized spec edits.
- **Require mechanical verify receipts**: every worker hand-off must report a machine-checkable `VERIFY_RECEIPT` (`PASSED | FAILED | NOT_RUN`) with the exact commands and exit codes run; any failed or unrun gate latches `FAILED` until a closer re-runs that gate to green.

## Modern Web Guidance Protocol (Mandatory for Frontend Work)

This repository strictly adheres to modern web standards via the `modern-web-guidance` skill. Training weights contain obsolete patterns; do not code HTML/CSS/DOM APIs from memory.

### Action Pre-Condition (Strict Trigger)
You **MUST** execute a `modern-web-guidance` search or retrieve **BEFORE** creating or modifying:
- Any UI component or custom element
- Any stylesheet (`*.css`)
- Any form controls, input elements, focus management, dialogs, popovers, or DOM event handlers

**Crucial: This applies to ALL phases, including BUG FIXES and TWEAKS.**
Never treat bug fixes or small component edits as "exempt plumbing". If a bug involves input focus, dropdowns, form state, layout wrapping, or scrolling, run `modern-web-guidance search "<specific topic>"` before authoring the fix.

### Execution Commands
- **Search**:
  ```sh
  npx modern-web-guidance@latest search "<action-oriented query>"
  ```
- **Retrieve**:
  ```sh
  npx modern-web-guidance@latest retrieve "<guide-id>"
  ```
- **Sandboxed environments**: When outbound network access is blocked (`E403` / offline), pass `--offline` (`npx --offline modern-web-guidance@latest ...`) to run from the local `~/.npm/_npx` cache, falling back to an unsandboxed call only if the cache is cold.

## UI Design with Stitch

Visual design is settled in [Stitch](https://stitch.withgoogle.com) before it is coded, so layout and look are tuned on a canvas instead of through code churn. The Stitch MCP server provides the tools (`create_project`, `generate_screen_from_text`, `edit_screens`, `generate_variants`, `get_screen`, `list_screens`, `upload_design_md`, `create_design_system_from_design_md`, `apply_design_system`), and the `stitch-skills` skills (`generate-design`, `manage-design-system`, `code-to-design`, `extract-design-md`, `design-md`, `enhance-prompt`, `upload-to-stitch`) give the workflows. Load the matching skill before calling its tools.

**When**: new screens, redesigns, navigation or layout changes, and any ticket whose look the user has not yet seen. Copy edits, bug fixes and changes that keep the layout skip Stitch, but still follow `DESIGN.md`.

**One up-front design checkpoint**: approve the design once, before the first UI ticket, in its own design ticket or batch: the user OKs `DESIGN.md` (palette, fonts, roundness) and picks every planned screen in Stitch. After that, agents implement and verify against those screens unattended (gauntlet steps 3 and 3a), without stopping for per-screen approval. A ticket that needs a screen nobody has approved yet goes back to the user before it is built.

**Workflow**:
1. **Design system first**: `DESIGN.md` at the repo root is the source of truth for tokens; the Stitch design system mirrors it. If either is missing, create `DESIGN.md` (`manage-design-system`, or `extract-design-md` / `code-to-design` for an existing app; Stitch skills default to `.stitch/DESIGN.md`, so pass the root path), then upload it and run `create_design_system_from_design_md`. Show the user the palette, fonts and roundness and get their OK before uploading.
2. **Generate and iterate on the canvas**: enhance the prompt first (`enhance-prompt`). Generation prompts describe layout, content and structure only, because the project's design system already supplies colours, fonts and roundness and repeating them conflicts. Use `edit_screens` and `generate_variants` until the user picks a screen. Show the user each tool's text description and suggestions.
3. **Record the decision**: the ticket gets a `Source:` line with the Stitch project and screen IDs, and `DESIGN.md` records the project ID. Agreed token changes go into `DESIGN.md` first, then into Stitch.
4. **Implement from the screen, not the export**: treat the screen's HTML and screenshot (`get_screen`) as a visual reference. Rebuild it in the repo's own components, tokens and platform features under the Modern Web Guidance Protocol. Exported markup (CDN styles, utility soup, absolute layouts) is never pasted in.
5. **Verify against the screen**: gauntlet step 3 compares the running app with the Stitch screenshot.
6. **Keep them in sync**: when implementation changes the visual language, update `DESIGN.md` in the same ticket and re-apply it to the Stitch project, so the next design round starts from what shipped.

If the Stitch MCP tools are not available, say so and point the user at the Stitch setup in the my-agentic-dev README. Don't design UI from memory as a silent fallback.

## Upstream: my-agentic-dev

This file grew from `GENERIC-AGENTS.md` in [psiarkiewicz/my-agentic-dev](https://github.com/psiarkiewicz/my-agentic-dev) (usually cloned at `~/coding/my-agentic-dev`): the shared rules, re-used across projects. Project-specific rules stay here; rules that would help any project belong upstream too.

- **Spot candidates**: whenever you add or change a rule in this file, ask whether it is project-specific (this domain, stack, paths, traps) or generic (workflow, gauntlet, tooling, agent behaviour, a trap any project in this stack would hit).
- **Remind, don't push**: list generic candidates in the hand-off under **Generic rule candidates**: each rule worded without project names, the upstream section it belongs in, and a one-line reason. Ask the user whether to fold each one in. Never edit the upstream repo unless the user asks.
- **When the user agrees**: generalize the rule (strip project names, paths and commands into examples), edit `GENERIC-AGENTS.md` upstream on its own branch or commit, and leave this file's project-specific wording alone.
- **Pulling updates down**: when the user asks to sync from upstream, diff this file against the latest `GENERIC-AGENTS.md`, adopt the generic changes, and keep every project-specific section intact.

## Known traps

Verified problems that have already bitten, or that a reasonable implementation gets wrong. Add one line when a bug's root cause is a non-obvious rule: the rule, then its consequence.

<!-- - **<Trap>**: <rule> → <consequence>. -->
- **Dev-server endpoints that write files on disk must isolate those paths from config bundling and HMR**: keep bundler config plugins free of static imports into dev-written JSON/asset directories, and exclude those output paths in the dev watcher and hot-update hook (e.g. Vite `server.watch.ignored` + `handleHotUpdate`) → otherwise writing a file mid-request restarts the dev server (dropping the active HTTP/WebSocket connection) or broadcasts a client full-reload that wipes editor UI state.
- **Programmatic QA hides broken keyboard, focus and timing paths**: drive UI verification with real pointer and keyboard events across real focus states and active transitions/animations (reserving debug/`evaluate_script` calls strictly for state inspection, seed/fixture setup, and headless seams with no UI control), ensure overlays and non-text controls never swallow global shortcuts via blanket `stopPropagation()` or retained focus, and run the exact hand-off test recipe before closing the browser → otherwise synthetic `.click()` / store-dispatch + await-idle passes green while shortcuts are unbound, trapped by focus, or dropped mid-transition.
- **Window `resize_page` clamps above mobile widths, and open sidebars narrow `md`/`lg` content columns**: verify every affected view (and every view when touching shared shell, navigation, or global CSS) via `emulate` at `390×844` mobile, `800×900` with any sidebar open, and `1440×900` desktop, and isolate main-content stacking (`isolation: isolate`) → otherwise narrow media queries never fire during QA, multi-column grids crush controls or clip beside an open rail, and positioned images paint above slide-over drawers.
- **Standard CLS ignores the 500 ms post-input window and `innerHTML` re-renders, and `ellipsis` hides broken layouts**: gate E2E steps on `layout-shift` entries *including* `hadRecentInput` plus landmark bounding-box diffs across viewports and width sweeps, and reserve space for variable copy with stacked grid cells (`grid-area: 1 / 1`) or `ch`/`tabular-nums` instead of `text-overflow: ellipsis` → otherwise tabs, selection badges, and multi-line descriptions shift panels or clip domain copy on click while standard CLS reports `0`.
- **CSS `visibility: hidden` does not redact pre-computed outcomes**: strip unrevealed stages in the presenter/view-model before rendering and assert zero future results in DOM child counts, `[aria-live]`, `[title]`, and logs during spin/loading phases → otherwise screen readers and DOM queries leak the outcome or hit count before the reveal animation finishes.

## Agent Skills & Repository Conventions

### Domain docs

Single-context (`GLOSSARY.md` and `docs/adr/` at the repo root) or multi-context (`GLOSSARY-MAP.md`) layout. See `docs/agents/domain.md`.

### Modern web guidance

Search tool for modern web development best practices (`.agents/skills/modern-web-guidance/SKILL.md`). Mandatory pre-condition for any frontend, component, or style implementation and bug fix. See protocol above.

### Stitch design

Stitch MCP server plus the `google-labs-code/stitch-skills` skills, for designing and tuning UI before coding it. See UI Design with Stitch above.
