# iterator — deal flow & the SF pipeline, in plain English

This add-on connects Claude Code to the **Iterator CRM**. Two things you get:

- **Ask about deal flow** — founders, companies, applications, cohorts, partner feedback,
  the portfolio — and get answers from the live data instead of Claude guessing. → `/iterator`
- **Work the SF direct-deals lead pipeline** (internally **porygon**) — triage the inbox,
  see what's in diligence, claim and pass on deals. → `/porygon`

## Set it up

Everything here is typed **inside Claude Code**, not a terminal.

**1. Add the collection** (once per machine):

```
/plugin marketplace add iterative-vc/iterative-plugins
```

**2. Install the plugin:**

```
/plugin install iterator@iterative
```

When it asks *where* to install, choose **User scope** ("install for yourself across all
projects") — Iterator is a CRM you'll want from any project, not just one repo.

**3. Restart Claude Code** so it loads.

## Signing in

The first time you ask Iterator something, a browser tab opens. Sign in with your
**@iterative.vc** Google account — access is restricted to that domain, so a personal address
will be turned away. This happens **once per computer**. After that it just works.

(On a remote/headless box the browser step needs one extra move — see
[Running Claude Code on a remote server](#running-claude-code-on-a-remote-server).)

## 1. Ask about deal flow — `/iterator`

Put `/iterator` in front of a question, or just ask normally (see
[the nudge](#it-usually-knows-when-to-check) below):

```
/iterator how many companies applied to the current cohort?
/iterator what did partners say about <company>?
/iterator which companies applied more than once and still got in?
/iterator show me the highest-rated applications we passed on
/iterator summarize <partner>'s feedback style over the last 10 reviews
/iterator which portfolio companies came through the SF pipeline?
/iterator show <founder>'s journey from lead to today
```

## 2. Work the SF lead pipeline — `/porygon`

`/porygon` is the **SF direct-deals** working loop.

**Two lanes.** Leads split into two pipelines, and it matters which one you mean:

- **cohort** — the recruiting / batch pipeline (applications for a cohort). Spoken as
  "cohort/batch leads", "W27 / current cohort", "SEA leads" (SEA is a location filter here,
  not a separate pipeline).
- **direct** — the **SF direct-deals** pipeline, aka **porygon** / pod porygon. Spoken as
  "SF", "SF leads", "the SF pipeline", "porygon".

`/porygon` drives the **direct / SF** lane. `/iterator` covers both lanes plus the rest of
the CRM.

**The SF stages**, start to finish:

```
sourced → qualified → contacted → reviewing → diligence → committed → invested
```

`sourced` = unclaimed, sitting in the inbox. `qualified` = someone claimed it and owns it.
Then it moves through `contacted` → `reviewing` → `diligence` → `committed` → `invested`.
Dead ends: **passed** / **lost** / **no_allocation**.

**The things you do to a lead** (just say them):

- **create** — add a lead (e.g. one that arrived by email)
- **assign** — claim a `sourced` lead → it becomes `qualified` and you own it
- **shortlist / unshortlist** — a personal bookmark (doesn't move the stage)
- **pass** — reject it (→ a dead end)
- **release** — hand an owned lead back to the unclaimed pool

**Where leads come from** (the *source*): today SF leads are mostly **YC**, plus the odd
**email** lead. New feeds show up as new sources, not new lanes.

**Examples** — a Monday on the pod, a fresh batch of YC leads just landed:

_Orient_
```
/porygon
/porygon what came in since the last import
/porygon break the inbox down by industry
/porygon how many untriaged leads carry a real signal
```

_Triage the unclaimed inbox_
```
/porygon what's unclaimed
/porygon top unclaimed leads by launch votes
/porygon unclaimed B2B leads that raised recently
/porygon the SEA cluster in the current inbox
```

_Explore_
```
/porygon SF leads in diligence
/porygon everything past first contact (contacted → committed)
/porygon leads owned by Jordan
/porygon anything with a $10M+ raise signal
/porygon healthcare leads in reviewing or diligence
```

_Act (the verbs)_
```
/porygon assign the Tasklet lead to me
/porygon shortlist RonanRx
/porygon pass on the ones with no signal and a tiny team
/porygon release the Billow lead back to the pool
/porygon a founder emailed me — add Acme (acme.ai) as an SF lead, source email
```

_Your queue / drill in_
```
/porygon my leads in diligence
/porygon my shortlist
/porygon anything of mine gone stale — no movement in 2 weeks
/porygon full detail on Tasklet
```

The usual rhythm is **orient → explore → act**: start with a summary of what's in each stage,
narrow down (by stage, owner, source, location, "new since last import"…), then act with the
verbs above.

### Blitz the inbox — `/tinderate`

When you just want to clear the unclaimed inbox, `/tinderate` walks it **10 at a time** in
full detail — **shortlisted-by-anyone first**, then the strongest leads — and you `assign`,
`shortlist`, or `pass` your way through, `next` for the next 10. Pass a filter to narrow it:

```
/tinderate
/tinderate SEA founders
/tinderate B2B with a raise signal
```

## It usually knows when to check

You don't have to prefix everything. When a question *sounds* like a CRM or lead question —
"how's deal flow this batch?", "any new SF leads?", "what's in porygon?" — Claude gets a quiet
reminder to check Iterator rather than answer from memory, and usually does the right thing on
its own. The slash commands (`/iterator`, `/porygon`) just make it explicit and load
the full playbook.

## How it answers

Two house rules are built in, so you don't have to ask:

- **Partner feedback always names who said it** — not just "the feedback was positive."
- **All review stages are shown** (inbox review, first interview, final interview), not only
  the most recent one.

If Claude ever gives you a number without saying where it came from, ask it to show the query.
It's reading real records and can always show its work.

## If something isn't working

- **Claude answers without checking the CRM** — say "use Iterator" explicitly, or start with
  `/iterator` / `/porygon`.
- **Sign-in fails** — it must be your `@iterative.vc` account.
- **`/iterator` or `/porygon` isn't recognized** — restart Claude Code after installing.
- **A fix or new command isn't showing up** — you're still on the version you launched with.
  Run `/plugin marketplace update iterative` then `/reload-plugins` (add `--force` if it asks,
  or just restart). Updates on disk don't apply to the running session until you reload.
- **It says it can't find a table or field** — the CRM's structure changes; ask it to re-check
  the schema and try again.

---

## Under the hood

**Components**

- **`.mcp.json`** — direct HTTPS connection to the Iterator MCP server (`type: http`,
  a Supabase edge function). OAuth is per-user and gated to `iterative.vc` emails; no
  credentials are stored here.
- **`skills/iterator/SKILL.md`** — the `/iterator <question>` command. Carries the full
  toolset guidance and the **two-lane leads model** (cohort vs direct/SF), and enforces:
  load tools → `describe_schema` → the Iterator tools / `run_sql`, answer from live data, and
  (per house style) name who gave feedback and show all stages.
- **`skills/porygon/SKILL.md`** — the SF direct-deals (porygon) working loop: the direct-lane
  stages, the action verbs, sources, and the orient→explore→act flow.
- **`skills/tinderate/SKILL.md`** — a triage loop over the unclaimed `sourced` inbox: 10
  full-detail cards at a time, shortlisted-first, then assign / shortlist / pass and `next`.
  Manual-only (`disable-model-invocation: true`) — you start a tinderate session deliberately.
- These ship as **skills** (not `commands/`) so each works both bare (`/porygon`) and
  namespaced (`/iterator:porygon`); a plain command only registers the namespaced form. Both
  are **model-invocable** — Claude can reach for them on its own when a question fits their
  `description` (e.g. "how's the SF pipeline?"), as well as when you type them.
- **`hooks/hooks.json`** + **`scripts/iterator-nudge.sh`** — a `UserPromptSubmit` hook that
  injects a reminder to use Iterator when a prompt looks like a CRM / deal-flow / **lead**
  question (it matches lead / SF / porygon vocabulary too), and hands Claude the lane model.

**Query conventions** (baked into the commands)

- `describe_schema` first — join paths and enum values are grant-driven and not guessable.
- Prefer the Iterator **lead tools** for lead work; use `run_sql` for counting / aggregation /
  ranking the tools can't express. Base tables for custom aggregation, `*_directory` /
  `*_active` projections for pre-derived flags.
- "Active cohort" = `cohort.status = 'recruiting'`, never a name match.
- Leads live in one `lead` table split by a `lane` column (`cohort` vs `direct`); the SF lane
  is `direct`. Partner feedback lives one row per `partner × stage × application`; join
  `feedback → profile → person` to resolve a partner's name.

> **Tool availability.** The lead-specific tools are rolling out; the guidance names them as
> examples (`find_leads` / `leads_summary` / `create_lead`) but falls back to the always-present
> `list_leads` / `get_lead` / `run_sql`, so the commands work whatever the server currently
> exposes.

### Running Claude Code on a remote server

This only applies when Claude Code runs somewhere other than the machine with your browser.

Claude Code receives the OAuth code on a **local** callback listener at
`http://localhost:3118/callback`. "localhost" means the machine running Claude Code — so if you
open the auth URL in your laptop's browser while CC runs on a remote box, the redirect lands on
the wrong machine and the login never completes. Pick whichever fits:

**1. VS Code / Cursor Remote-SSH** — nothing to do. Port forwarding is automatic; run Claude
Code in the integrated terminal and authenticate normally. Easiest option if you already work
this way.

**2. SSH tunnel** — the plain-CLI answer. The callback port is fixed at 3118:

```bash
ssh -t -L 3118:localhost:3118 you@devbox
```

Then use Iterator inside that session and authenticate as usual. (`-t` matters: the auth prompt
needs a real TTY.) Already connected without the tunnel? Press `~C` on a fresh line and type
`-L 3118:localhost:3118` — the callback only fires after you approve in the browser, so adding
it mid-flow works.

**3. Complete the callback by hand** — no tunnel required. Let the redirect fail in your
laptop's browser, copy the full URL out of the address bar, and run this on the remote box:

```bash
curl "http://localhost:3118/callback?code=...&state=..."
```

The waiting listener picks it up. Move quickly — authorization codes are single-use and expire
in about a minute.

**4. Copy the credential** — authenticate once on your laptop, then copy the `iterator` entry
under `mcpOAuth` in `~/.claude/.credentials.json` across. No browser needed on the remote at
all. You are moving a live credential, so `scp` it rather than pasting it anywhere, and keep
the file at mode `600`.

> **`claude mcp login --no-browser` does not work against this server.** The flag exists for
> exactly this case, but as of Claude Code 2.1.237 it builds OAuth URLs from the domain root
> (`/authorize`, `/register`) instead of the endpoints the server advertises under
> `/auth/v1/oauth/*` — our issuer sits at a subpath, and the path gets dropped. Both requests
> return 404. There is no client-side override: `authorizationUrl` / `tokenUrl` in `.mcp.json`
> are silently ignored. Upstream: anthropics/claude-code#80731 and #85897.
