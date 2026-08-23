---
name: sf
description: Work the SF direct-deals lead pipeline via Iterator (alias for /porygon)
argument-hint: <what you want to do — e.g. "leads in diligence", "unclaimed inbox", "assign this one to me">
disable-model-invocation: true
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

**Bare `/sf` (no request):** orient and stop — a human read of the pipeline, then **ask** what
they want. Orient with **aggregates** (the summary tool + one or two quick `run_sql`
aggregations); **never list individual lead rows** on a bare call.

Brief it like a colleague, not a form:

- **Open with one plain sentence** stating what's actually true (total; all one stage / source?
  anything owned, shortlisted, passed? how old?).
- **Then the breakdown that's actually informative** — a per-**stage** table only earns its
  place if leads span stages; when everything's in one stage it's noise, so break down by
  **industry / source / signal presence / geography / launch recency** instead. Clean box
  table when it helps.
- `to_triage` *is* the `sourced`/unclaimed leads (don't double-count). **Shortlist is not a
  stage** — a shortlisted lead still sits in a stage; treat it as a personal cut.
- **Interpret, then point at the usable cuts** (money-signal leads, a geo cluster, loud
  launches) so they triage by cluster, not row by row. Then ask what to pull.

Aim for this shape/tone (content illustrative, not required columns):

```
827 untriaged — the whole direct pipeline: every lead sourced, unclaimed,
unshortlisted. Zero owned, zero passed (one import batch, 20260823, all YC).

┌──────────────┬─────┬────────┬──────────────┐
│ Industry     │  n  │ signal │ launched <30d│
├──────────────┼─────┼────────┼──────────────┤
│ B2B          │ 487 │   23   │     109      │
│ …            │  …  │   …    │      …       │
└──────────────┴─────┴────────┴──────────────┘

Only 78 of 827 carry any signal. Worth acting on: the ~43 money-signal
leads, a ~12-lead SEA cluster, the loud-but-unannotated launches.

Want the money-signal cut, the SEA cluster, or the raw inbox?
```

**Never dump raw rows.** The lead tools return big rows (nested `signals` / `launches` /
company / founder). Render each lead as a **compact card**, not JSON — stage as a leading
tag (its own thing, not tacked onto the founder), then company, a one-liner, a meta line:

```
[SOURCED]  Tasklet — Andrew Lee
           "AI agents that connect to your tools and run 24/7 to get work done"
           YC #31470 · unclaimed · B2B · San Francisco
           Signal: $20M raise at $175M val
```

`[STAGE]` caps leading · **Company — Founder** title · one-liner from the tagline if any ·
meta line `source (+ YC id) · owner or unclaimed · industry · location` · **Signal:** the
strongest signal on its own line · **blank line between leads**. Default ~10; if there are
more, say how many and offer to narrow. Pull full detail (`get_lead`) only for a lead the
user names.

## Discipline

Load the Iterator tools if deferred (`ToolSearch` for "Iterator"), call `describe_schema`
first, and use the Iterator **lead tools** — e.g. `find_leads` / `leads_summary` /
`create_lead` once available, otherwise `list_leads` / `get_lead`. Reserve `run_sql` for
aggregation the lead tools can't express. For the fuller writeup, `/porygon` and
`/iterator` carry the same model.

Request (if empty: summary only, then ask — see "Bare `/sf`" above): $ARGUMENTS
