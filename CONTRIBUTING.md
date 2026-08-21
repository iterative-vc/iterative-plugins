# Contributing a plugin

This repo is **one marketplace, many plugins**. Everyone on the team adds the
marketplace once; each contribution is a new folder under `plugins/` plus one
entry in the catalog. You don't need to understand the whole repo to add yours.

## Plugin vs. skill vs. command — which do I make?

You always ship a **plugin** (that's the installable unit). A plugin is just a
folder that can contain any mix of:

| Component | Folder | What it is |
|-----------|--------|------------|
| **Command** | `commands/*.md` | An explicit action the user invokes: `/your-command ...` |
| **Skill** | `skills/<name>/SKILL.md` | Reusable know-how Claude pulls in *automatically* when its `description` matches |
| **Agent** | `agents/*.md` | A subagent definition |
| **Hook** | `hooks/hooks.json` | Code the harness runs automatically on events (e.g. a nudge) |
| **MCP server** | `.mcp.json` | A data/tool connection (like Iterator) |

"I just want to share a skill" → make a plugin that contains only a `skills/`
folder. Same for a command-only or hook-only plugin. Keep what you need, delete
the rest.

## Add your plugin in 4 steps

1. **Copy the template:**
   ```bash
   cp -r plugins/_template plugins/my-plugin
   ```

2. **Edit `plugins/my-plugin/.claude-plugin/plugin.json`** — set a unique
   kebab-case `name` (this is what people type: `/plugin install my-plugin@iterative`),
   a `description`, and your `author`.

3. **Build it.** Keep the component folders you need, delete the others. Test
   locally without pushing:
   ```bash
   /plugin marketplace add /absolute/path/to/iterative-plugins   # once
   /plugin install my-plugin@iterative
   ```
   After edits, run `/plugin marketplace update iterative` and reinstall.

4. **List it in the catalog.** Add one object to the `plugins` array in
   [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json):
   ```json
   {
     "name": "my-plugin",
     "source": "my-plugin",
     "description": "One line users see when installing.",
     "version": "0.1.0"
   }
   ```
   (`source` is just the folder name — `metadata.pluginRoot` is set to `./plugins`.)

Then open a PR. Once merged, teammates get it with `/plugin marketplace update iterative`.

## Conventions

- **Unique names.** The plugin `name` in `plugin.json` and the `name` in the
  marketplace entry must match and be unique across the repo.
- **No secrets.** Never commit tokens/keys. MCP servers should use OAuth or a
  user-provided `userConfig` value, not a checked-in credential. (See the
  `iterator` plugin's `.mcp.json` for the OAuth-remote pattern.)
- **Hooks run code on other people's machines.** Keep hook scripts small and
  readable — teammates are trusting and executing them.
- **Document it.** Add a short `README.md` in your plugin folder.
