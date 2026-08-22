# Lightflow

Lightflow is a small, team-shareable Codex and Claude Code plugin for explicitly requested software-development workflows. It chooses the least expensive route that still protects correctness and architectural intent.

## Quick start

### Codex

1. Add this repository as a marketplace and install Lightflow:

   ```powershell
   codex plugin marketplace add ErfanNikouie/Lightflow
   codex plugin add lightflow@lightflow
   ```

   Repo marketplaces and Git sources are supported by the [official plugin packaging documentation](https://developers.openai.com/plugins/build/plugins).

2. Configure a target repository from this checkout:

   ```bat
   scripts\setup.bat C:\path\to\project refined-balanced
   ```

   Profiles are `refined-balanced` (recommended), `balanced` (legacy default), `quality`, and `economy`. To change only model settings later:

   ```bat
   scripts\setup.bat C:\path\to\project refined-balanced --profile-only
   ```

3. Open the project in ChatGPT/Codex and invoke Lightflow explicitly, for example: `Use Lightflow to implement player reconnect.`

### Claude Code

Add the same repository as a Claude marketplace and install Lightflow:

```powershell
claude plugin marketplace add ErfanNikouie/Lightflow
claude plugin install lightflow@lightflow
```

The Claude plugin bundles the shared skill and four native agents, so no project scaffold is required. Invoke Lightflow explicitly in the target repository:

- “Use Lightflow to implement player reconnect.”
- “Run Lightflow to refactor this service. Keep these three interfaces, but decide the remaining boundaries yourself.”
- “Use Lightflow to port the leaderboard implementation from repository A, but reuse our shared Go economy module.”
- “Use Lightflow to plan this first. I already decided how persistence works.”

`$lightflow` and `/lightflow:lightflow` are also affirmative invocations. Incidental mentions, criticism, questions about Lightflow, and negative instructions do not activate the workflow. Once active, the workflow does not require users to name internal agents. Operational tools and execution validation are opt-in on both hosts: ask for tests, builds, Play Mode, Console checks, browser/editor automation, or another live operation when you want it run.

## What gets installed

- Codex: `.codex/config.toml` model settings and four project specialists in `.codex/agents/`. Setup removes obsolete Lightflow-managed `AGENTS.md` blocks but preserves unrelated project instructions.
- Claude Code: the shared Lightflow skill plus four plugin agents; Explorer uses Haiku at low effort while the opt-in roles inherit the session model.

See [installation](docs/installation.md), [migration](docs/migration.md), [architecture](docs/architecture.md), [profiles](docs/profiles.md), and [toolsets](docs/toolsets.md) for the operator-facing details.

## Toolsets and installed skills

No toolset registration is required. Before source exploration in an unfamiliar codebase, package, or tool, Lightflow searches the relevant scope for Markdown documentation and reads only the one to three most relevant files. It prioritizes `README.md`, `USAGE.md`, `GETTING_STARTED.md`, `QUICKSTART.md`, and relevant usage, installation, integration, or API documents under `docs/`, then falls back to manifests, public APIs, and the smallest necessary source surface when documentation is absent or insufficient.

Explorer follows Unity's `Packages/manifest.json` and `Packages/packages-lock.json` into embedded/local packages and `Library/PackageCache`. For Go it follows `go.work`, `go.mod`, replacements/vendor, and `GOMODCACHE`, using `go list -m -json all` only with `GOPROXY=off`.

Lightflow uses a named or clearly necessary skill already available in the current host without chaining skills merely because they exist. Ponytail principles are implicit. Additional skills are not bundled; Lightflow falls back to repository guidance when they are absent.

## Platform adaptation

Codex uses standalone `.codex/agents/*.toml` project agents. Claude Code discovers the shared skill and Markdown agents from the plugin root. On both hosts, the shared skill and specialists require an affirmative Lightflow invocation. Plan Mode is controlled by the host; Lightflow changes routing behavior when planning is active but does not enable the mode itself.

Lightflow prefers readable paragraphs. It uses numbered lists for sequences or rankings and bullet lists for unordered alternatives or findings, but only when a list improves readability. Natural-language bullet items use `•`; code and structured formats keep their required syntax.

## Validation

From PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\evals\validate.ps1
```

The fast validator checks Codex and Claude manifests, agent/profile invariants, setup behavior, native dependency discovery, scenario contracts, and the shared-source approval boundary. It does not call a model.

Run the opt-in live evaluator when changing routing or agent behavior. It requires Codex authentication and uses model quota:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\evals\run-behavioral.ps1
```

Use `-ScenarioId trivial-rename,failing-rpc` for a smaller run or `-SkipExecutionSmoke` to test routing without the workspace-write smoke task.

## Official references

- [Package plugins and marketplaces](https://developers.openai.com/plugins/build/plugins)
- [Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Configure subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Use AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- [Windows desktop behavior](https://learn.chatgpt.com/docs/windows/windows-app)
- [ChatGPT Work execution boundaries](https://learn.chatgpt.com/docs/enterprise/chatgpt-work-overview)
- [Create Claude Code plugins](https://code.claude.com/docs/en/plugins)
- [Claude Code plugin reference](https://code.claude.com/docs/en/plugins-reference)
- [Claude Code plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

## License

MIT. See [LICENSE](LICENSE).
