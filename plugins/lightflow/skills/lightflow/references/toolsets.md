# Dependency/toolset discovery and reuse

Do not require a hand-maintained registry. The project's native manifests, lockfiles, workspace files, and resolved local caches are the dependency map. Inspect only candidates relevant to the requested capability.

## Unity packages

1. Read `Packages/manifest.json`, `Packages/packages-lock.json`, and embedded `Packages/*/package.json` files to identify direct and transitive UPM packages.
2. Resolve installed packages through `Library/PackageCache`. For local, Git, or embedded dependencies, follow the resolved path/source and confirm identity using the package's own `package.json` `name`; do not infer identity from cache folder names alone.
3. Read the nearest package `README.md` first. If it is missing or insufficient, inspect only the useful public surface: `package.json`, assembly definitions, relevant `Runtime`/`Editor` code, tests, and samples.

## Go modules

1. Read `go.work` and `go.mod`, including `use` and `replace` directives, and respect a checked-in `vendor` directory. Use `go env GOMODCACHE` to locate the local cache.
2. When Go is available, run `go list -m -json all` with `GOPROXY=off` so discovery cannot download modules. If offline resolution fails or the read-only sandbox blocks cache writes, parse the workspace/module files and inspect already resolved replacement, vendor, or module-cache paths directly.
3. Read the relevant module or package `README.md` first. If it is missing or insufficient, inspect only `go.mod`, exported APIs, relevant implementation, and tests needed to establish behavior and integration.

Return the capability, package/module identity and resolved path, supported integration path, version/pinning constraints, and evidence. Reuse a suitable dependency through its public API; do not dump whole dependency trees into context.

A reusable candidate normally serves multiple real projects, is foundational studio infrastructure, materially centralizes correctness/security/maintenance, or prevents costly divergent implementations. Hypothetical reuse is insufficient.

Implement project-specific behavior locally. For broadly reusable behavior, propose a toolset extension with rationale, affected packages/modules, compatibility impact, and blast radius.

## Hard approval boundary

Reading and proposing are allowed. Never edit `Library/PackageCache`, `GOMODCACHE`, or vendored/generated dependency copies. To change a shared toolset, locate its writable source repository and obtain explicit approval for that repository change. General permission to implement the current project or update its dependency manifest is not approval to mutate shared source.

After approval, use one Explorer for non-trivial package/consumer discovery and let the primary agent design, implement, and inspect the change. Architect, Worker, Reviewer, and parallel Explorers require an explicit user request or a concrete need that remains after primary reasoning.

Public/shared API changes are at least `HIGH` risk. Prefer pinned/released versions where supported; upgrading consumers is a separate integration task.
