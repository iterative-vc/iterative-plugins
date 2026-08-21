# iterator — ask questions about our deal flow

This add-on connects Claude Code to the **Iterator CRM**, so you can ask about founders,
companies, applications, cohorts, partner feedback, leads and the portfolio in plain English
and get answers from the live data — not from Claude guessing.

## Install it

Type these **inside Claude Code** (see the [main README](../../README.md) if you haven't added
the collection yet), then restart Claude Code:

```
/plugin install iterator@iterative
```

## Signing in

The first time you ask Iterator something, a browser tab opens. Sign in with your
**@iterative.vc** Google account — access is restricted to that domain, so a personal address
will be turned away.

This happens **once per computer**. After that it just works.

## Things you can ask

Put `/iterator` in front of your question:

```
/iterator how many companies applied to the current cohort?
/iterator what did partners say about <company>?
/iterator which companies applied more than once and still got in?
/iterator show me the highest-rated applications we passed on
/iterator summarize <partner>'s feedback style over the last 10 reviews
```

You can also just ask normally. If your question sounds like a CRM question, Claude gets a
quiet reminder to check Iterator rather than answer from memory — so "how's deal flow looking
this batch?" usually does the right thing on its own.

## How it answers

Two house rules are built in, so you don't have to ask for them:

- **Partner feedback always names who said it** — not just "the feedback was positive."
- **All review stages are shown** (inbox review, first interview, final interview), not only
  the most recent one.

If Claude ever gives you a number without saying where it came from, ask it to show the query.
It's reading real records and can always show its work.

## If something isn't working

- **Claude answers without checking the CRM** — say "use Iterator" explicitly, or start the
  question with `/iterator`.
- **Sign-in fails** — it must be your `@iterative.vc` account.
- **`/iterator` isn't recognized** — restart Claude Code after installing.
- **It says it can't find a table or field** — the CRM's structure changes; ask it to re-check
  the schema and try again.

---

## Under the hood

**Components**

- **`.mcp.json`** — direct HTTPS connection to the Iterator MCP server (`type: http`,
  a Supabase edge function). OAuth is per-user and gated to `iterative.vc` emails; no
  credentials are stored here.
- **`commands/iterator.md`** — the `/iterator <question>` slash command. Enforces:
  load tools → `describe_schema` → `run_sql`, answer from live data, and (per house style)
  name who gave feedback and show all stages.
- **`hooks/hooks.json`** + **`scripts/iterator-nudge.sh`** — a `UserPromptSubmit` hook that
  injects a reminder to use Iterator when the prompt looks like a CRM / deal-flow question.

**Query conventions** (baked into `/iterator`)

- `describe_schema` first — join paths are grant-driven and not guessable.
- `run_sql` for counting / aggregation / ranking; base tables for custom aggregation,
  `*_directory` / `*_active` projections for pre-derived flags.
- "Active cohort" = `cohort.status = 'recruiting'`, never a name match.
- Partner feedback lives one row per `partner × stage × application`; join
  `feedback → profile → person` to resolve a partner's name.

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
