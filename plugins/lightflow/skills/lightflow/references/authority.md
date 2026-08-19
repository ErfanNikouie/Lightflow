# Authority, skills, and simplicity

When guidance conflicts, use this precedence:

1. Current explicit user instruction
2. Explicit user-provided architecture or design
3. Project `AGENTS.md`
4. Accepted ADRs and architecture documentation
5. Established codebase architecture and conventions
6. Project-local skills
7. This shared workflow
8. Ponytail principles
9. General model judgment

Within a level, newer and more specific guidance wins. Higher levels define what must be achieved; lower levels help decide how.

Do not silently follow a higher-priority instruction when it creates an important contradiction, impossible implementation, serious regression, or unsafe condition. Surface the conflict and resolve or escalate it.

Ponytail applies implicitly to unnecessary complexity: reuse existing code, standard/platform features, and installed dependencies before adding code; avoid speculative wrappers, factories, interfaces, and duplicate infrastructure. It never removes explicit abstractions, reusable capabilities, architectural boundaries, accessibility, safety, validation, or error handling. Use an installed Ponytail review skill only when deeper simplicity review materially improves the result.

## Installed skills

Use relevant platform, vendor, project, and review skills that are available in the current Codex installation. Skill descriptions determine when they apply; Lightflow does not hardcode a private skill inventory. Its custom agents omit `skills.config`, so they inherit the parent session's skill configuration. This lets Unity, Go, Ponytail, and other compatible skills participate without becoming plugin dependencies. If a skill is not installed or is disabled, do not claim to use it; fall back to repository guidance and native tooling.
