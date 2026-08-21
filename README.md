# Lightflow

Lightflow is a small, team-shareable Codex plugin and repository scaffold for natural software-development requests. Install the plugin, run one setup command in a project, and ask for work normally; the workflow chooses the least expensive route that still protects correctness and architectural intent.

## Quick start

1. Add this repository as a marketplace:

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

3. Open the project in ChatGPT/Codex and speak naturally:

   - “Implement player reconnect.”
   - “Refactor this service. Keep these three interfaces, but decide the remaining boundaries yourself.”
   - “Port the leaderboard implementation from repository A, but reuse our shared Go economy module.”
   - “Plan this first. I already decided how persistence works.”

The workflow does not require users to name agents for ordinary work. Operational tools and execution validation are opt-in: ask for tests, builds, Play Mode, Console checks, browser/editor automation, or another live operation when you want it run.

## What gets installed

- A managed section in the target `AGENTS.md` (existing instructions are preserved and backed up before the first merge).
- `.codex/config.toml` model and multi-agent defaults, merged without removing unrelated settings.
- Four project specialists in `.codex/agents/`: explorer, architect, worker, and reviewer. The primary Codex agent is Orchestrator.

See [installation](docs/installation.md), [migration](docs/migration.md), [architecture](docs/architecture.md), [profiles](docs/profiles.md), and [toolsets](docs/toolsets.md) for the operator-facing details.

## Toolsets and installed skills

No toolset registration is required. Explorer follows Unity's `Packages/manifest.json` and `Packages/packages-lock.json` into embedded/local packages and `Library/PackageCache`. For Go it follows `go.work`, `go.mod`, replacements/vendor, and `GOMODCACHE`, using `go list -m -json all` only with `GOPROXY=off`. It reads each relevant resolved package/module `README.md` first and inspects the smallest necessary public API, source, and tests only when documentation is absent or insufficient.

Lightflow uses a named or clearly necessary skill already available in the current Codex installation without chaining skills merely because they exist. Its custom agents inherit the parent skill configuration. Ponytail principles are implicit. These skills are not bundled: teammates get the same integration when they install/enable the same skills, while Lightflow falls back to repository guidance when they do not.

## Platform adaptation

The scaffold follows current OpenAI documentation: project custom agents are standalone `.codex/agents/*.toml` layers, repo instructions live in `AGENTS.md`, and the Windows desktop app runs natively with PowerShell. Plan Mode is controlled by the host UI/runtime; Lightflow changes routing behavior when planning is active but does not attempt to enable the mode itself.

## Validation

From PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\evals\validate.ps1
```

The fast validator checks JSON/TOML syntax, manifest/role invariants, setup and profile-only behavior, native dependency discovery, scenario contracts, and the shared-source approval boundary. It does not call a model.

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

## License

MIT. See [LICENSE](LICENSE).
