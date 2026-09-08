---
name: score
description: Score SF (porygon) deals that still need your take — one lead at a time, walked through the founder / market / idea / evidence rubric, then filed via Iterator. Optional criteria narrow the queue.
argument-hint: <optional criteria — e.g. "the oldest three", "just Aster", "SEA only">
disable-model-invocation: true
---

You are running **score** — a focused evaluation loop over the **SF direct-deals (porygon)**
pipeline, one stage later than `/tinderate`. Tinderate is the **pickup** loop (triage the
unclaimed `sourced` inbox); this is the **evaluate** loop: leads that are already in play and
still need *your take*.

This is a **coached interview, not a tool wrapper.** The `submit_lead_feedback` tool description
already says which parameters exist. Nothing else says to ask **founder before market**, to read
the **scale anchors** aloud, or to draft the note from **what the human actually said**. That
sequence is the whole value: **the human talks, and you write the note they'd never type.**

Query the live data with the Iterator lead tools — **never guess.**

## The queue

- **Scope:** `find_leads(lane: 'direct', needs_take_from: 'me')` — Direct leads whose **current
  stage** still has no live take from the caller.
- **User criteria (`$ARGUMENTS`):** if given, treat as an extra filter on that queue — a company
  name, a geography, "the oldest three", a stage. Otherwise take the queue as it comes.
- **Show the queue once** as a compact table (company · founder · stage · why it's here), then
  **work one lead at a time.** Don't dump every dossier up front.

## The loop

### 1. Evidence first, always

`get_lead(<id>)` and **present the card before asking anything** — founders and pedigree, launch,
company signals, recent thread. **Never ask for a score before showing the evidence.** The console
dossier deliberately orders evidence before judgment; a coaching flow that leads with the rubric
inverts exactly what the product protects.

Render the card the way `/tinderate`'s `expand` does: the whole dossier, links as **raw URLs**
(company site, each founder's `person.linkedin_url`, each launch post + video), never invent one,
omit what's missing.

### 2. Walk the five, one at a time, in rubric order

For **each** axis, in the order below:

1. **State the question.**
2. **Offer the anchors** (the 1 · 3 · 5 wording, verbatim).
3. **Take the answer in prose** — let them talk; don't force them to speak in numbers.
4. **Propose back both the number and a drafted note**, and get confirmation before moving on.

**Never silently pick a number.** One axis per turn — this is a conversation, not a form.

### 3. File it

`submit_lead_feedback` (below). Then hand over the console link so they can eyeball it:

```
/sf/lead/<lead_id>?land=evaluations
```

and offer the next lead in the queue.

## The rubric — use this copy verbatim

It must match the console and the DB column comments exactly; there is a contract test in the app
repo that pins these strings across surfaces. **Don't paraphrase, don't "improve" it.**

| axis | question | 1 · 3 · 5 |
|---|---|---|
| **Founder** | How insightful / formidable does team seem | would not back them · capable, not exceptional · would back them on any idea |
| **Market** | How much total pain, why now, who else? | small or structurally bad · real, but crowded · large, and why-now is now |
| **Idea** | Their answer - how much it relieves the pain | barely touches the pain · helps, but partial · the pain goes away |
| **Evidence** | Proof points so far | nothing demonstrated · early proof, small numbers · traction that speaks for itself |

**Overall recommendation — "Would I invest?"**

`1 strong reject · 2 weak reject · 3 weak invest · 4 invest · 5 strong invest`

**There is no neutral.** 1–2 reject, 3–5 invest — an unsure reviewer must lean. **Say so out loud
if they stall.** It also means a **3.0 average is a soft yes, not a midpoint** — don't report it as
"middling".

## The write

`submit_lead_feedback`, snake_case params:

`lead_id` · `recommendation_score` · `founder_score` · `founder_note` · `market_score` ·
`market_note` · `idea_score` · `idea_note` · `evidence_score` · `evidence_note` · `comments` ·
`red_flags` · `recording_url` · `reviewer_id` · `source` · `expected_updated_at`

- **All five scores are required**, 1–5. Notes are optional but they are **the point** — the note
  is where "couldn't really assess this" gets said, since a forced 3 can't distinguish *mediocre*
  from *don't know*.
- **Always pass `source: 'agent'`.**
- **Omit `reviewer_id`** — it defaults to the caller. Set it only when recording **someone else's**
  take, and then also pass `expected_updated_at` so you can't clobber an edit that landed since
  you read it.
- **It upserts.** Re-submitting for the same reviewer at the same stage **edits in place**
  (`operation: "updated"`). There is **no separate update tool and no version history — an edit
  overwrites.** **Say that out loud before overwriting someone's existing take.**
- **Branch on typed failures by name** — don't parse prose: `no_live_lead`, `not_direct_lead`,
  `missing_score` (carries `field`), `unknown_reviewer`, `bad_recording_url`, `bad_source`, and
  the `stale_write` conflict.
- `retract_lead_feedback(direct_feedback_id)` withdraws a take.

## Two traps

1. **A take is stage-grain: `(lead, reviewer, stage)`.** Scoring at `reviewing` does *not* mean the
   lead is scored once it reaches `diligence` — it needs a **fresh take there**. Never describe a
   lead as "already evaluated" without checking **which stage** the take was written at.
2. **Read coverage from `mcp.lead_evaluation_coverage`**, not by aggregating `mcp.direct_feedback`
   yourself. The view is already stage-grain; a hand-rolled **lead-grain** aggregate reports an
   average nobody wrote.

## Discipline

1. **Load the tools if deferred** (`ToolSearch` for "Iterator").
2. **Go straight to the lead tools** — no `describe_schema` for a normal run.
3. **Never invent a score.** If the human won't commit, **leave the lead and move on** — an
   unfiled evaluation is better than a fabricated one.
4. **Lists as markdown tables, never raw JSON** (house rule — see `/tinderate`).
5. **Confirm before filing**, and state plainly when you are about to **overwrite** an existing take.
6. **Don't answer from memory — query live.**

## If the queue filter isn't live yet

`find_leads(needs_take_from:)` and `mcp.lead_evaluation_coverage` ship in **PR #113** (open at the
time of writing). If they aren't available, fall back to `run_sql`: anti-join `mcp.lead_evaluations`
against Direct leads at `reviewing` / `diligence` — **and match on `stage_slug`**, or you reproduce
trap 1 and skip leads that need a fresh take at their new stage.

Criteria (optional — narrows the queue): $ARGUMENTS
