# iterative-plugins

Iterative's shared [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
One repo, many plugins — add the marketplace once and install any plugin the team ships
(CRM access, skills, commands, hooks). Contributions welcome from anyone on the team; see
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Install the marketplace (once)

```shell
# Public GitHub:
/plugin marketplace add Iterative-VC/iterative-plugins

# …or a local checkout while developing:
/plugin marketplace add /absolute/path/to/iterative-plugins
```

Then install whatever you want and refresh when new plugins land:

```shell
/plugin install iterator@iterative
/plugin marketplace update iterative
```

> The marketplace is named **`iterative`** (independent of the repo name), so installs are
> always `<plugin>@iterative`.

## Available plugins

| Plugin | Install | What it does |
|--------|---------|--------------|
| **iterator** | `/plugin install iterator@iterative` | First-class access to the **Iterator CRM** — the MCP connection + an `/iterator` command + a nudge hook. [Details ›](plugins/iterator/README.md) |

_Add yours here when you contribute._

## Contributing

Everything is one folder under `plugins/` plus one entry in the catalog. Start from
`plugins/_template/` and follow [`CONTRIBUTING.md`](CONTRIBUTING.md). A plugin can bundle any
mix of commands, skills, agents, hooks, and MCP servers — including a plugin that's *just* a
skill or *just* a command.

## Repo layout

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

## Notes

- **Auth / secrets:** plugins never store credentials. MCP servers use per-user OAuth (e.g.
  Iterator's is gated to `iterative.vc` emails and OAuths in your browser on first use). See
  each plugin's own README.
- **Public repo:** hosting this publicly lets the team `add` it with no login. It contains no
  secrets by design — only pointers (URLs) and code. Anything sensitive stays behind each
  server's own auth.
- **Hooks execute code** on each user's machine. Keep hook scripts small and readable; that's
  the trust boundary for a shared marketplace.
