#!/usr/bin/env bash
#
# UserPromptSubmit hook for the Iterator plugin.
#
# Fires on every user prompt. If the prompt looks like an Iterative CRM /
# deal-flow question, it injects a one-line reminder telling Claude to reach
# for the Iterator MCP. Otherwise it prints nothing and stays out of the way.
#
# The harness passes the hook a JSON object on stdin that includes the user's
# prompt text under the "prompt" key. We keyword-match that text.
#
set -euo pipefail

input="$(cat)"

# Pull the prompt text out of the hook JSON; fall back to the raw stdin if the
# shape ever changes so the hook degrades gracefully instead of going silent.
prompt="$(printf '%s' "$input" | python3 -c '
import sys, json
try:
    print(json.load(sys.stdin).get("prompt", ""))
except Exception:
    pass
' 2>/dev/null || true)"
[ -z "$prompt" ] && prompt="$input"

# Case-insensitive, word-boundary match for Iterator / CRM territory.
# Tune this list to taste: broaden it if real questions slip through,
# tighten it if you get nudges on unrelated (e.g. coding) prompts.
pattern='\b(iterator|founders?|co-?founders?|applicant|application|applied|cohort|batch|deal ?flow|portfolio|prospect|partner (score|feedback)|feedback from|recommendation score|investment committee|accepted and|got in)\b|\b[SW][0-9]{2}\b'

if printf '%s' "$prompt" | grep -qiE "$pattern"; then
  cat <<'MSG'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"[Iterator reminder] This prompt looks like an Iterative CRM / deal-flow question. The Iterator MCP is available (founders, companies, applications, cohorts, partner feedback, portfolio). Load its tools (via ToolSearch if deferred), call describe_schema first, and answer from run_sql / the Iterator tools rather than guessing. You can also run /iterator. When reporting feedback, name who gave it and show all stages."}}
MSG
fi

exit 0
