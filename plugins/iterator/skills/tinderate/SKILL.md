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
2. **Pull the next 10** in the order above and render them as a **table** (format below),
   numbered `1`–`10` so the user can act by number. Keep it scannable — one row per lead.
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

## Batch format (a table of 10)

Render the 10 as a compact **markdown table** — it renders in the terminal and scans fast for
rapid triage. **Every URL a clickable markdown link** (`[label](url)`), never bare text:

```
| # | Company | Founder | Focus | Top signal | Launch |
|--:|---------|---------|-------|-----------|--------|
| 1 ★2 | [Tasklet](https://tasklet.ai) | [Andrew Lee](https://linkedin.com/in/andrewlee) | B2B · SF | $20M raise ($175M val) | [39▲](https://www.ycombinator.com/launches/PsX-tasklet-…) · [▶](https://youtu.be/sriwtDYi6XQ) |
| 2 | [Clara](https://askclara.com) | [George Favvas](https://linkedin.com/in/gfavvas) | Healthcare · SF | $12M seed | [11▲](https://www.ycombinator.com/launches/QMs-clara-…) |
```

- **#** — the index to act by. Append the shortlist count as **★N** when >0 (why it's near the
  top; nothing when zero).
- **Company** → site (`website`/`domain`); **Founder** → `person.linkedin_url`; **Launch** →
  the top launch's votes linked to the post, plus `· [▶](video_url)` when there's media.
- **Focus** = industry · location. **Top signal** = the single strongest — the table is a scan.
- One line per lead. Don't wrap cells with paragraphs; that's what `expand` is for.

## Expand one (the full card)

On `expand <n>` (or when the user names a lead), show that single lead in full — a company with
its **founder(s)**, all **launches**, and all **signals**:

```
─ Tasklet · ★2 · SOURCED ────────────────────────────
**[Tasklet](https://tasklet.ai)** · B2B · San Francisco · 8 people · YC #31470
Andrew Lee — repeat founder — [LinkedIn ↗](https://linkedin.com/in/andrewlee)
"AI agents that connect to your tools and run 24/7 to get real work done"
Signals: $20M raise ($175M val) · $5M ARR (+1200% since Jan)
Launches
  • [The cloud agent OS for knowledge work](https://www.ycombinator.com/launches/PsX-tasklet-…) — 39 ▲ · [video ↗](https://youtu.be/sriwtDYi6XQ)
```

- **Company line:** name → site, then industry · location · team size · source (+ YC id).
- **Founder line(s):** one per founder — name, a pedigree flag if notable, and **[LinkedIn ↗]**
  → `person.linkedin_url`. List co-founders each on their own line. Link LinkedIn **only when a
  URL exists** — never invent one.
- **Pitch:** the launch tagline / one-liner (skip if none).
- **Signals:** the notable ones (raises, traction, contracts), deduped; link a `source_url`
  when useful.
- **Launches:** **every** launch (it's an array), each `• [tagline](launch_url) — N ▲` plus
  `· [video ↗](video_url)` per media; use `get_lead` for the full dossier if the batch payload
  is thin.

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
