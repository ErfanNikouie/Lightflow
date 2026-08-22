# Shared production toolsets

Toolsets are ordinary project dependencies. Lightflow does not require `.codex/toolsets.json` or another hand-maintained registry.

Before inspecting implementation source in an unfamiliar codebase, package, or tool, determine the relevant scope and search it for Markdown documentation. Read only the one to three most relevant files, prioritizing the nearest `README.md`, `USAGE.md`, `GETTING_STARTED.md`, `QUICKSTART.md`, and relevant usage, installation, integration, or API documents under `docs/`. State which documents informed the work or that none was adequate, then inspect manifests, public APIs, and the smallest necessary source surface only when the documentation is absent or insufficient.

For Unity, Explorer reads `Packages/manifest.json`, `Packages/packages-lock.json`, and embedded package manifests, then resolves installed code in `Library/PackageCache` or the lockfile's local/Git source. Package identity comes from its own `package.json`, not its cache-folder name.

For Go, Explorer reads `go.work`, `go.mod`, `use`/`replace` directives, and vendor metadata. `go env GOMODCACHE` locates the local module cache. When Go is available, Explorer runs `go list -m -json all` with `GOPROXY=off`; if offline resolution fails, it inspects manifests and already resolved paths directly instead of downloading modules.

For each relevant resolved package or module, Explorer applies the same documentation-first process. When documentation is absent or insufficient, it inspects only the manifest, exported/public API, tests, assembly definitions, and relevant source or sample directories needed to establish behavior and integration.

Caches and vendored/generated copies are read-only. To change a shared toolset, locate its writable source repository and obtain explicit approval for that repository. Project-specific behavior stays local. Broad reuse is proposed only for multiple real projects, foundational infrastructure, or meaningful correctness/security/maintenance centralization. Public toolset APIs are at least high risk, and consumers are not automatically upgraded.
