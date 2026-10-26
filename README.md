# my-agentic-dev

My locked-down, generic setup for AI-assisted software development: one set of agent rules plus a script that installs the skills those rules depend on into any repository.

It works with Claude Code, Cursor, OpenCode, Devin, Windsurf, Amp, Pi and other agents that read `AGENTS.md` / `CLAUDE.md`.

## What's in here

| File | Purpose |
|---|---|
| [`GENERIC-AGENTS.md`](./GENERIC-AGENTS.md) | The template `AGENTS.md`: the workflow every agent follows in my repos. |
| [`setup-env.sh`](./setup-env.sh) | Installs the skills into a target repo and seeds its `AGENTS.md` + `CLAUDE.md` symlink. |

### The rules in `GENERIC-AGENTS.md`

- **Documents in reading order**: `GLOSSARY.md` (domain vocabulary and invariants), the spec (its test vectors set the bar for correctness), and the living `ARCHITECTURE.md`, `COMPREHENSIVE_QA_FLOW.md` and `USER_GUIDE.md`. Also `DESIGN.md` (the visual design contract) and ADRs in `docs/adr/`.
- **Tracker-neutral issue workflow**: one vocabulary (*Read*, *Comment*, *Resolve*, *batch*, *plan*, *roadmap*) covering both local markdown tickets in `.scratch/` and GitHub Issues.
- **Branch / worktree per ticket**: never on `main`, and nothing merges until a human has tested it.
- **Testing gauntlet**: strict typecheck, a lint run with zero warnings, the full test suite, a production build, live browser checks via the `chrome-devtools` MCP on an OS-assigned port, doc updates, ticket resolution, a modern-web-guidance audit, and an `improve-codebase-architecture` deepening review.
- **Hard stop at hand-off**: a testing summary, architecture recommendations and any generic rule candidates, then the agent waits.
- **Batch mode**: several tickets on one branch with one test cycle, driven by a roadmap's Batches table and Batch Log.
- **Modern Web Guidance protocol**: before any UI, CSS, form, focus or dialog work, including bug fixes, the agent searches `modern-web-guidance` instead of coding the platform from memory.
- **UI Design with Stitch**: new screens and redesigns are designed and tuned on the Stitch canvas first. `DESIGN.md` holds the design tokens and is synced to the Stitch design system, and tickets cite the Stitch screen they implement. The agent rebuilds that screen from the repo's own components (exported markup is never pasted in) and checks the result against the screen in the browser.
- **Upstream: my-agentic-dev**: agents spot rules they add to a project's `AGENTS.md` that would help any project, and propose them back to this repo. They don't edit it themselves.
- **Known traps**: a running list of non-obvious rules that have already caused bugs.

## Usage

Requires Node.js (`npx`) and bash.

```sh
git clone https://github.com/psiarkiewicz/my-agentic-dev.git ~/coding/my-agentic-dev

# From inside the repo you want to set up:
~/coding/my-agentic-dev/setup-env.sh -a claude-code   # or cursor, opencode, devin, windsurf, amp, pi
~/coding/my-agentic-dev/setup-env.sh                  # omit -a to choose the agent interactively
~/coding/my-agentic-dev/setup-env.sh -S               # skip the Stitch skills (non-UI projects)
~/coding/my-agentic-dev/setup-env.sh -a cursor ../other-repo   # or pass a target directory
```

The script runs:

1. `npx skills@latest add mattpocock/skills -a <agent>`: [Matt Pocock's skills](https://github.com/mattpocock/skills) (`tdd`, `diagnose`, `codebase-design`, `improve-codebase-architecture`, `to-issues`, `to-prd`, `grilling`, …).
2. `npx modern-web-guidance@latest install`: the modern-web-guidance skill.
3. `npx skills@latest add google-labs-code/stitch-skills -a <agent>`: the [Stitch skills](https://github.com/google-labs-code/stitch-skills) (`generate-design`, `manage-design-system`, `code-to-design`, `extract-design-md`, `design-md`, `enhance-prompt`, …). Skip it with `-S`.
4. Copies `GENERIC-AGENTS.md` to `AGENTS.md`, with a first-line comment recording the upstream commit, and links `CLAUDE.md -> AGENTS.md`. It skips any file that already exists.
5. Prints the Stitch MCP setup reminder (below).

Then, in the target repo:

1. Fill in the project-specific sections listed in the bootstrap comment at the top of `AGENTS.md`: commands, stack, governing principle, invariants, seams, build order, design, known traps.
2. Run `/setup-matt-pocock-skills` in your agent to generate `docs/agents/` (issue tracker, triage labels, domain docs), fold its tracker lines into the Issue Tracker section (rather than under Agent Skills & Repository Conventions), keep only your tracker's column in that table, and narrow Domain docs to the chosen layout.
3. For UI projects, connect Stitch (below), then have the agent create `DESIGN.md` and a Stitch project.

### Stitch MCP server (one time per agent)

The Stitch skills need the Stitch MCP server, and that needs your personal API key, so the script reminds you instead of configuring it for you.

1. In [Stitch](https://stitch.withgoogle.com), create an API key (profile menu → Stitch settings → API keys) and `export STITCH_API_KEY=...` in your shell profile.
2. Register the server:
   - **Claude Code**:
     ```sh
     claude mcp add --transport http stitch https://stitch.googleapis.com/mcp \
       --header "X-Goog-Api-Key: $STITCH_API_KEY"
     ```
   - **Any MCP client** (`mcp.json`, `.cursor/mcp.json`, …):
     ```json
     {
       "mcpServers": {
         "stitch": {
           "command": "npx",
           "args": ["-y", "mcp-remote", "https://stitch.googleapis.com/mcp",
                    "--header", "X-Goog-Api-Key: ${STITCH_API_KEY}"]
         }
       }
     }
     ```
3. Full guide: https://stitch.withgoogle.com/docs/mcp/setup/

## Keeping it current

`GENERIC-AGENTS.md` is the source of truth, and the generated `AGENTS.md` says so in its **Upstream: my-agentic-dev** section. Agents working in a project list any generic rule they add as **Generic rule candidates** in their hand-off, and you decide whether to fold each one back in here. To pull upstream changes into a project, ask its agent to sync from upstream: it diffs against the latest `GENERIC-AGENTS.md`, using the commit stamped on the first line of `AGENTS.md` as the baseline, and keeps the project-specific sections. The script never overwrites an existing `AGENTS.md`.

## License

[Apache 2.0](./LICENSE)
