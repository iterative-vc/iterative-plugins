---
name: porygon
description: Work the SF direct-deals (porygon) lead pipeline via Iterator — orient/explore/act on direct-lane leads (SF, porygon, unclaimed inbox, diligence, assign, shortlist, pass). Use for questions about the SF pipeline or direct deals.
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

If `$ARGUMENTS` is empty, **orient and stop** — give a human read of the pipeline, then ask
what they want. Orient with **aggregates**: the summary tool, plus one or two quick
aggregation queries (`run_sql`) when they help you characterize what's actually in there.
**Never list individual lead rows on a bare call** — a fresh import is hundreds of leads.

Write it like you're briefing a colleague, not filling in a form:

- **Open with one plain sentence** that states the real situation — the total and what's
  actually true of it (all one stage? all one source? anything owned / shortlisted / passed?
  how old?). No fixed template; say what's true.
- **Then show the breakdown that's actually informative.** A per-**stage** table earns its
  place only if leads really span stages. When the pipeline is lopsided — e.g. everything
  sitting in `sourced` — a stage table is noise (two rows and a total tells nobody anything);
  break down by a dimension that helps you triage instead: **industry, source, signal
  presence, geography, launch recency**. Use a clean box table when a breakdown helps.
- **Don't double-count or invent stages.** `to_triage` *is* the `sourced` / unclaimed leads —
  the same leads, not a separate bucket. **Shortlist is not a stage:** a shortlisted lead
  still sits in some stage (usually sourced or qualified), so treat shortlist as a personal
  cut, not a pipeline segment.
- **Interpret, then point at the usable cuts.** A line on the shape of it, then the handful of
  slices worth acting on (the leads carrying money signals, a geographic cluster, the loud
  launches) so they can triage by cluster, not row by row.
- **End by asking** what they want to pull.

Aim for this **tone, wrapping, and shape** — the content below is illustrative, *not* a
required set of columns; pick whatever breakdown the actual data makes interesting:

```
827 untriaged — that's the whole direct pipeline: every lead is sourced,
unclaimed, and unshortlisted. Zero owned, zero passed, oldest 0 days
(one import batch, 20260823, all YC).

What's in there

┌──────────────┬─────┬────────┬───────────┬──────────────┐
│ Industry     │  n  │ signal │ 100+ votes│ launched <30d│
├──────────────┼─────┼────────┼───────────┼──────────────┤
│ B2B          │ 487 │   23   │    34     │     109      │
│ Industrials  │ 130 │    6   │     7     │      40      │
│ …            │  …  │   …    │     …     │      …       │
└──────────────┴─────┴────────┴───────────┴──────────────┘

Shape of it: ~59% B2B, tiny teams, ~194 launched in the last 30 days.
Only 78 of 827 carry any signal — the rest are name + launch only.

Worth acting on: the ~43 with money signals (Tasklet, Clara, Drafted…),
a ~12-lead SEA cluster, and the loud-but-unannotated launches. Triage by
cluster, not row by row.

Want the money-signal cut, the SEA cluster, or a look at the raw inbox?
```

## Output discipline (lists → a markdown table, never raw JSON)

The lead tools return **big** rows (nested `signals`, `launches`, full company/founder
objects). Never echo that JSON. Render a list of leads as a compact **markdown table** — it
renders in the terminal and scans fast, one row per lead:

```
| # | Company | Founder | Focus | Top signal | Launch |
|--:|---------|---------|-------|-----------|--------|
| 1 ★ | [Tasklet](https://tasklet.ai) | [Andrew Lee](https://linkedin.com/in/andrewlee) | B2B · SF | $20M raise ($175M val) | [39▲](https://www.ycombinator.com/launches/PsX-tasklet-…) |
| 2 | [Clara](https://askclara.com) | [George Favvas](https://linkedin.com/in/gfavvas) | Healthcare · SF | $12M seed | [11▲](https://www.ycombinator.com/launches/QMs-clara-…) |
```

- **#** — a stable index so the user can act by number ("assign 1, pass 2"). Put a **★** by the
  number when the lead is shortlisted (`shortlist_count > 0`).
- **Company** links to its site (`website`/`domain`); **Founder** links to
  `person.linkedin_url`; **Launch** shows the top launch's votes linked to the post (append
  `· [▶](video_url)` when there's media). All markdown links so the terminal makes them clickable.
- **Focus** = industry · location. **Top signal** = the single strongest (largest raise /
  standout traction) — the table is a scan, not the full dossier.
- Add an **Owner** column when the view spans owners (drop it when everything's unclaimed).
- **Default ~10 rows.** If there are more, say how many and offer to narrow — don't fetch all.
- For the **full** dossier on a lead (every founder, every launch + media, all signals), use
  `/tinderate` or pull `get_lead` for a lead the user names.

**Founder LinkedIn** (`person.linkedin_url`) is populated for ~all direct leads. If the lead
payload doesn't include it, fetch it for the shown rows with one `run_sql` (`lead` → `person`
on `primary_contact_id`) rather than leaving the column blank.

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
3. **Use the Iterator lead tools, not guesses** — `find_leads` / `leads_summary` /
   `create_lead` / `get_lead` (all live in prod). Reserve `run_sql` for the LinkedIn join or
   aggregation the lead tools can't express (and check `describe_schema` first for the real
   `lead.lane` / `lead.stage` / `lead.lead_source` values before hand-writing filters).

Request (if empty, follow "No request given" above — summary only, then ask): $ARGUMENTS
