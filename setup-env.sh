#!/usr/bin/env bash
# Bootstrap my agentic dev setup into a target repository.
#
# Usage:
#   ./setup-env.sh [-a <agent>] [-S] [<target-repo-dir>]
#
#   -a <agent>   Agent to install skills for: claude-code, cursor, opencode,
#                devin, windsurf, amp, pi, ... Omit it to choose interactively.
#   -S           Skip the Stitch design skills (non-UI projects).
#   <target>     Repository to set up. Defaults to the current directory.
#
# Steps:
#   1. Install Matt Pocock's skills (mattpocock/skills).
#   2. Install the modern-web-guidance skill.
#   3. Install the Stitch design skills (google-labs-code/stitch-skills).
#   4. Copy GENERIC-AGENTS.md to <target>/AGENTS.md (stamped with the upstream
#      commit) and symlink CLAUDE.md to it, unless AGENTS.md already exists.
#   5. Remind you to connect the Stitch MCP server (needs your API key).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT=""
STITCH=1

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

while getopts ":a:Sh" opt; do
  case "$opt" in
    a) AGENT="$OPTARG" ;;
    S) STITCH=0 ;;
    h) usage; exit 0 ;;
    :) echo "error: -$OPTARG needs an agent name" >&2; usage >&2; exit 2 ;;
    \?) echo "error: unknown option -$OPTARG" >&2; usage >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

TARGET="${1:-$PWD}"
if [[ ! -d "$TARGET" ]]; then
  echo "error: target directory '$TARGET' does not exist" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found; install Node.js first" >&2
  exit 1
fi

# Pass -a through when given; without it the skills installer prompts.
add_skills() {
  if [[ -n "$AGENT" ]]; then
    npx skills@latest add "$1" -a "$AGENT"
  else
    npx skills@latest add "$1"
  fi
}

cd "$TARGET"
echo "==> Setting up agentic dev environment in $TARGET"

# 1. Matt Pocock's skills.
echo "==> Installing mattpocock/skills"
add_skills mattpocock/skills

# 2. Modern web guidance skill.
echo "==> Installing modern-web-guidance"
npx modern-web-guidance@latest install

# 3. Stitch design skills.
if [[ "$STITCH" -eq 1 ]]; then
  echo "==> Installing google-labs-code/stitch-skills"
  add_skills google-labs-code/stitch-skills
else
  echo "==> Skipping Stitch skills (-S)"
fi

# 4. AGENTS.md + CLAUDE.md symlink.
if [[ -e AGENTS.md ]]; then
  echo "==> AGENTS.md already exists; leaving it alone (compare with $SCRIPT_DIR/GENERIC-AGENTS.md)"
else
  echo "==> Writing AGENTS.md from GENERIC-AGENTS.md"
  UPSTREAM_REV="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  {
    echo "<!-- Seeded from psiarkiewicz/my-agentic-dev GENERIC-AGENTS.md @ $UPSTREAM_REV. See \"Upstream: my-agentic-dev\" below. -->"
    echo
    cat "$SCRIPT_DIR/GENERIC-AGENTS.md"
  } > AGENTS.md
fi

if [[ -e CLAUDE.md || -L CLAUDE.md ]]; then
  echo "==> CLAUDE.md already exists; leaving it alone"
else
  ln -s AGENTS.md CLAUDE.md
  echo "==> Linked CLAUDE.md -> AGENTS.md"
fi

cat <<'EOF'
==> Done. Next steps:
  1. Fill in the project-specific sections listed in the bootstrap comment in AGENTS.md.
  2. Run /setup-matt-pocock-skills in your agent to write docs/agents/
     (issue tracker, triage labels, domain docs): fold its Issue tracker and
     Triage labels lines into AGENTS.md's Issue Tracker section (do not add
     them under Agent Skills & Repository Conventions), keep only your
     tracker's column in that table, and narrow Domain docs to the chosen layout.
EOF

if [[ "$STITCH" -eq 1 ]]; then
  cat <<'EOF'
  3. Connect the Stitch MCP server (one time per agent; the skills need it):
     - Create an API key in Stitch (profile menu > Stitch settings > API keys)
       and export it: export STITCH_API_KEY=...
     - Claude Code:
         claude mcp add --transport http stitch https://stitch.googleapis.com/mcp \
           --header "X-Goog-Api-Key: $STITCH_API_KEY"
     - Any MCP client (mcp.json / .cursor/mcp.json):
         "stitch": { "command": "npx", "args": ["-y", "mcp-remote",
           "https://stitch.googleapis.com/mcp",
           "--header", "X-Goog-Api-Key: ${STITCH_API_KEY}"] }
     - Full guide: https://stitch.withgoogle.com/docs/mcp/setup/
  4. For UI projects: create DESIGN.md and a Stitch project
     (see "UI Design with Stitch" in AGENTS.md).
EOF
fi
