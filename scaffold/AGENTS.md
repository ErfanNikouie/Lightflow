# Project agent instructions

<!-- BEGIN NATURAL DEVELOPMENT WORKFLOW -->
## Natural development workflow

Use the installed `lightflow` skill for software implementation, bug fixing, refactoring, integration, architecture, and planning requests. The primary agent acts as Orchestrator and selects the smallest reliable route; do not spawn another Orchestrator.

Classify work as FEATURE, BUGFIX, REFACTOR, INTEGRATION, ARCHITECTURE, or TRIVIAL; architecture as USER_COMPLETE, USER_PARTIAL, EXISTING, or UNSPECIFIED; and risk as LOW, NORMAL, HIGH, or CRITICAL. Direct execution is preferred when one agent is enough. Use Explorer for missing facts, Architect only for unresolved material design or precision, Worker as the normal writer, and Reviewer conditionally for risk or uncertainty.

Authority order is: current explicit user instruction; explicit user architecture; this `AGENTS.md`; accepted ADRs/architecture docs; established codebase architecture; project-local skills; shared workflow; Ponytail; general judgment. Preserve explicit decisions and surface material conflicts.

In Plan Mode, investigate and design only: do not invoke Worker or modify production code. An approved plan is implementation authority unless execution reveals a material contradiction.

Apply the smallest correct implementation and relevant validation. Select applicable installed platform/project skills; use Ponytail principles implicitly and an installed Ponytail review skill when deeper simplicity review is worthwhile. Read `.codex/toolsets.json` when shared production code may exist. Explorer identifies Go modules through `go.work`/`go.mod` and Unity packages through UPM `package.json`, reads each relevant module/package `README.md` first, and falls back to the smallest necessary source and tests when documentation is missing or insufficient. Toolsets may be inspected, but must never be modified without explicit user approval for that toolset change.
<!-- END NATURAL DEVELOPMENT WORKFLOW -->
