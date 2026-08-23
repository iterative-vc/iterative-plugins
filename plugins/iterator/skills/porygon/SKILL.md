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
That's the whole turn — **no `describe_schema`, no `run_sql`, no `find_leads`, no lead listing.**
The extra schema-loading and aggregation is exactly the noise to avoid on a bare orient.

`leads_summary` already carries everything the readout needs — `by_stage`, `to_triage`, `new`
(count + batch), `mine` (owned/shortlist/watching), `by_source`. Turn that into two or three
sentences a colleague would say out loud:

- **State what's true:** the total, whether it's all one stage / one source / one import, how
  much you own or shortlisted, anything past triage. `to_triage` *is* the `sourced`/unclaimed
  set — don't double-count it. Shortlist is a personal cut, not a stage.
- **Then offer the next move** — a deeper breakdown, the triage queue (`/tinderate`), or a
  specific slice — and let the user pick. Only *then* do you spend queries.

```
827 leads in the SF pipeline — all sourced and untriaged, one import
(batch 20260823, all YC). You own 0, shortlisted 0; nothing's moved past triage.

Want a breakdown (by industry, or just the ones carrying signals),
the triage queue (/tinderate), or a specific slice?
```

**If they then ask for a breakdown**, aggregate with `run_sql` over the base tables — you do
**not** need `describe_schema`, and never grep a saved describe_schema result file. The join:
`lead l` (`l.lane = 'direct'`) → `company c on c.id = l.company_id` for `c.industry` /
`c.location` / `c.team_size`, → `person p on p.id = l.primary_contact_id` for the founder;
`l.lead_source` / `l.source_batch` / `l.current_stage_id` / `l.owner_user_id` are on the lead.
Signals/launches are in `company_signal` / `company_launch` (keyed by `company_id`) — only if
you need those columns, glance at `describe_schema` **via a subagent**, never dumped inline.

## Rendering a list — principles, not a fixed template

Never echo raw JSON (the rows are big — nested signals, launches, company/founder). Make a list
**scannable** and use your judgment on layout:

- A compact **markdown table** is usually right (it renders in the terminal and scans fast); a
  tight one-or-two-line block per lead is fine when a one-liner earns its place — let text wrap,
  don't cram it into a cell.
- Per lead, carry only what aids a decision: an **index to act by** (with **★** when shortlisted,
  `shortlist_count > 0`), the **company**, **founder(s)**, **focus** (industry · location), the
  **strongest signal**, and the **launch(es)** (votes). Add an owner column only when the view
  spans owners.
- **Keep the list clean — no long URLs here.** The full dossier (all founders, every launch +
  media, all signals) with **raw, copyable URLs** is what `/tinderate`'s expand and `get_lead`
  are for. (Raw URLs, not `[label](url)`: hidden-label links render as unclickable decorative
  text in some terminals, e.g. SSH iTerm2.)
- **Cap at ~10.** If there are more, say how many and offer to narrow — never dump the inbox.

Founder LinkedIn is `person.linkedin_url` (populated for ~all direct leads); if a payload lacks
it, one `run_sql` (`lead` → `person` on `primary_contact_id`) fills it — don't invent URLs.

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
2. **`describe_schema` only for an unfamiliar join** — and read it **via a subagent**, never
   dump the blob into the conversation or grep a saved result file. The lead columns above
   (`lead.lane` / `company_id` / `primary_contact_id` / `lead_source` / `source_batch` /
   `current_stage_id` / `owner_user_id`, `company.industry` / `location` / `team_size`,
   `person.linkedin_url`) are known — use them directly, no schema call.
3. **Use the Iterator lead tools, not guesses** — `find_leads` / `leads_summary` /
   `create_lead` / `get_lead` (all live in prod). Reserve `run_sql` for the LinkedIn join or
   aggregation the lead tools can't express.

Request (if empty, follow "No request given" above — summary only, then ask): $ARGUMENTS
