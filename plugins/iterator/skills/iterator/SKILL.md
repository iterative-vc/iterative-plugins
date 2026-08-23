---
name: iterator
description: Query the Iterator CRM (Iterative deal-flow / portfolio) via the Iterator MCP — founders, companies, applications, cohorts, partner feedback, leads, portfolio. Use for any question about Iterative's deal flow that should be answered from live CRM data rather than memory.
argument-hint: <question about founders, companies, applications, cohorts, or partner feedback>
---

You have access to the **Iterator MCP** — Iterative's CRM covering founders, companies,
applications, cohorts, partner feedback, leads, and portfolio. Answer the question below
using Iterator. **Do not answer from memory or guess** — query the live data.

The full Iterator toolset (load all of these if they're deferred — don't limit yourself to
`describe_schema`/`run_sql`):

- **`describe_schema`** — the catalog of everything `run_sql` can read (relations, columns, joins).
- **`run_sql`** — one read-only SELECT for ad-hoc analysis / aggregation / ranking.
- **`search`** — cross-entity semantic/text search when you don't know the exact record.
- **`journey`** — a company/founder's progression through the pipeline over time.
- **`list_applications`**, **`list_companies`**, **`list_leads`**, **`list_people`** — filtered list
  queries returning refs + totals (good for review-queue / directory-style questions).
- **`get_application`**, **`get_company`**, **`get_lead`**, **`get_person`**, **`get_thread`** —
  full detail for a single record (incl. LinkedIn threads).

Pick the narrowest tool that fits: `get_*`/`list_*`/`search`/`journey` for lookups and
directory questions; `run_sql` for anything that counts, aggregates, ranks, or joins across
entities.

## Leads: two lanes

Leads live in one `lead` table split by a **lane** column — know which lane a request means:

- **cohort** — the recruiting / batch pipeline. Spoken as "cohort/batch leads",
  "W27 / current cohort", "SEA leads" (SEA is a **geography** filter, not a lane).
  Stages: `sourced → contacted → engaged → applying → applied` (terminal: `dropped`).
- **direct** — the **SF direct-deals** pipeline, internally **porygon** (pod porygon).
  Spoken as "SF", "SF leads", "SF pipeline", "porygon". Stages:
  `sourced` (unclaimed inbox / triage) → `qualified` (claimed/shortlisted, owned) →
  `contacted` (we reached out) → `reviewing` (back-and-forth) → `diligence` (diligencing) →
  `committed` → `invested`; terminal: `passed` / `lost` / `no_allocation`.

**Action verbs:** **create** (add a lead, e.g. one that arrived by email), **assign**
(pick up a `sourced` lead → `qualified`, you own it), **shortlist/unshortlist** (personal
bookmark), **pass** (reject → terminal), **release** (return an owned lead to the pool).

**Sources:** each lead has a source — direct leads are mostly **YC** (`yc_intel`) plus
**email**. New feeds are additional direct **sources**, not new lanes.

**Phrase → intent:** "porygon leads in diligence" = direct lane, `stage = diligence`;
"current cohort SEA leads" = cohort lane, current cohort, location SEA; "what's unclaimed" =
direct lane, `stage = sourced`, `owner = none`.

To work leads, orient with a pipeline **summary**, then **explore** filtered by lane + stage
+ owner (me/none/name) + shortlist + source + geography + "new since last import", then
**act** with the verbs — via the Iterator **lead tools** (`find_leads` / `leads_summary` /
`create_lead` / `get_lead`, all live); use `run_sql` for the founder-LinkedIn join
(`person.linkedin_url`) or aggregation those can't express. `/porygon` is the dedicated SF
working loop.

Lead rows are **big** (nested `signals` / `launches` / company / founder) — never echo the
raw JSON. Render each lead as a **compact card**: a leading `[STAGE]` tag, then
`Company — Founder`, a one-liner from the tagline if any, a meta line (`source (+ YC id) ·
owner or unclaimed · industry · location`), and the strongest **Signal:** on its own line —
blank line between leads. Default ~10 and offer to narrow if there are more; pull full detail
(`get_lead`) only for a named lead. A pipeline that just imported can be hundreds of leads,
so lead with the **summary**, not a dump.

Workflow:

1. **Load the tools if needed.** The Iterator tools may be deferred. If they aren't already
   available, load them (e.g. `ToolSearch` for "Iterator", which surfaces the full set above).
2. **Call `describe_schema` before writing SQL.** Table names and join paths are grant-driven
   and not guessable. The schema is large — read it in chunks or via a subagent rather than
   dumping it inline.
3. **Use `run_sql` for any counting, aggregation, or ranking.** Use the base tables
   (`application`, `company`, `cohort`, `feedback`, `person`, `profile`) for custom aggregation;
   use the `*_directory` / `*_active` projections only for their pre-derived flags
   (`is_portfolio`, `has_applied`, `avg_recommendation`, …). Remember "active cohort" means
   `cohort.status = 'recruiting'`, never a name match.
4. **Report clearly.** When the answer involves partner feedback, name **who** gave it and
   show **all stages** (inbox_review / first_interview / final_interview), not just the latest.

Question: $ARGUMENTS
