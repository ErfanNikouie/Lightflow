# Lightflow routing

Classify independently across the dimensions below. Classification exists to reduce delegation, not to create ceremony.

## Work type

- `FEATURE`: new behavior. Implement directly when clear; use Explorer only for substantial missing context, Architect only for unresolved material design or risk, custom Worker only for useful handoff/isolation, and Reviewer when high-risk or explicitly requested.
- `BUGFIX`: reproduce, trace callers, fix the root cause, and validate directly when practical. Use Explorer only when a bounded investigation merits a separate context. Architect only if investigation reveals material architecture.
- `REFACTOR`: preserve observable behavior unless told otherwise. Implement clear low/normal refactors directly. For meaningful unresolved or high-risk work, use Explorer/Architect as needed, then either primary implementation or a custom Worker, followed by conditional review.
- `INTEGRATION`: the implementing agent normally inspects source and target in one coherent pass. Apply the reference-intent rules below before changing source structure or contracts. Split read-only exploration only when the mapping is genuinely large or parallel savings justify quota; use Architect for nontrivial unresolved mapping and Reviewer for high-risk integration.
- `ARCHITECTURE`: Explorer when repository facts are needed, then Architect. Return a plan/design; implement only when requested.
- `TRIVIAL`: primary agent implements directly with lightweight verification and no custom specialist.

## Architecture completeness

- `USER_COMPLETE`: enough explicit direction exists. Do not invoke Architect to reconsider it.
- `USER_PARTIAL`: important user decisions are locked but gaps remain. Architect may resolve only those gaps and may challenge a decision only when contradictory, impossible, materially unsafe, or incompatible with another explicit requirement.
- `EXISTING`: the repository has a clear appropriate architecture. Follow it unless higher authority conflicts.
- `UNSPECIFIED`: no sufficient architecture exists. Use Architect when the work materially requires design.

## Reference intent

- `EXACT_REPLICATION`: “copy and paste,” “identical,” “unchanged,” “do not change anything,” or equivalent language makes the named source system authoritative, not the entire source repository. Fidelity and breadth are independent. Preserve the named system's files, structure, names, interfaces, behavior, helpers, assets/settings, serialized wiring, and pipeline order while copying only its named roots and strictly required dependency closure. Reuse target dependencies already present. Never copy unrelated sibling systems, scenes, assets, or the whole project unless explicitly requested. Copy bounded artifacts rather than recreating them. Do not minimize, clean up, redesign, or adapt; allow only target-identity edits required to compile/resolve, and report every deviation.
- `TEMPLATE_REPLICATION`: “use project A's setup/base/structure” makes the smallest complete reusable source slice authoritative. Inspect and preserve entry points, helpers, configuration/assets/prefabs, extension pipelines, and folder conventions; exclude only product-specific behavior outside the requested target foundation. Do not replace existing source/package components with new equivalents.
- `ADAPTATION`: alter the source design only when explicitly requested or when an evidenced target incompatibility prevents faithful replication. Keep changes minimal and preserve public contracts unless the user authorizes changing them.

If wording mixes these modes, the more explicit fidelity instruction wins without widening the named scope. “Check,” “audit,” or “verify” other systems is read-only unless the user explicitly asks to modify or synchronize them. Before exact replication, create a bounded copy manifest containing named roots, each required dependency and reason, explicit exclusions, and expected changed files. If that dependency closure unexpectedly reaches a large part of the source project, stop and ask before bulk copying. Ponytail and target conventions cannot override exact/template source authority. Before finishing, compare the source and target relevant file set, public signatures, structural/serialized wiring, and behavior; explain any unavoidable difference and confirm the diff contains no unrelated additions or modifications.

## Risk

- `LOW`: no Reviewer unless explicitly requested.
- `NORMAL`: no Reviewer by default; use one only for a concrete unresolved correctness concern or explicit request.
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

## Delegation budget

Routes list extra custom-specialist contexts; direct primary-agent work has an empty route.

- `LOW` and clear `NORMAL`: no custom specialist by default.
- Bounded missing fact or isolated long-running implementation: at most one custom specialist by default.
- `HIGH` and `CRITICAL`: use the specialists needed for correctness, but do not repeat discovery or review.
- Parallelism is a quota-for-time tradeoff. Use it only when independent work materially shortens the critical path.

## Handoffs

- Explorer: relevant files/components, current flow, constraints, affected areas, unresolved questions.
- Architect: locked decisions, gaps resolved, rationale, required changes, risks, Worker constraints.
- Worker: result, material files/systems changed, validation and results, limitations.
- Reviewer: severity-ordered findings with evidence, impact, and required correction. No finding means say so plainly.
