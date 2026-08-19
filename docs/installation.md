# Installation and updates

## Plugin

Add the Git repository as a Codex marketplace, then install the plugin by marketplace name:

```powershell
codex plugin marketplace add ErfanNikouie/Lightflow
codex plugin add lightflow@lightflow
```

Git URL, SSH URL, local root, `owner/repo`, and optional pinned refs are supported by the [official marketplace CLI](https://developers.openai.com/plugins/build/plugins). Refresh later with:

```powershell
codex plugin marketplace upgrade lightflow
codex plugin add lightflow@lightflow
```

Restart the ChatGPT desktop app and use a new task after plugin updates so new skill content is loaded.

## Project scaffold

Run from this repository:

```bat
scripts\setup.bat C:\path\to\project balanced
```

The script resolves the target path, merges a marked block into `AGENTS.md`, preserves unrelated `.codex/config.toml` values, writes the five managed agent files, creates `.codex/toolsets.json` only when absent, injects the chosen profile, validates expected fields, and prints a summary. Existing files that the install/update path changes receive timestamped `.lightflow-backup-*` copies.

Change only model fields later:

```bat
scripts\setup.bat C:\path\to\project quality --profile-only
```

The profile-only path requires an existing scaffold and does not reinstall instructions, toolsets, or role behavior.

The Windows desktop app uses PowerShell natively and shares `%USERPROFILE%\.codex` with native Codex. See [official Windows behavior](https://learn.chatgpt.com/docs/windows/windows-app) when mixing native Windows and WSL repositories.
