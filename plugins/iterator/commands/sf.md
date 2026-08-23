---
description: Work the SF direct-deals lead pipeline via Iterator (alias for /porygon)
argument-hint: <what you want to do — e.g. "leads in diligence", "unclaimed inbox", "assign this one to me">
---

**`/sf` is `/porygon`** — two doors, one room. This runs the SF direct-deals lead playbook
through the **Iterator MCP**. **Do not answer from memory or guess** — query the live data.

"SF" leads = the **direct** lane (internally **porygon** / pod porygon), as opposed to the
**cohort** lane (recruiting / batch — "cohort/batch leads", "current cohort", "SEA leads",
where SEA is a geography filter, not a lane).

## Direct-lane stages

```
sourced    unclaimed inbox / triage — nobody owns it yet
qualified  claimed / shortlisted — someone owns it
contacted  we reached out
reviewing  back-and-forth in progress
diligence  we're diligencing it
committed  we've committed
invested   deal done
```

Terminal: **passed** / **lost** / **no_allocation**.

## Verbs

**create** (add a lead, e.g. one that arrived by email) · **assign** (pick up a `sourced`
lead → `qualified`, you own it) · **shortlist / unshortlist** (personal bookmark) ·
**pass** (reject → terminal) · **release** (return an owned lead to the ownerless pool).

## Sources

Direct leads are mostly **YC** (`yc_intel`) plus **email**. New feeds are additional
direct **sources**, not new lanes.

## Orient → explore → act

Start with a pipeline **summary**; then **explore** leads filtered by lane (direct) +
stage + owner (me / none / name) + shortlist + source + geography (location) + signal +
"new since last import"; then **act** with the verbs. E.g. "porygon leads in diligence" =
direct lane, `stage = diligence`; "what's unclaimed" = direct, `stage = sourced`,
`owner = none`.

## Discipline

Load the Iterator tools if deferred (`ToolSearch` for "Iterator"), call `describe_schema`
first, and use the Iterator **lead tools** — e.g. `find_leads` / `leads_summary` /
`create_lead` once available, otherwise `list_leads` / `get_lead`. Reserve `run_sql` for
aggregation the lead tools can't express. For the fuller writeup, `/porygon` and
`/iterator` carry the same model.

Request: $ARGUMENTS
