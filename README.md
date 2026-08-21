# Iterative Claude Code plugins

A private [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) for
Iterative. Today it ships one plugin, **`iterator`**, which gives Claude Code first-class
access to the Iterator CRM (deal flow, founders, companies, applications, cohorts, partner
feedback, portfolio).

## What `iterator` gives you

| Piece | What it does |
|-------|--------------|
| **Iterator MCP connection** | A direct HTTPS connection to the Iterator MCP server. Auth is per-user OAuth (see below) — no secrets are stored in this repo. |
| **`/iterator <question>`** | A slash command for deliberate CRM queries. It forces the right flow: load tools → `describe_schema` → `run_sql`, and answer from live data instead of guessing. |
| **Keyword nudge (hook)** | A `UserPromptSubmit` hook that watches your prompt and, when it looks like a CRM / deal-flow question, reminds Claude to use Iterator — the backstop for when neither you nor Claude thinks to reach for it. |

The command is for when *you* know you want the CRM; the hook covers the times you don't.

## Install

```shell
# 1. Add this marketplace (use the private git URL you host this repo at,
#    a github owner/repo, or a local path while developing):
/plugin marketplace add <your-org>/iterator-plugin
#    e.g. /plugin marketplace add ./iterator-plugin   (local checkout)

# 2. Install the plugin:
/plugin install iterator@iterative
```

Update later with `/plugin marketplace update iterative`.

## Authentication (OAuth)

The Iterator MCP uses OAuth, and it is handled **per user, on your own machine** — this
repo contains **no tokens or credentials**.

- The first time you use an Iterator tool after installing, Claude Code sees the server
  needs authorization and opens the **OAuth flow in your browser**. You log in as yourself
  and approve; the resulting token is cached locally in your Claude Code credential store.
- Everyone authenticates as their own identity. Revoking one person never touches anyone else.
- **Interactive only:** the first-run OAuth flow needs a browser, so it can't complete in a
  headless / CI / cron context. Do the one-time auth in an interactive session first.

## Configure the MCP endpoint

Before publishing, set the real server URL in
[`plugins/iterator/.mcp.json`](plugins/iterator/.mcp.json):

```json
{
  "mcpServers": {
    "iterator": {
      "type": "http",
      "url": "https://REPLACE_WITH_ITERATOR_MCP_URL/mcp"
    }
  }
}
```

Replace `https://REPLACE_WITH_ITERATOR_MCP_URL/mcp` with Iterator's direct HTTPS MCP
endpoint. Leave out any `headers` / secrets — OAuth is negotiated at connect time.

## Hosting (private is fine)

A marketplace is just a git repo containing `.claude-plugin/marketplace.json`. It can be a
**private** GitHub / GitLab / Bitbucket / self-hosted repo — Claude Code clones it with each
user's own git credentials. Because the plugin folder lives *inside* this repo (referenced by
relative path in `marketplace.json`), users never need access to a second repository.

For Team/Enterprise distribution you can also push it via
**Organization settings → Plugins** so it's synced to everyone automatically.

## Repo layout

```
iterator-plugin/
├── .claude-plugin/
│   └── marketplace.json          # catalog: lists the iterator plugin
├── plugins/
│   └── iterator/
│       ├── .claude-plugin/
│       │   └── plugin.json        # plugin manifest
│       ├── .mcp.json              # Iterator MCP server (set the URL)
│       ├── commands/
│       │   └── iterator.md        # /iterator slash command
│       ├── hooks/
│       │   └── hooks.json         # registers the UserPromptSubmit hook
│       ├── scripts/
│       │   └── iterator-nudge.sh  # keyword nudge logic
│       └── README.md
└── README.md                      # this file
```

## Tuning the nudge

The hook's keyword list lives in
[`plugins/iterator/scripts/iterator-nudge.sh`](plugins/iterator/scripts/iterator-nudge.sh).
Broaden the `pattern` if real questions slip through; tighten it if you get nudged on
unrelated (e.g. coding) prompts. A false nudge only costs one injected line, so err toward
coverage.
