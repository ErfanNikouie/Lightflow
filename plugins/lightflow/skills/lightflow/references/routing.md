# Lightflow routing

Classify independently across the dimensions below. Classification exists to reduce delegation, not to create ceremony.

## Work type

- `FEATURE`: new behavior. Use Explorer when locating or tracing the affected flow is non-trivial, then let the primary agent reason and implement.
- `BUGFIX`: use Explorer to trace the failing flow and callers unless they are already localized, then let the primary agent fix the root cause. Reproduce or run validation only when requested.
- `REFACTOR`: preserve observable behavior unless told otherwise. Use Explorer for non-trivial boundary/caller mapping; resolve design and implement in the primary context.
- `INTEGRATION`: use Explorer for non-trivial source/target and dependency mapping, then let the primary agent apply the reference-intent rules and implement.
- `ARCHITECTURE`: use Explorer when repository facts are needed, then design in the primary context. Return a plan/design; implement only when requested.
- `TRIVIAL`: primary agent implements directly, inspects the diff, and uses no custom specialist.

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
- `HIGH`: apply extra care in the primary context. Includes concurrency, network authority, persistence integrity, public/shared API change, schema migration, authentication/authorization, security boundaries, or economy/currency.
- `CRITICAL`: perform a precision audit in the primary context. Natural phrases such as “critical,” “maximum precision,” or “be extremely careful” raise this level. Risk alone does not authorize delegation.

## Plan Mode

Plan Mode changes the deliverable, not the architecture classification:

1. Orchestrator analyzes.
2. Use Explorer when non-trivial repository facts are needed.
3. Resolve design in the primary context.
4. Return a concrete implementation plan.
5. Do not invoke Worker or modify production code.
6. Review in the primary context unless a separate review was requested.

An approved plan becomes implementation authority. Worker does not redo it unless implementation exposes a material contradiction.

## Delegation budget

Routes list extra custom-specialist contexts; direct primary-agent work has an empty route.

- Default route is empty for trivial or already-localized work and one Explorer for non-trivial repository investigation.
- Architect, Worker, and Reviewer require an explicit user request or a concrete need that remains after primary reasoning.
- Multiple specialists or parallelism require an explicit user request.

## Handoffs

- Explorer: relevant files/components, current flow, constraints, affected areas, unresolved questions.
- Architect: locked decisions, gaps resolved, rationale, required changes, risks, Worker constraints.
- Worker: result, material files/systems changed, validation and results, limitations.
- Reviewer: severity-ordered findings with evidence, impact, and required correction. No finding means say so plainly.
