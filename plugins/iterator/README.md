# iterator

Claude Code plugin for querying Iterative's **Iterator CRM** — founders, companies,
applications, cohorts, partner feedback, leads, and portfolio.

Installed as part of the `iterative` marketplace (see the [repo README](../../README.md)).

## Components

- **`.mcp.json`** — direct HTTPS connection to the Iterator MCP server (`type: http`).
  OAuth is per-user; no credentials are stored here. **Set the real URL before publishing.**
- **`commands/iterator.md`** — the `/iterator <question>` slash command. Enforces:
  load tools → `describe_schema` → `run_sql`, answer from live data, and (per house style)
  name who gave feedback and show all stages.
- **`hooks/hooks.json`** + **`scripts/iterator-nudge.sh`** — a `UserPromptSubmit` hook that
  injects a reminder to use Iterator when the prompt looks like a CRM / deal-flow question.

## Usage

```
/iterator which companies applied the most times and still got in?
/iterator show the last 10 feedback rows from <partner> and summarize their style
```

Or just ask normally — if the prompt trips the keyword nudge, Claude gets reminded to reach
for Iterator on its own.

## Auth

First Iterator tool call triggers a browser OAuth flow; the token is cached locally per user.
Interactive sessions only (won't complete headless). See the repo README for details.

## Query conventions (baked into `/iterator`)

- `describe_schema` first — join paths are grant-driven and not guessable.
- `run_sql` for counting / aggregation / ranking; base tables for custom aggregation,
  `*_directory` / `*_active` projections for pre-derived flags.
- "Active cohort" = `cohort.status = 'recruiting'`, never a name match.
- Partner feedback lives one row per `partner × stage × application`; join
  `feedback → profile → person` to resolve a partner's name.
