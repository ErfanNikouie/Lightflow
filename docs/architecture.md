# Architecture

Lightflow has three cooperating layers:

1. The shared plugin root supplies one explicitly invoked orchestration skill and focused policy references. It contains no MCP server and does not duplicate Ponytail, engine/vendor skills, or game-development skill packs.
2. `.codex-plugin/plugin.json` plus the Codex project scaffold provide gated TOML specialists and profile-based model selection.
3. `.claude-plugin/plugin.json` plus root-level Markdown agents provide the same workflow natively to Claude Code; the repository-level Claude marketplace points to this shared plugin root.

Lightflow activates only after an affirmative invocation such as “use Lightflow,” “run Lightflow,” `$lightflow`, or `/lightflow:lightflow`. Incidental or negative mentions do not activate it. The main agent then acts as Orchestrator, decision-maker, and writer. Explorer is the normal read-only helper for non-trivial repository discovery; Architect, Worker, and Reviewer are opt-in specialists. Every specialist verifies that the parent assignment belongs to an active Lightflow workflow.

Codex agent files do not set `skills.config`, so they inherit the parent session's available skills. Claude plugin agents do not preload skills. On either host, Lightflow uses only a named or clearly necessary additional skill and otherwise falls back to repository guidance and native tools.

Codex model values live in `profiles/*.json`, and `scripts/setup.ps1` injects them into a target project. Claude's Explorer uses Haiku at low effort; the opt-in Architect, Worker, and Reviewer inherit the active session model with role-appropriate effort.

Codex project agents are standalone `.codex/agents/*.toml` layers, while Claude plugin agents are root-level `agents/*.md` files. Lightflow does not inject project-wide `AGENTS.md` instructions. The shared skill provides primary-agent orchestration on both hosts. Plan Mode remains host-controlled.
