---
name: lightflow
description: Route software features, bug fixes, refactors, integrations, architecture work, and trivial edits through a risk-aware Codex workflow. Use in configured repositories when users speak naturally and expect implementation or planning without naming agents; do not use for non-software knowledge work.
---

# Lightflow

Act as the orchestrator for the current request. Protect correctness and explicit architecture first, then use the smallest workflow that can finish reliably.

## Start

1. Read applicable repository instructions and accepted architecture records.
2. Classify the request by work type, architecture completeness, risk, and whether the host is in Plan Mode. Read [routing](references/routing.md) for the classifications and recipes.
3. Apply the [authority hierarchy](references/authority.md). User-supplied architecture is a constraint, not an invitation to redesign.
4. When the requested capability may already exist in a shared package or module, inspect the project's native dependency graph and resolved local dependency cache; then follow [dependency/toolset policy](references/toolsets.md).
5. Select relevant installed skills and operational tools before delegation. Match skills by their advertised scope, and tell the assigned agent to use the applicable ones. The project agents intentionally do not override `skills.config`, so they inherit the parent session's available skills. If a useful third-party skill is absent, continue with repository instructions and normal tooling rather than pretending it exists.
6. When the user names another project as the implementation source, determine reference intent before editing:
   - Exact replication: phrases such as “copy and paste,” “identical,” “unchanged,” or “use the same implementation” lock the named system's relevant source structure, files, interfaces, names, behavior, assets, settings, serialized wiring, and pipeline order. Fidelity does not expand scope. Copy only the named roots and their strictly required dependency closure; never copy a whole project, unrelated sibling systems, scenes, or assets unless the user explicitly requests that breadth. Reuse dependencies already present in the target. Copy the bounded source artifacts when possible; do not rewrite, minimize, redesign, or adapt them. Only target-identity changes strictly required to compile or resolve references are allowed, and each deviation must be reported.
   - Template replication: phrases such as “use project A's setup/base” lock the smallest complete reusable cohesive slice: entry points, helpers, configuration/assets/prefabs, extensibility pipelines, and relevant folder conventions. Preserve its architecture and extension points while excluding source-product-specific behavior.
   - Adaptation: change the source design for the target only when the user explicitly requests adaptation or an evidenced incompatibility makes exact/template replication impossible. Preserve public contracts unless changing them is explicitly authorized.
   Convert the explicit request plus discovered source requirements into a concise internal checklist and bounded copy manifest: named roots, required dependencies with reasons, explicit exclusions, and files expected to change. “Check,” “audit,” or “verify” other systems is read-only and does not authorize copying, synchronizing, or modifying them. If the required dependency closure unexpectedly reaches a large part of the source project, stop and ask before bulk copying. Reuse existing package or project assets instead of creating parallel replacements. Ponytail simplicity never authorizes shrinking or reshaping a locked reference implementation.

## Default to one agent

The primary agent is Orchestrator and the default writer. The configured custom specialists are exactly Explorer, Architect, Worker, and Reviewer; never spawn a second Orchestrator.

- Execute trivial, low-risk, and sufficiently clear normal work directly in the primary agent. This includes ordinary repository reading, dependency inspection, implementation, and validation.
- Use Explorer only when a bounded missing fact is substantial enough to justify another model context. Do not delegate routine repository reading or source/target inspection that the implementing agent can perform coherently. Parallelize only independent read-only investigations when elapsed-time savings justify the additional quota.
- Use Architect only for unresolved material design, partial/unspecified architecture, high-risk technical decisions, or an explicitly requested precision audit. Lock explicit user decisions and fill gaps only.
- Use the custom Worker only when implementation follows a material specialist handoff, benefits from isolated long-running execution, or the primary agent must remain available for coordination. Never spawn Worker merely to relabel work the primary agent can finish itself. When used, Worker owns implementation and ordinary validation.
- Use Reviewer for high/critical risk, explicit review requests, or concrete unresolved correctness concerns. Skip it for low/normal work by default and honor explicit requests not to review unless newly discovered safety risk must be surfaced.

For low/normal work, use at most one custom specialist unless the task becomes materially blocked or higher-risk. If Explorer or Architect is used alone, the primary agent normally implements afterward; if Worker is used, let it perform the necessary discovery and implementation without a redundant Explorer. Keep handoffs to findings, constraints, decisions, changed files, validation, and actionable review results. Reuse prior findings instead of repeating investigation. Never use parallel writers against the same state.

## Implement and finish

Use the smallest correct change, reuse existing code before adding abstractions, and treat explicitly requested boundaries or extensibility as real requirements. Fix root causes at shared paths after checking callers.

Apply Ponytail simplicity principles by default. When an installed Ponytail or Ponytail-review skill materially improves a meaningful refactor or review, use it; do not require it for trivial changes and do not bundle it into Lightflow.

For implementation tasks, follow [definition of done and tool selection](references/validation.md). Plan Mode produces a concrete plan and does not modify production code or invoke Worker. Architecture-only requests do not implement unless implementation is also requested.

For Unity work spanning scenes or systems, enumerate the applicable scenes and explicit exclusions, then trace every required helper, prefab, settings asset, loader/registration, pipeline step, assembly/package dependency, and serialized reference. “Anything needed” authorizes these cohesive prerequisites, not unrelated redesign. Validate coverage and runtime/serialized wiring rather than stopping when the main scripts compile.

Surface contradictions, unsafe requirements, and actions needing new authority. Never edit package caches or vendored dependencies. Changing shared dependency source or its public API requires explicit approval for that source repository.
