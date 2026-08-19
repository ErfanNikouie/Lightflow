# Lightflow routing

Classify independently across the dimensions below. Classification exists to reduce delegation, not to create ceremony.

## Work type

- `FEATURE`: new behavior. Explorer only when context is missing; Architect only for unresolved design or risk; Worker; Reviewer when warranted.
- `BUGFIX`: reproduce or trace with Explorer when useful; Worker; Reviewer only when warranted. Architect only if investigation reveals material architecture.
- `REFACTOR`: preserve observable behavior unless told otherwise. For meaningful work, use Explorer as needed, Architect unless the target design is complete, Worker, then conditional Reviewer.
- `INTEGRATION`: inspect source and target independently when useful; use Architect for nontrivial mapping; Worker; conditional Reviewer. Adapt behavior to target architecture rather than copying blindly.
- `ARCHITECTURE`: Explorer when repository facts are needed, then Architect. Return a plan/design; implement only when requested.
- `TRIVIAL`: Worker directly with lightweight verification.

## Architecture completeness

- `USER_COMPLETE`: enough explicit direction exists. Do not invoke Architect to reconsider it.
- `USER_PARTIAL`: important user decisions are locked but gaps remain. Architect may resolve only those gaps and may challenge a decision only when contradictory, impossible, materially unsafe, or incompatible with another explicit requirement.
- `EXISTING`: the repository has a clear appropriate architecture. Follow it unless higher authority conflicts.
- `UNSPECIFIED`: no sufficient architecture exists. Use Architect when the work materially requires design.

## Risk

- `LOW`: normally no Reviewer.
- `NORMAL`: Reviewer only when size or uncertainty warrants it.
- `HIGH`: normally Reviewer. Includes concurrency, network authority, persistence integrity, public/shared API change, schema migration, authentication/authorization, security boundaries, or economy/currency.
- `CRITICAL`: Reviewer plus an Architect precision audit when useful. Natural phrases such as “critical,” “maximum precision,” or “be extremely careful” raise this level.

## Plan Mode

Plan Mode changes the deliverable, not the architecture classification:

1. Orchestrator analyzes.
2. Explorer investigates only when needed.
3. Architect runs only for `USER_PARTIAL`, `UNSPECIFIED`, material risk, or explicit request.
4. Return a concrete implementation plan.
5. Do not invoke Worker or modify production code.
6. Review only high/critical plans or when requested.

An approved plan becomes implementation authority. Worker does not redo it unless implementation exposes a material contradiction.

## Handoffs

- Explorer: relevant files/components, current flow, constraints, affected areas, unresolved questions.
- Architect: locked decisions, gaps resolved, rationale, required changes, risks, Worker constraints.
- Worker: result, material files/systems changed, validation and results, limitations.
- Reviewer: severity-ordered findings with evidence, impact, and required correction. No finding means say so plainly.
