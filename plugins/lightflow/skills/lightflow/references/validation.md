# Validation and tool selection

Worker owns normal validation. When reasonably applicable, completion means requested behavior is implemented, explicit requirements are satisfied, existing behavior remains intact, builds and relevant automated checks pass, runtime or visual behavior is exercised where meaningful, material regressions are resolved, and public/architectural documentation is current.

Compilation alone is insufficient when meaningful runtime validation is available. Use the cheapest reliable tool that can validate the requirement.

## Tool selection

- Unity source-only edits: use source/toolchain checks; do not invoke editor automation automatically.
- Unity scene, prefab, serialized-state, asset, Play Mode, runtime input, screenshot, or Console work: use the available Unity editor/MCP tooling.
- Go/Nakama: use repository scripts, `go test`, compiler, `go vet` or appropriate static checks, Docker/Compose, and Nakama runtime/log/API validation when relevant.
- Python/web: use normal tests and scripts; use browser automation when actual interaction or visual behavior matters.

## Unity compilation and Console gate

For changes validated through a live Unity editor, and for any change affecting assembly/package resolution, imports, scenes, prefabs, assets, or serialized/editor state:

1. Record relevant existing Console errors when practical so new failures are distinguishable from the baseline.
2. Save changed assets and request an Asset Database refresh/recompile when the applicable automatic refresh/import/compile cycle has not started.
3. Observe editor state, confirm the applicable cycle starts, and wait for importing/refreshing/compiling to finish. Poll the actual editor state; a fixed sleep or a successful tool call is not evidence of completion.
4. After the final compile/import cycle is idle, read the Console and inspect errors plus relevant exceptions. Do not rely on a Console snapshot taken before or during compilation.
5. Fix failures caused by the change and repeat the refresh, wait, and post-compile Console check. Stop only when the final cycle is idle and introduces no relevant errors, or when a concrete blocker is reported with the remaining diagnostics.

Do not claim “compiled,” “validated,” or “Console clean” without evidence from the final settled editor state. If no live Unity editor/tool connection is available, run the strongest available batch/toolchain compile check and state explicitly that settled editor compilation and post-compile Console validation were not performed.

If an operational tool lacks a one-off capability, use a reasonable workaround. If the gap will recur across projects, finish the task when possible and propose a separate tool/MCP/workflow improvement; do not silently expand reusable AI tooling during unrelated work.

Reviewer checks correctness, requirements, regressions, architectural violations, concurrency/networking, security, meaningful missing tests, maintainability, and unnecessary complexity. Route implementation defects back to Worker and architectural failures to Architect.

## Reference and coverage validation

- Exact replication: validate both fidelity and bounded scope. Diff the manifest-listed source and target artifacts where practical; confirm file/class/member names, public signatures, behavior, serialized components/references, settings/assets, and pipeline order remain equivalent. Compare the final changed-file list with the bounded copy manifest and fail completion on unrelated additions or modifications. List every necessary target-specific deviation.
- Template replication: compare the complete reusable slice and verify its extension points remain intact; confirm only product-specific behavior was excluded.
- Unity scene-wide integration: enumerate all project scenes and explicit exclusions, then verify the required components/prefabs, helpers, settings, loaders, pipeline registrations, package/assembly dependencies, and serialized references in every applicable scene. Exercise editor/runtime behavior when those are part of the change, then wait for the final compilation/import cycle to settle and inspect the post-cycle Console.
