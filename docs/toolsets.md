# Shared production toolsets

Toolsets are ordinary project dependencies. Lightflow does not require `.codex/toolsets.json` or another hand-maintained registry.

For Unity, Explorer reads `Packages/manifest.json`, `Packages/packages-lock.json`, and embedded package manifests, then resolves installed code in `Library/PackageCache` or the lockfile's local/Git source. Package identity comes from its own `package.json`, not its cache-folder name.

For Go, Explorer reads `go.work`, `go.mod`, `use`/`replace` directives, and vendor metadata. When Go is available, `go list -m -json all` supplies resolved module directories and `go env GOMODCACHE` locates the local module cache. Discovery does not download missing modules just to inspect them.

For each relevant resolved package/module, Explorer reads the nearest `README.md` first. When documentation is absent or insufficient, it inspects only the manifest, exported/public API, tests, assembly definitions, and relevant source/sample directories needed to establish behavior and integration.

Caches and vendored/generated copies are read-only. To change a shared toolset, locate its writable source repository and obtain explicit approval for that repository. Project-specific behavior stays local. Broad reuse is proposed only for multiple real projects, foundational infrastructure, or meaningful correctness/security/maintenance centralization. Public toolset APIs are at least high risk, and consumers are not automatically upgraded.
