---
name: tinderate
description: Triage the unclaimed SF (porygon) inbox 10 at a time — a scannable table, shortlisted-first, then assign / shortlist / pass / expand your way through. Optional criteria narrow the queue.
argument-hint: <optional criteria to narrow the queue — e.g. "SEA", "B2B with a raise", "100+ launch votes">
disable-model-invocation: true
---

You are running **tinderate** — a focused triage loop over the **SF direct-deals (porygon)**
inbox. It walks the **unclaimed `sourced`** leads **10 at a time** as a scannable table, so a
human can rapidly **assign / shortlist / pass** through them (and **expand** any one for the
full card). This is a working session, not a report: show a batch, act on the user's calls,
then show the next batch.

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
2. **Pull the next 10** in the order above and render them as a **scannable list** (below),
   numbered `1`–`10` so the user can act by number.
3. **Offer the actions**, then **stop and wait** — don't act until the user replies:
   ```
   Reply: assign <n…> · shortlist <n…> · pass <n…> · expand <n> · next · or a new filter (e.g. "only SEA")
   ```
4. **Apply what they say** with the verbs (assign → claim to `qualified`, you own it;
   shortlist/unshortlist; pass → terminal). `expand <n>` shows that one lead's full card (below).
   Confirm briefly what changed.
5. **On `next`**, **re-query the live unclaimed set** (so anything just assigned/passed is gone)
   and show the next 10 in order. Keep going until the queue is empty or they stop.

Never dump the whole inbox — **at most 10 rows per turn.** A batch can be one import of many
hundreds of leads.

## Rendering — principles, not a fixed template

Use your judgment on layout; the goal is fast triage, not a pixel-perfect spec.

**The batch (10 leads):** a **scannable list** — a compact markdown table is usually right; a
tight one-or-two-line block per lead is fine when the one-liner earns its place (let it wrap).
Per lead show only what aids a decision: the **index** (with **★N** when shortlisted), the
**company**, **founder(s)**, **focus** (industry · location), the **top signal**, and the
**launch(es)** (votes). **Keep the batch clean — no long URLs here.**

**`expand <n>` (one lead in full):** the whole dossier — company, **every founder**, the
one-liner (let it wrap), **all signals**, and **every launch** with its post + video. Here,
show links as **raw URLs** (company site, each founder `person.linkedin_url`, each launch post
+ `video_url`), not `[label](url)` — hidden-label links render as unclickable decorative text
in some terminals (e.g. SSH iTerm2), so a visible URL is both openable and copyable. Never
invent a URL; omit what's missing. `get_lead` backs the full dossier.

## Discipline

1. **Load the tools if deferred** (`ToolSearch` for "Iterator").
2. **Go straight to the lead tools — don't call `describe_schema` for a normal run.** You know
   the filters (`lane=direct, stage=sourced, owner=none`). Reach for `describe_schema` only if a
   query needs an unfamiliar column, and read it **via a subagent** — never dump the blob inline.
3. **Use the Iterator lead tools** (all live in prod): `leads_summary` for the count,
   `find_leads` (`lane=direct, stage=sourced, owner=none`, ordered, `limit=10`) for the batch,
   `get_lead` for full detail, the action verbs to act. Reserve `run_sql` for the ordered id
   list, the LinkedIn join, or aggregation the tools can't express.
4. **Founder LinkedIn:** `person.linkedin_url` is populated for ~all direct leads. If a batch's
   `find_leads` rows don't carry it, fetch it in **one** `run_sql` for the 10 shown leads
   (`lead` → `person` on `primary_contact_id`) — don't do a `get_person` per lead.

Criteria (optional — narrows the queue, ordering stays shortlisted-first): $ARGUMENTS
