# Authority

The runtime hierarchy is:

1. Current explicit user instruction
2. Explicit user-provided architecture/design
3. Project `AGENTS.md`
4. Accepted ADRs and architecture documentation
5. Established codebase architecture and conventions
6. Project-local skills
7. Shared Lightflow workflow
8. Ponytail principles
9. General model judgment

Within one level, newer and more specific guidance wins. Higher levels define the required outcome; lower levels help choose the implementation. Important contradictions, unsafe requirements, and impossible combinations are surfaced rather than followed silently.

The canonical agent-facing policy is `plugins/lightflow/skills/lightflow/references/authority.md`.
