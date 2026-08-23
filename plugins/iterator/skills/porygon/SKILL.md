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

If `$ARGUMENTS` is empty: **call `leads_summary` once, render it in plain language, and stop.**
That's the whole turn. **Do not** call `describe_schema`, **do not** run `run_sql`, **do not**
call `find_leads` or list any leads — one tool call, then a human readout and an offer. The
extra schema-loading and aggregation is exactly the noise to avoid on a bare orient.

`leads_summary` already gives you everything the readout needs — `by_stage`, `to_triage`,
`new` (count + batch), `mine` (owned/shortlist/watching), `by_source`. Turn that JSON into two
or three sentences a colleague would say out loud:

- **State what's actually true:** the total, whether it's all one stage / one source / one
  import, how much you own or have shortlisted, anything past triage. `to_triage` *is* the
  `sourced`/unclaimed set — don't double-count it as a separate bucket. Shortlist is a personal
  cut, not a stage.
- **Then offer the next move** — a deeper breakdown, the triage queue, or a specific slice —
  and let the user pick. Only *then* do you spend queries.

```
827 leads in the SF pipeline — all sourced and untriaged, one import
(batch 20260823, all YC). You own 0, shortlisted 0; nothing's moved past triage.

Want a breakdown (by industry, or just the ones carrying signals),
the triage queue (/tinderate), or a specific slice?
```

**If they then ask for a breakdown**, aggregate with `run_sql` over the base tables — you do
**not** need `describe_schema` for this, and never grep a saved describe_schema result file.
The join you need: `lead l` (where `l.lane = 'direct'`) → `company c on c.id = l.company_id`
for `c.industry` / `c.location` / `c.team_size`, → `person p on p.id = l.primary_contact_id`
for the founder, and `l.lead_source` / `l.source_batch` / `l.current_stage_id` /
`l.owner_user_id` on the lead itself. Signals/launches live in `company_signal` and
`company_launch` (keyed by `company_id`) — only if you need those columns, glance at
`describe_schema` **via a subagent** rather than dumping it into this conversation. Present the
result as a compact box table + a "shape of it" line + the usable cuts (money-signal leads, a
geo cluster, loud launches), so they triage by cluster, not row by row.

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
2. **`describe_schema` only when you actually need an unfamiliar join** — and read it **via a
   subagent**, never dump the whole blob into the conversation or grep a saved result file.
   The lead columns above (`lead.lane` / `company_id` / `primary_contact_id` / `lead_source` /
   `source_batch` / `current_stage_id` / `owner_user_id`, `company.industry` / `location` /
   `team_size`, `person.linkedin_url`) are known — use them directly, no schema call.
3. **Use the Iterator lead tools, not guesses** — `find_leads` / `leads_summary` /
   `create_lead` / `get_lead` (all live in prod). Reserve `run_sql` for the LinkedIn join or
   aggregation the lead tools can't express.

Request (if empty, follow "No request given" above — summary only, then ask): $ARGUMENTS
