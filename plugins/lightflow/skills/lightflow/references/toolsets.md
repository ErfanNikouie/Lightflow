# Dependency/toolset discovery and reuse

Do not require a hand-maintained registry. The project's native manifests, lockfiles, workspace files, and resolved local caches are the dependency map. Inspect only candidates relevant to the requested capability.

## Unity packages

1. Read `Packages/manifest.json`, `Packages/packages-lock.json`, and embedded `Packages/*/package.json` files to identify direct and transitive UPM packages.
2. Resolve installed packages through `Library/PackageCache`. For local, Git, or embedded dependencies, follow the resolved path/source and confirm identity using the package's own `package.json` `name`; do not infer identity from cache folder names alone.
3. Read the nearest package `README.md` first. If it is missing or insufficient, inspect only the useful public surface: `package.json`, assembly definitions, relevant `Runtime`/`Editor` code, tests, and samples.

## Go modules

1. Read `go.work` and `go.mod`, including `use` and `replace` directives. When Go is available, prefer `go list -m -json all` for resolved module identities/directories and `go env GOMODCACHE` for the local module cache. Also respect a checked-in `vendor` directory.
2. Do not download dependencies solely for discovery. Inspect already resolved workspace, replacement, vendor, or module-cache paths.
3. Read the relevant module or package `README.md` first. If it is missing or insufficient, inspect only `go.mod`, exported APIs, relevant implementation, and tests needed to establish behavior and integration.

Return the capability, package/module identity and resolved path, supported integration path, version/pinning constraints, and evidence. Reuse a suitable dependency through its public API; do not dump whole dependency trees into context.

A reusable candidate normally serves multiple real projects, is foundational studio infrastructure, materially centralizes correctness/security/maintenance, or prevents costly divergent implementations. Hypothetical reuse is insufficient.

Implement project-specific behavior locally. For broadly reusable behavior, propose a toolset extension with rationale, affected packages/modules, compatibility impact, and blast radius.

## Hard approval boundary

Reading and proposing are allowed. Never edit `Library/PackageCache`, `GOMODCACHE`, or vendored/generated dependency copies. To change a shared toolset, locate its writable source repository and obtain explicit approval for that repository change. General permission to implement the current project or update its dependency manifest is not approval to mutate shared source.

After approval:

- Public or architectural toolset change: Explorer → Architect (`xhigh`) → Worker → Reviewer.
- Promotion from project into toolset: source Explorer + toolset Explorer → Architect → Worker → Reviewer.
- Existing capability integration: target/toolset exploration as needed → Architect only for nontrivial adaptation → Worker.

Public/shared API changes are at least `HIGH` risk. Prefer pinned/released versions where supported; upgrading consumers is a separate integration task.
