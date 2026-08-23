---
name: tinderate
description: Triage the unclaimed SF (porygon) inbox 10 at a time — full-detail cards, shortlisted-first, then assign / shortlist / pass your way through. Optional criteria narrow the queue.
argument-hint: <optional criteria to narrow the queue — e.g. "SEA", "B2B with a raise", "100+ launch votes">
disable-model-invocation: true
---

You are running **tinderate** — a focused triage loop over the **SF direct-deals (porygon)**
inbox. It walks the **unclaimed `sourced`** leads **10 at a time**, in full detail, so a human
can rapidly **assign / shortlist / pass** through them. This is a working session, not a report:
show a batch, act on the user's calls, then show the next batch.

Query the live data with the Iterator lead tools — **never guess**.

## The queue

- **Scope:** direct lane, `stage = sourced`, `owner = none` (unclaimed / untriaged). Nothing
  else — a claimed or passed lead has left this queue.
- **Order (this is the point):**
  1. **Shortlisted by anyone first** — `shortlist_count > 0`, highest first. These are leads
     a teammate already flagged; they lead the queue.
  2. then the strongest leads — by signal (largest raise / clearest traction), material rank,
     and launch votes.
  The order must be **deterministic and stable** so "next" never re-shows a lead. If the lead
  tool can't sort by `shortlist_count`, get the ordered id list with `run_sql`, then pull each
  lead's detail.
- **User criteria (`$ARGUMENTS`):** if given, treat as an extra filter on the queue — industry,
  geography (e.g. SEA/Singapore), signal type, min raise, launch recency, etc. Keep the
  shortlisted-first ordering within the filtered set.

## The loop

1. **Orient (one line).** How many unclaimed sourced leads match right now, and how many of
   those are shortlisted. E.g. `312 unclaimed match "SEA" — 4 shortlisted. Here are the first 10:`
2. **Pull the next 10** in the order above and render them as **full cards** (format below),
   numbered `1`–`10`. Pull full detail (`get_lead`) when the list payload isn't enough.
3. **Offer the actions**, then **stop and wait** — don't act until the user replies:
   ```
   Reply: assign <n…> · shortlist <n…> · pass <n…> · next · or a new filter (e.g. "only SEA")
   ```
4. **Apply what they say** with the verbs (assign → claim to `qualified`, you own it;
   shortlist/unshortlist; pass → terminal). Confirm briefly what changed.
5. **On `next`**, **re-query the live unclaimed set** (so anything just assigned/passed is gone)
   and show the next 10 in order. Keep going until the queue is empty or they stop.

Never dump the whole inbox — **at most 10 cards per turn.** A batch can be one import of many
hundreds of leads.

## Card format (one rich card per lead)

Each lead is a **company** with **founder(s)**, **launch(es)**, and **signals** — lay it out as
a sectioned card, not a table. **Render every URL as a clickable markdown link** (`[label](url)`),
never bare text: the company site, each founder's LinkedIn, and each launch's post + media.

```
─ 1 · ★2 · SOURCED ─────────────────────────────────
**[Tasklet](https://tasklet.ai)** · B2B · San Francisco · 8 people · YC #31470
Andrew Lee — repeat founder — [LinkedIn ↗](https://linkedin.com/in/andrewlee)
"AI agents that connect to your tools and run 24/7 to get real work done"
Signals: $20M raise ($175M val) · $5M ARR (+1200% since Jan)
Launches
  • [The cloud agent OS for knowledge work](https://www.ycombinator.com/launches/PsX-tasklet-…) — 39 ▲ · [video ↗](https://youtu.be/sriwtDYi6XQ)
```

- **Header rule:** `─ <#> · ★<N> · <STAGE> ─…` — `<#>` is the index for acting by number,
  `★<N>` shows the shortlist count when >0 (why it's near the top; omit the star at zero).
- **Company line:** company name linked to its `website`/`domain`, then industry · location ·
  team size · source (+ YC id).
- **Founder line(s):** one per founder — name, a pedigree flag if notable (repeat founder,
  selected-employer alum), and **[LinkedIn ↗]** linked to `person.linkedin_url`. A lead can
  have co-founders; list each on its own line. Link LinkedIn **only when a URL exists** — never
  invent one; omit the link if missing.
- **Pitch:** the launch tagline / one-liner (skip if none).
- **Signals:** the notable ones (raises, traction, contracts), deduped — not every row; link a
  signal's `source_url` when useful.
- **Launches:** list **every** launch (it's an array), each `• [tagline](launch_url) — N ▲`
  plus `· [video ↗](video_url)` for each media; drop the video part when there's none.
- Blank line between cards.

## Discipline

1. **Load the tools if deferred** (`ToolSearch` for "Iterator").
2. **`describe_schema` first** — the real `lane` / `stage` / shortlist / `source` fields and
   enum values are grant-driven, not guessable.
3. **Use the Iterator lead tools** (all live in prod): `leads_summary` for the count,
   `find_leads` (`lane=direct, stage=sourced, owner=none`, ordered, `limit=10`) for the batch,
   `get_lead` for full detail, the action verbs to act. Reserve `run_sql` for the ordered id
   list, the LinkedIn join, or aggregation the tools can't express.
4. **Founder LinkedIn:** `person.linkedin_url` is populated for ~all direct leads. If a batch's
   `find_leads` rows don't carry it, fetch it in **one** `run_sql` for the 10 shown leads
   (`lead` → `person` on `primary_contact_id`) — don't do a `get_person` per lead.

Criteria (optional — narrows the queue, ordering stays shortlisted-first): $ARGUMENTS
