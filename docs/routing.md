# Routing

Users state the task, not the machinery. The primary Orchestrator is also the default writer: it classifies work type, architecture completeness, and risk, then delegates only when the expected correctness or elapsed-time gain exceeds the extra context, quota, and coordination cost.

The canonical rules are shipped with the plugin in `plugins/lightflow/skills/lightflow/references/routing.md`. In practical terms:

- Trivial, low-risk, and clear normal work is implemented directly by the primary agent; no custom specialist is spawned.
- Explorer is used only when a substantial bounded repository question justifies another context, not for routine source/target or dependency reading.
- Architect fills unresolved material gaps and never reconsiders complete user architecture merely to offer another design.
- Custom Worker is reserved for material handoffs or isolated long-running execution. It is not spawned merely to rename direct implementation.
- Reviewer is skipped for low/normal work by default and expected for high-risk work.
- Plan Mode never invokes Worker or changes production code.

Normal work uses at most one custom specialist unless it becomes materially blocked or higher-risk. Parallel specialists trade more quota for less elapsed time and are used only when their investigations are independent and on the critical path.

Cross-project work also classifies reference intent. Explicit copy/identical/unchanged language requires exact replication with source-parity validation and no cleanup, minimization, interface changes, or behavioral adaptation. “Use project A's setup/base” preserves the complete reusable source structure and extension points while excluding only product-specific behavior. Adaptation is allowed only when requested or forced by an evidenced incompatibility.

The scenario matrix in `evals/routing-scenarios.json` covers the required feature, bugfix, refactor, integration, planning, dependency/toolset, Unity, Go/Nakama, and critical-work routes. `evals/validate.ps1` checks those contracts without a model; `evals/run-behavioral.ps1` runs the prompts against Codex and includes a real write-and-verify smoke task.
