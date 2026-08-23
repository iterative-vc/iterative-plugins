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
#
# Two groups of terms:
#   1. recruiting/deal-flow (founders, applications, cohorts, feedback, …)
#   2. lead / lane vocabulary (leads, pipeline, stages, SF/porygon, verbs).
# NOTE: `sea` is intentionally scoped to `sea (leads|founders|companies)`,
# not a bare token — a bare `sea` false-hits on ordinary prose. Same idea for
# `direct`: only the deal-flow senses (`direct deals/leads/lane`) qualify.
pattern='\b(iterator|founders?|co-?founders?|applicant|application|applied|cohort|batch|deal ?flow|portfolio|prospect|partner (score|feedback)|feedback from|recommendation score|investment committee|accepted and|got in|leads?|pipeline|sourced|shortlist(ed)?|qualified|diligence|passed?|released?|sf|porygon|direct (deals?|leads?|lane)|sea (leads?|founders?|companies?))\b|\b[SW][0-9]{2}\b'

if printf '%s' "$prompt" | grep -qiE "$pattern"; then
  cat <<'MSG'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"[Iterator reminder] This prompt looks like an Iterative CRM / lead question. The Iterator MCP is available. Load its tools (via ToolSearch if deferred) and call describe_schema first; use the Iterator lead tools rather than guessing, and reserve run_sql for aggregation the lead tools can't express. LEADS LIVE IN TWO LANES (a lane column on the lead): (1) cohort = the recruiting/batch pipeline — spoken as 'cohort/batch leads', 'W27 / current cohort', 'SEA leads' (SEA is a geography filter, not a lane); stages sourced -> contacted -> engaged -> applying -> applied (terminal: dropped). (2) direct = the SF direct-deals pipeline — spoken as 'SF', 'SF leads', 'SF pipeline', 'porygon', 'pod porygon'; stages sourced (unclaimed inbox/triage) -> qualified (claimed/shortlisted) -> contacted (we reached out) -> reviewing (back-and-forth) -> diligence (diligencing) -> committed -> invested; terminal: passed / lost / no_allocation. ACTION VERBS: create a lead (e.g. one that arrived by email), assign (pick up a sourced lead -> qualified, you own it), shortlist/unshortlist (personal bookmark), pass (reject -> terminal), release (return an owned lead to the ownerless pool). SOURCES/provenance: direct leads are mostly 'YC' (yc_intel) plus 'email'; new feeds are additional direct SOURCES, not new lanes. HOW TO ANSWER (orient -> explore -> act): start with a pipeline summary; then explore leads filtered by lane + stage + owner (me/none/name) + shortlist + source + geography (location, e.g. SEA/Singapore) + signal + 'new since last import'; then act with the verbs. E.g. 'porygon leads in diligence' = direct lane, diligence stage; 'current cohort SEA leads' = cohort lane, current cohort, location SEA. Prefer the Iterator lead tools (find_leads / leads_summary / create_lead / get_lead); use run_sql for the founder-LinkedIn join (person.linkedin_url) or aggregation those can't express. Run /porygon for the SF working loop, or /iterator for the full playbook."}}
MSG
fi

exit 0
