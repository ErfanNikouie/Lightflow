# Architecture

Lightflow has two cooperating layers:

1. The `lightflow` plugin supplies one implicitly selectable orchestration skill and focused policy references. It contains no MCP server and does not duplicate Ponytail, engine/vendor skills, or game-development skill packs.
2. The project scaffold supplies repository instructions, four project-scoped custom specialists, and model selection. Shared packages and modules are discovered from the project's native dependency graph and local caches.

The main Codex agent acts as Orchestrator and default writer. Explorer, Architect, and Reviewer are read-only custom specialists; Worker is the only write-capable custom specialist and is reserved for useful handoffs or isolated long-running execution. There is no custom Orchestrator to spawn accidentally and never more than one writer against the same state.

The agent files do not set `skills.config`, so current Codex behavior makes them inherit the parent session's available skills. Lightflow can therefore route into installed Unity, vendor, project, or Ponytail skills without bundling or naming a fixed inventory. Skill selection remains description-driven; absent skills fall back to repository guidance and native tools.

Model values live only in `profiles/*.json`. The source agent TOML files contain role behavior, and `scripts/setup.ps1` injects the selected model settings into a target project. This avoids three copies of every agent instruction.

Current Codex project agents are standalone `.codex/agents/*.toml` configuration layers, as documented in [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents). `AGENTS.md` provides the primary-agent orchestration behavior. Plan Mode remains a host-controlled mode; Lightflow changes its workflow when that mode is active but does not configure the mode.
