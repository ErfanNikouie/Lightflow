# Migrating existing projects

This migration applies to projects configured by Lightflow before the four-specialist layout and `gpt-5.6-sol` model ID.

## 1. Update Lightflow

From the Lightflow checkout:

```powershell
git pull
codex plugin marketplace upgrade lightflow
codex plugin add lightflow@lightflow
```

Start a new Codex task after reinstalling the plugin.

## 2. Run one full project setup

Do not use `--profile-only` for the first migration run:

```bat
scripts\setup.bat C:\path\to\project refined-balanced
```

The full run updates the managed `AGENTS.md` block and model IDs, installs Explorer, Architect, Worker, and Reviewer, and backs up then removes the obsolete `.codex/agents/orchestrator.toml`. The primary Codex agent remains Orchestrator. Existing changed files receive timestamped `.lightflow-backup-*` copies.

## Local agent configuration

Recommended when teammates want independent agent/model tuning:

```gitignore
.codex/agents/
.codex/config.toml
*.lightflow-backup-*
```

Each teammate installs Lightflow and runs the full setup locally. Commit the shared `AGENTS.md`, but not the generated agents, config, or backup files. Everyone should use the same Lightflow revision when consistent routing matters.

## Git-tracked agent configuration

If the project intentionally versions Codex configuration, run the full setup and commit:

- The updated `AGENTS.md` and `.codex/config.toml`.
- Explorer, Architect, Worker, and Reviewer TOML files.
- The deletion of `.codex/agents/orchestrator.toml`.

Do not commit `.lightflow-backup-*` files. Review any customized legacy Orchestrator backup before removing it locally.

## Multiple local projects

After reviewing the first migrated project, the same checkout can update several projects:

```powershell
$projects = @(
    "C:\path\to\project-a",
    "C:\path\to\project-b"
)

foreach ($project in $projects) {
    & .\scripts\setup.ps1 -TargetRepository $project -Profile refined-balanced
}
```

## Verify a project

```powershell
Get-ChildItem C:\path\to\project\.codex\agents -Filter *.toml
Select-String -Path C:\path\to\project\.codex\config.toml -Pattern '^model'
```

Expected specialists are `explorer.toml`, `architect.toml`, `worker.toml`, and `reviewer.toml`. The root model should be `gpt-5.6-sol` for Refined Balanced, Balanced, or Quality, and `gpt-5.6-terra` for Economy. Project-local skills such as `.codex/skills/*` and unrelated manifests are not changed by setup.
