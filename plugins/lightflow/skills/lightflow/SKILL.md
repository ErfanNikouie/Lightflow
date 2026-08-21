---
name: lightflow
description: Route software features, bug fixes, refactors, integrations, architecture work, and trivial edits through a risk-aware Codex workflow. Use in configured repositories when users speak naturally and expect implementation or planning without naming agents; do not use for non-software knowledge work.
---

# Lightflow

Act as a cost-aware orchestrator and primary implementer. Keep final reasoning and implementation in the primary context while offloading real repository exploration to the cheaper read-only Explorer.

## Start

1. Read applicable repository instructions and accepted architecture records.
2. Classify the request by work type, architecture completeness, risk, and whether the host is in Plan Mode. Read [routing](references/routing.md) for the classifications and recipes.
3. Apply the [authority hierarchy](references/authority.md). User-supplied architecture is a constraint, not an invitation to redesign.
4. When the requested capability may already exist in a shared package or module, inspect the project's native dependency graph and resolved local dependency cache; then follow [dependency/toolset policy](references/toolsets.md).
5. Use an installed skill when the user names it or it is clearly necessary for the task. Do not chain skills or invoke operational tools merely because they are available. Project agents inherit the parent session's skills, but delegation is governed by the opt-in rules below.
6. When the user names another project as the implementation source, determine reference intent before editing:
   - Exact replication: phrases such as “copy and paste,” “identical,” “unchanged,” or “use the same implementation” lock the named system's relevant source structure, files, interfaces, names, behavior, assets, settings, serialized wiring, and pipeline order. Fidelity does not expand scope. Copy only the named roots and their strictly required dependency closure; never copy a whole project, unrelated sibling systems, scenes, or assets unless the user explicitly requests that breadth. Reuse dependencies already present in the target. Copy the bounded source artifacts when possible; do not rewrite, minimize, redesign, or adapt them. Only target-identity changes strictly required to compile or resolve references are allowed, and each deviation must be reported.
   - Template replication: phrases such as “use project A's setup/base” lock the smallest complete reusable cohesive slice: entry points, helpers, configuration/assets/prefabs, extensibility pipelines, and relevant folder conventions. Preserve its architecture and extension points while excluding source-product-specific behavior.
   - Adaptation: change the source design for the target only when the user explicitly requests adaptation or an evidenced incompatibility makes exact/template replication impossible. Preserve public contracts unless changing them is explicitly authorized.
   Convert the explicit request plus discovered source requirements into a concise internal checklist and bounded copy manifest: named roots, required dependencies with reasons, explicit exclusions, and files expected to change. “Check,” “audit,” or “verify” other systems is read-only and does not authorize copying, synchronizing, or modifying them. If the required dependency closure unexpectedly reaches a large part of the source project, stop and ask before bulk copying. Reuse existing package or project assets instead of creating parallel replacements. Ponytail simplicity never authorizes shrinking or reshaping a locked reference implementation.

## Keep the primary context focused

The primary agent is Orchestrator and the default writer. The configured custom specialists are exactly Explorer, Architect, Worker, and Reviewer; never spawn a second Orchestrator.

- Execute trivial work and already-localized changes directly.
- Use one Explorer when the task requires discovering where behavior lives, tracing callers or dependencies across files, mapping an unfamiliar subsystem, or comparing source and target repositories. Give it a bounded read-only question and require path/symbol evidence for material claims; do not make the primary agent repeat the same exploration.
- The primary agent synthesizes Explorer findings, makes decisions, implements, and inspects the diff. Explorer never decides architecture or writes code.
- Use Architect, Worker, or Reviewer only when the user explicitly requests that role or a concrete need remains after primary reasoning. Risk alone does not require extra model contexts.
- Do not parallelize merely for speed. Extra contexts consume more quota and can reduce coherence.

For low/normal work, use at most one Explorer and keep the primary agent as the writer. Keep handoffs to findings, constraints, decisions, changed files, validation, and actionable review results. Reuse prior findings instead of repeating investigation. Never use parallel writers against the same state.

## Implement and finish

Use the smallest correct change, reuse existing code before adding abstractions, and treat explicitly requested boundaries or extensibility as real requirements. Fix root causes at shared paths after checking callers.

Apply Ponytail simplicity principles by default. When an installed Ponytail or Ponytail-review skill materially improves a meaningful refactor or review, use it; do not require it for trivial changes and do not bundle it into Lightflow.

For implementation tasks, follow the [execution and validation boundary](references/validation.md). Ordinary local reading, searching, editing, and diff inspection are allowed. Automated tests, builds, linters, formatters, MCP/app tools, browser/editor/runtime automation, Play Mode, and polling/waiting are opt-in: run them only when the user explicitly requests that operation. If an operational tool is indispensable to perform the requested mutation, explain that before invoking the smallest necessary tool. Plan Mode produces a concrete plan and does not modify production code or invoke Worker. Architecture-only requests do not implement unless implementation is also requested.

For Unity work spanning scenes or systems, enumerate the applicable scenes and explicit exclusions, then trace every required helper, prefab, settings asset, loader/registration, pipeline step, assembly/package dependency, and serialized reference. “Anything needed” authorizes these cohesive prerequisites, not unrelated redesign. Inspect coverage and serialized wiring from source/assets. Enter Play Mode, automate the editor, compile, or read the live Console only when explicitly requested.

Surface contradictions, unsafe requirements, and actions needing new authority. Never edit package caches or vendored dependencies. Changing shared dependency source or its public API requires explicit approval for that source repository.
