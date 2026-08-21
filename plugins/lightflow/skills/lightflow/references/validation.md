# Validation and tool selection

The primary agent owns implementation. By default, inspect the affected flow and final diff without executing validation commands or external tools. Do not imply that unrun checks passed.

Words such as “implement,” “fix,” and “change” do not authorize automated validation. Run tests, builds, compilers, linters, formatters, Play Mode, runtime/visual checks, MCP/app tools, browser/editor automation, or polling/waiting only when the user explicitly requests that operation. If a tool is essential to perform the requested mutation rather than validate it, explain why before the call and use the smallest necessary capability.

## Tool selection

- Unity: use editor/MCP tooling only when the user asks to operate or inspect the live editor, Play Mode, runtime behavior, screenshots, compilation state, or Console.
- Go/Nakama: run named repository scripts, `go test`, `go vet`, Docker/Compose, or live Nakama checks only when requested.
- Python/web: run tests or browser automation only when requested.
- Prefer the narrowest requested check; do not expand “run this unit test” into a full suite or runtime smoke test.

## Unity compilation and Console gate

When the user explicitly requests validation through a live Unity editor:

1. Record relevant existing Console errors when practical so new failures are distinguishable from the baseline.
2. Save changed assets and request an Asset Database refresh/recompile when the applicable automatic refresh/import/compile cycle has not started.
3. Observe editor state, confirm the applicable cycle starts, and wait for importing/refreshing/compiling to finish. Poll the actual editor state; a fixed sleep or a successful tool call is not evidence of completion.
4. After the final compile/import cycle is idle, read the Console and inspect errors plus relevant exceptions. Do not rely on a Console snapshot taken before or during compilation.
5. Fix failures caused by the change and repeat the refresh, wait, and post-compile Console check. Stop only when the final cycle is idle and introduces no relevant errors, or when a concrete blocker is reported with the remaining diagnostics.

Do not claim “compiled,” “validated,” or “Console clean” without evidence from the final settled editor state. If no live Unity editor/tool connection is available, report that limitation. Do not substitute another automated check unless the user authorizes it.

If an operational tool lacks a one-off capability, use a reasonable workaround. If the gap will recur across projects, finish the task when possible and propose a separate tool/MCP/workflow improvement; do not silently expand reusable AI tooling during unrelated work.

When explicitly requested, Reviewer checks correctness, requirements, regressions, architectural violations, concurrency/networking, security, meaningful missing tests, maintainability, and unnecessary complexity.

## Reference and coverage validation

- Exact replication: validate both fidelity and bounded scope. Diff the manifest-listed source and target artifacts where practical; confirm file/class/member names, public signatures, behavior, serialized components/references, settings/assets, and pipeline order remain equivalent. Compare the final changed-file list with the bounded copy manifest and fail completion on unrelated additions or modifications. List every necessary target-specific deviation.
- Template replication: compare the complete reusable slice and verify its extension points remain intact; confirm only product-specific behavior was excluded.
- Unity scene-wide integration: enumerate all project scenes and explicit exclusions, then inspect the required components/prefabs, helpers, settings, loaders, pipeline registrations, package/assembly dependencies, and serialized references in every applicable scene. Exercise editor/runtime behavior only when explicitly requested.
