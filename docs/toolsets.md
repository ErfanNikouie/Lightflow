# Shared production toolsets

Toolsets are approved repositories of production code, not AI tools or MCP servers. A configured target project keeps its registry in `.codex/toolsets.json`:

```json
{
  "version": 1,
  "toolsets": [
    {
      "name": "studio-go",
      "repository": "C:\\src\\studio-go",
      "platform": "go",
      "packages": [
        { "name": "matchmaking", "path": "matchmaking", "docs": "matchmaking/README.md" },
        { "name": "economy", "path": "economy", "docs": "economy/README.md" }
      ],
      "docs": "README.md",
      "consumption": "Pinned Go module versions",
      "release": "Tagged release after review"
    }
  ]
}
```

The registry prevents repeated repository discovery. Agents may inspect registered toolsets and propose changes. They may not modify source, APIs, package versions, branches, commits, or releases without explicit user approval for that toolset mutation. General permission to implement the current project is not approval.

Explorer resolves Go modules through `go.work`/`go.mod` and Unity UPM packages through their `package.json` name and path. For each relevant package/module it reads the nearest `README.md` first. When documentation is absent or insufficient, it inspects only the manifest, exported/public API, tests, assembly definitions, and relevant source/sample directories needed to establish behavior and integration.

Project-specific behavior stays local. Broad reuse is proposed only for multiple real projects, foundational infrastructure, or meaningful correctness/security/maintenance centralization. Public toolset APIs are at least high risk, and consumers are not automatically upgraded.
