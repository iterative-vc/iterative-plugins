---
description: Query the Iterator CRM (Iterative deal-flow / portfolio) via the Iterator MCP
argument-hint: <question about founders, companies, applications, cohorts, or partner feedback>
---

You have access to the **Iterator MCP** — Iterative's CRM covering founders, companies,
applications, cohorts, partner feedback, leads, and portfolio. Answer the question below
using Iterator. **Do not answer from memory or guess** — query the live data.

Workflow:

1. **Load the tools if needed.** The Iterator tools may be deferred. If they aren't already
   available, load them (e.g. `ToolSearch` for "Iterator", or select `describe_schema`,
   `run_sql`, `list_applications`, `list_companies`, `list_people`, `get_*`, `search`).
2. **Call `describe_schema` before writing SQL.** Table names and join paths are grant-driven
   and not guessable. The schema is large — read it in chunks or via a subagent rather than
   dumping it inline.
3. **Prefer `run_sql` for any counting, aggregation, or ranking.** Use the base tables
   (`application`, `company`, `cohort`, `feedback`, `person`, `profile`) for custom aggregation;
   use the `*_directory` / `*_active` projections only for their pre-derived flags
   (`is_portfolio`, `has_applied`, `avg_recommendation`, …). Remember "active cohort" means
   `cohort.status = 'recruiting'`, never a name match.
4. **Report clearly.** When the answer involves partner feedback, name **who** gave it and
   show **all stages** (inbox_review / first_interview / final_interview), not just the latest.

Question: $ARGUMENTS
