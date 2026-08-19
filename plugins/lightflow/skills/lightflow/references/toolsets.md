# Toolset discovery and reuse

A toolset is an approved repository of production code, not an AI tool or MCP. The current project declares known toolsets in `.codex/toolsets.json`; do not hardcode studio repositories into this plugin.

When a capability plausibly belongs to a registered toolset, assign Explorer to inspect the registry and only the relevant repository/package candidates.

For every candidate module or package that may satisfy the request:

1. Resolve its boundary and identity.
   - Go: use `go.work` and `go.mod` for module boundaries, then package directories and import paths.
   - Unity: use UPM `package.json` files and their `name` values; use the target project's `Packages/manifest.json` or lock file to confirm consumption when relevant.
2. Read the nearest package/module `README.md` first, plus the registry's explicit `docs` path when present.
3. If the README is missing or insufficient to establish behavior, compatibility, or integration, inspect the manifest and the smallest useful source surface: exported Go APIs and tests, or Unity assembly definitions plus `Runtime`, `Editor`, `Tests`, and samples as relevant.
4. Return the capability, package/module identity and path, supported integration path, version/pinning constraints, and evidence. Do not dump whole repositories into context.
5. Reuse a suitable existing package or module. If none exists, decide whether the missing capability is project-specific or genuinely reusable.

A reusable candidate normally serves multiple real projects, is foundational studio infrastructure, materially centralizes correctness/security/maintenance, or prevents costly divergent implementations. Hypothetical reuse is insufficient.

Implement project-specific behavior locally. For broadly reusable behavior, propose a toolset extension with rationale, affected packages/modules, compatibility impact, and blast radius.

## Hard approval boundary

Reading and proposing are allowed. Do not change toolset source, APIs, packages, versions, branches, commits, or releases without explicit user approval for that toolset mutation. General permission to implement the current project is not approval.

After approval:

- Public or architectural toolset change: Explorer → Architect (`xhigh`) → Worker → Reviewer.
- Promotion from project into toolset: source Explorer + toolset Explorer → Architect → Worker → Reviewer.
- Existing capability integration: target/toolset exploration as needed → Architect only for nontrivial adaptation → Worker.

Public/shared API changes are at least `HIGH` risk. Prefer pinned/released versions where supported; upgrading consumers is a separate integration task.

## Registry shape

`toolsets.json` has `version: 1` and a `toolsets` array. Each entry may contain:

- `name`: stable identifier.
- `repository`: local path or repository URL.
- `platform`: language/ecosystem such as `unity`, `go`, or `python`.
- `packages`: known reusable packages/modules, either names or objects with `name`, `path`, and optional `docs`.
- `docs`: documentation location.
- `consumption`: how projects pin or consume it.
- `release`: how approved changes are released.
