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

## Card format (full detail, one per lead)

```
1. [SOURCED · ★2]  Tasklet — Andrew Lee  · repeat founder
   "AI agents that connect to your tools and run 24/7 to get real work done"
   B2B · San Francisco · team 8 · YC #31470
   Signals: $20M raise ($175M val) · $5M ARR, +1200% since Jan
   Launch: 39 votes · https://www.ycombinator.com/launches/PsX-tasklet-…
```

- **`[SOURCED · ★N]`** leading tag — `★N` shows shortlist count when >0 (why it's near the top);
  omit the star when zero.
- **Company — Founder**, with a short pedigree flag if notable (repeat founder, selected-employer
  alum).
- **One-liner** from the launch tagline / description (skip if none).
- **Meta:** industry · location · team size · source (+ YC id).
- **Signals:** the notable ones (raises, traction, contracts) — not every duplicate.
- **Launch:** votes + link when present.
- Blank line between cards so each reads as its own item.

## Discipline

1. **Load the tools if deferred** (`ToolSearch` for "Iterator").
2. **`describe_schema` first** — the real `lead.lane` / `lead.stage` / `shortlist` /
   `source` fields and enum values are grant-driven, not guessable.
3. **Use the Iterator lead tools** — e.g. `leads_summary` for the count, `find_leads`
   (`lane=direct, stage=sourced, owner=none`, ordered, `limit=10`) for the batch, `get_lead`
   for full detail, and the action verbs to act — falling back to `list_leads` / `get_lead` /
   `run_sql` where those aren't available. Reserve `run_sql` for the ordered id list or any
   aggregation the lead tools can't express.

Criteria (optional — narrows the queue, ordering stays shortlisted-first): $ARGUMENTS
