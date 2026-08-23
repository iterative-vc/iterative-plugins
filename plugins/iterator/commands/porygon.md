---
description: Work the SF direct-deals (porygon) lead pipeline via Iterator
argument-hint: <what you want to do — e.g. "leads in diligence", "unclaimed inbox", "assign this one to me">
---

You are working the **SF direct-deals pipeline** — internally **porygon** (pod porygon) —
through the **Iterator MCP**. This is the working loop for SF leads. **Do not answer from
memory or guess** — query the live data with the Iterator lead tools.

## Two lanes (know which one you're in)

Leads live in one `lead` table split by a **lane** column:

- **cohort** — the recruiting / batch pipeline. Spoken as "cohort/batch leads",
  "W27 / current cohort", "SEA leads" (SEA is a **geography** filter, not a lane).
- **direct** — the **SF direct-deals** pipeline. This is porygon. Spoken as "SF",
  "SF leads", "SF pipeline", "porygon", "pod porygon".

`/porygon` is about the **direct** lane. If a request is clearly about recruiting/batch,
that's the cohort lane instead.

## Direct-lane stages (one-word meanings)

```
sourced    unclaimed inbox / triage — nobody owns it yet
qualified  claimed / shortlisted — someone picked it up and owns it
contacted  we reached out
reviewing  back-and-forth in progress
diligence  we're diligencing it
committed  we've committed
invested   deal done
```

Terminal outcomes: **passed** / **lost** / **no_allocation**.

## Action verbs

- **create** — add a lead (e.g. one that arrived by email).
- **assign** — pick up a `sourced` lead → `qualified`; you now own it.
- **shortlist / unshortlist** — a personal bookmark (doesn't change the stage).
- **pass** — reject → terminal.
- **release** — return an owned lead to the ownerless pool.

## Sources / provenance

Each lead has a **source**. Today direct leads are mostly **YC** (`yc_intel`) plus the
occasional **email** lead. New feeds are additional direct **sources**, not new lanes.

## How to answer: orient → explore → act

1. **Orient** with a pipeline **summary** — how many leads sit in each stage right now.
2. **Explore** leads filtered by any of: **lane** (direct) + **stage** + **owner**
   (me / none / a name) + **shortlist** + **source** (YC/email) + **geography** (location)
   + **signal** + **"new since last import"**.
3. **Act** with the verbs above.

### No request given (bare `/porygon`)

If `$ARGUMENTS` is empty, **only orient, then stop and ask.** Run the pipeline **summary**
tool once, render it as the table below, and ask what they want next. **Do NOT call
`find_leads` / `list_leads` or dump any lead rows on a bare invocation** — a fresh import
can be hundreds of leads, and each row is large.

Render the summary as a small table — the stage funnel first, then your personal queue and
the triage line. Shortlist is a personal bookmark, **not** a stage, so it belongs with "your
queue", not in the funnel:

```
SF (direct) pipeline

  STAGE        LEADS
  Sourced        827
  Qualified        0
  …                …          (stages in pipeline order; a Total row at the bottom)
  Total          827

  Your queue:  0 owned · 0 shortlisted
  Triage:      827 to triage · newest import 20260823 (827 new)

What do you want — triage the inbox, drill into a stage, or see your own queue?
```

## Output discipline (never dump raw rows)

The lead tools return **big** rows (nested `signals`, `launches`, full company/founder
objects). Never echo that JSON. Render each lead as a **compact, scannable card** — stage as
a leading tag (it's its own thing, not tacked onto the founder), then the company, a
one-liner, and a short meta line:

```
[SOURCED]  Tasklet — Andrew Lee
           "AI agents that connect to your tools and run 24/7 to get work done"
           YC #31470 · unclaimed · B2B · San Francisco
           Signal: $20M raise at $175M val
```

- **`[STAGE]`** in caps, leading — the fastest thing to scan down a list.
- **Company — Founder** as the title.
- **One-liner** from the company's tagline/description if there is one (skip the line if not).
- **Meta line:** source (+ YC id/batch) · owner or `unclaimed` · industry · location.
- **Signal:** the strongest signal if any (largest raise, standout traction) on its own line.
- **Blank line between leads** so each reads as a separate item.
- **Default ~10.** If there are more, say how many and offer to narrow — don't fetch them all.
- Pull full detail (`get_lead`) only for a **specific** lead the user names.

## Worked examples (phrase → what to do)

- **"porygon leads in diligence"** → direct lane, `stage = diligence`. List them.
- **"what's in the inbox / what's unclaimed"** → direct lane, `stage = sourced`,
  `owner = none`. That's the triage queue.
- **"assign the Acme lead to me"** → find that direct lead, then **assign** it
  (sourced → qualified, owned by you).
- **"a founder emailed me, add them"** → **create** a direct lead with `source = email`.
- **"my SF leads"** → direct lane, `owner = me`, across active stages.

## Discipline

1. **Load the tools if needed.** The Iterator tools may be deferred — load them
   (e.g. `ToolSearch` for "Iterator", which surfaces the full set).
2. **Call `describe_schema` before writing SQL.** Table/column/enum names are
   grant-driven and not guessable.
3. **Use the Iterator lead tools, not guesses** — e.g. `find_leads` / `leads_summary` /
   `create_lead` once available, otherwise `list_leads` / `get_lead`. Reserve `run_sql`
   for aggregation the lead tools can't express (and check `describe_schema` first for the
   real `lead.lane` / `lead.stage` / `lead.source` values before hand-writing filters).

Request (if empty, follow "No request given" above — summary only, then ask): $ARGUMENTS
