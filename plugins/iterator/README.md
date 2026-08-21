# iterator

Claude Code plugin for querying Iterative's **Iterator CRM** — founders, companies,
applications, cohorts, partner feedback, leads, and portfolio.

Installed as part of the `iterative` marketplace (see the [repo README](../../README.md)).

## Components

- **`.mcp.json`** — direct HTTPS connection to the Iterator MCP server (`type: http`,
  a Supabase edge function). OAuth is per-user and gated to `iterative.vc` emails; no
  credentials are stored here.
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

The first Iterator tool call opens a browser OAuth flow. Sign in with your **@iterative.vc**
Google account — the server gates on that domain, so a personal address is rejected. The token
is cached per user in `~/.claude/.credentials.json`, so this is a one-time step per machine.

### On a remote or headless machine (SSH, dev box, container)

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
> are silently ignored. Use one of the four methods above instead.

## Query conventions (baked into `/iterator`)

- `describe_schema` first — join paths are grant-driven and not guessable.
- `run_sql` for counting / aggregation / ranking; base tables for custom aggregation,
  `*_directory` / `*_active` projections for pre-derived flags.
- "Active cohort" = `cohort.status = 'recruiting'`, never a name match.
- Partner feedback lives one row per `partner × stage × application`; join
  `feedback → profile → person` to resolve a partner's name.
