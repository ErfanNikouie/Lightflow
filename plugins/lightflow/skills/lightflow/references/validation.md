# Validation and tool selection

Worker owns normal validation. When reasonably applicable, completion means requested behavior is implemented, explicit requirements are satisfied, existing behavior remains intact, builds and relevant automated checks pass, runtime or visual behavior is exercised where meaningful, material regressions are resolved, and public/architectural documentation is current.

Compilation alone is insufficient when meaningful runtime validation is available. Use the cheapest reliable tool that can validate the requirement.

## Tool selection

- Unity source-only edits: use source/toolchain checks; do not invoke editor automation automatically.
- Unity scene, prefab, serialized-state, asset, Play Mode, runtime input, screenshot, or Console work: use the available Unity editor/MCP tooling.
- Go/Nakama: use repository scripts, `go test`, compiler, `go vet` or appropriate static checks, Docker/Compose, and Nakama runtime/log/API validation when relevant.
- Python/web: use normal tests and scripts; use browser automation when actual interaction or visual behavior matters.

If an operational tool lacks a one-off capability, use a reasonable workaround. If the gap will recur across projects, finish the task when possible and propose a separate tool/MCP/workflow improvement; do not silently expand reusable AI tooling during unrelated work.

Reviewer checks correctness, requirements, regressions, architectural violations, concurrency/networking, security, meaningful missing tests, maintainability, and unnecessary complexity. Route implementation defects back to Worker and architectural failures to Architect.

## Reference and coverage validation

- Exact replication: diff the relevant source and target artifact sets where practical. Confirm file/class/member names, public signatures, behavior, serialized components/references, settings/assets, and pipeline order remain equivalent. List every necessary target-specific deviation.
- Template replication: compare the complete reusable slice and verify its extension points remain intact; confirm only product-specific behavior was excluded.
- Unity scene-wide integration: enumerate all project scenes and explicit exclusions, then verify the required components/prefabs, helpers, settings, loaders, pipeline registrations, package/assembly dependencies, and serialized references in every applicable scene. Exercise editor/runtime behavior when those are part of the change.
