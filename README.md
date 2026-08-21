# Iterative plugins for Claude Code

Shared add-ons for Claude Code, built by and for the Iterative team. Add the collection once
and you can install anything the team has built — starting with the ability to ask questions
about our deal flow in plain English and get real answers from the CRM.

**You don't need to be an engineer to use any of this.**

## What's available

| Add-on | What it gives you |
|--------|-------------------|
| **iterator** | Ask about founders, companies, applications, cohorts, partner feedback and the portfolio. Claude queries the real Iterator CRM instead of guessing. [More ›](plugins/iterator/README.md) |

_More to come — see [Adding your own](#adding-your-own)._

## Set it up (about two minutes)

Everything below is typed **inside Claude Code**, not in a terminal. Open Claude Code, type
the line, press enter.

**1. Add the collection.** You only ever do this once:

```
/plugin marketplace add Iterative-VC/iterative-plugins
```

**2. Install what you want:**

```
/plugin install iterator@iterative
```

**3. Restart Claude Code** so it picks everything up.

Done. The first time you ask Iterator a question, a browser tab opens asking you to sign in —
use your **@iterative.vc** Google account. That's once per computer, not once per session.

> **Why the `@iterative` bit?** That's the name of our collection, and it stays the same even
> if the repo moves. Installs are always `<name>@iterative`.

## Getting updates

When someone adds a new add-on or improves an existing one:

```
/plugin marketplace update iterative
```

## If something isn't working

- **"Unknown command" when you type `/plugin`** — you're probably in a normal terminal rather
  than Claude Code, or on claude.ai in a browser. These commands only work in Claude Code.
- **Installed it but nothing happens** — restart Claude Code. Add-ons load at startup.
- **Sign-in rejected** — it has to be your `@iterative.vc` account. Personal Gmail won't work.
- **Still stuck** — ask in the team channel. Someone has probably hit it already.

## Adding your own

If you've worked out something useful in Claude Code — a prompt you keep reusing, a workflow,
a set of rules you want Claude to follow — it can live here so everyone gets it.

You don't have to be an engineer. The smallest useful contribution is a single text file
describing how you want Claude to handle something. [CONTRIBUTING.md](CONTRIBUTING.md) walks
through it.

---

## For engineers

**Repo layout**

```
iterative-plugins/
├── .claude-plugin/
│   └── marketplace.json      # the catalog — one entry per plugin
├── plugins/
│   ├── iterator/             # the Iterator CRM plugin
│   └── _template/            # copy this to start a new plugin (not installable)
├── CONTRIBUTING.md
└── README.md                 # this file
```

It's a standard [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
A plugin can bundle any mix of commands, skills, agents, hooks, and MCP servers — including a
plugin that is *just* a skill or *just* a command. Local checkout for development:
`/plugin marketplace add /absolute/path/to/iterative-plugins`.

**Notes**

- **Auth / secrets:** plugins never store credentials. MCP servers use per-user OAuth (e.g.
  Iterator's is gated to `iterative.vc` emails and OAuths in your browser on first use). See
  each plugin's own README.
- **Remote / headless machines:** OAuth completes on a local callback listener, so running a
  plugin over SSH needs one extra step. See
  [the iterator README](plugins/iterator/README.md#running-claude-code-on-a-remote-server).
- **Public repo:** hosting this publicly lets the team add it with no login. It contains no
  secrets by design — only pointers (URLs) and code. Anything sensitive stays behind each
  server's own auth.
- **Hooks execute code** on each user's machine. Keep hook scripts small and readable; that's
  the trust boundary for a shared marketplace.
