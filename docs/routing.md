# Routing

Users state the task, not the machinery. The primary Orchestrator is the decision-maker and writer. One cheap read-only Explorer handles non-trivial repository discovery so the primary model spends its context on reasoning and implementation.

The canonical rules are shipped with the plugin in `plugins/lightflow/skills/lightflow/references/routing.md`. In practical terms:

- Trivial and already-localized work is implemented directly by the primary agent.
- One Luna Explorer is used when work requires locating behavior, tracing callers/dependencies across files, mapping an unfamiliar subsystem, or comparing repositories.
- The primary agent consumes the distilled findings, reasons, implements, and inspects the diff without repeating the exploration.
- Architect, Worker, and Reviewer are used only when explicitly requested or a concrete need remains after primary reasoning; risk alone does not spawn them.
- Plan Mode never invokes Worker or changes production code.

Normal work uses at most one Explorer. Multiple specialists or parallelism require an explicit user request.

Cross-project work also classifies reference intent. Explicit copy/identical/unchanged language requires exact replication with source-parity validation and no cleanup, minimization, interface changes, or behavioral adaptation. Exactness never widens scope: copy only the named system and strictly required dependency closure, use a bounded copy manifest, and reject unrelated changes. Requests to check other systems are read-only. “Use project A's setup/base” preserves the complete reusable source structure and extension points while excluding only product-specific behavior. Adaptation is allowed only when requested or forced by an evidenced incompatibility.

Execution is opt-in. Tests, builds, compilers, linters, formatters, MCP/app tools, browser/editor/runtime automation, Play Mode, and polling/waiting run only when explicitly requested. When live Unity validation is requested, completion is state-based: wait until importing/compilation is idle, then inspect the final-cycle Console.

The scenario matrix in `evals/routing-scenarios.json` covers the required feature, bugfix, refactor, integration, planning, dependency/toolset, Unity, Go/Nakama, and critical-work routes. `evals/validate.ps1` checks those contracts without a model; `evals/run-behavioral.ps1` runs the prompts against Codex and includes a real write-and-verify smoke task.
