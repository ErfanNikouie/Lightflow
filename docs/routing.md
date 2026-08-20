# Routing

Users state the task, not the machinery. The Orchestrator classifies work type, architecture completeness, and risk, then delegates only when it improves the expected result more than its coordination cost.

The canonical rules are shipped with the plugin in `plugins/lightflow/skills/lightflow/references/routing.md`. In practical terms:

- Trivial edits and clear normal features go directly to Worker.
- Explorer is used only when repository facts are missing.
- Architect fills unresolved material gaps and never reconsiders complete user architecture merely to offer another design.
- Reviewer is conditional for normal work and expected for high-risk work.
- Plan Mode never invokes Worker or changes production code.

The scenario matrix in `evals/routing-scenarios.json` covers the required feature, bugfix, refactor, integration, planning, dependency/toolset, Unity, Go/Nakama, and critical-work routes. `evals/validate.ps1` checks those contracts without a model; `evals/run-behavioral.ps1` runs the prompts against Codex and includes a real write-and-verify smoke task.
