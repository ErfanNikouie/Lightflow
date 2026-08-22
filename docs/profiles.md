# Model profiles

Profile values are centralized in `profiles/*.json` and use current Codex GPT-5.6 IDs: `gpt-5.6-sol`, `gpt-5.6-terra`, and `gpt-5.6-luna`.

| Role | Refined Balanced | Balanced | Quality | Economy |
|---|---|---|---|---|
| Orchestrator | Sol medium | Sol medium | Sol high | Terra medium |
| Explorer | Luna low | Luna medium | Terra high | Luna medium |
| Architect | Sol high | Sol xhigh | Sol xhigh | Sol xhigh |
| Worker | Terra medium | Sol medium | Sol high | Terra medium |
| Reviewer | Terra high | Sol high | Sol xhigh | Terra high |

`refined-balanced` is recommended for the best quality/quota tradeoff: the primary remains Sol medium, while Luna low handles non-trivial read-only repository exploration. Sol keeps the reasoning and implementation work without spending its context on broad file tracing. `balanced` remains the setup-script default for compatibility. Edit the JSON files to tune a team fork; role instructions remain unchanged. Switch an installed repository without reinstalling other scaffold files:

```bat
scripts\setup.bat C:\path\to\project refined-balanced --profile-only
```

The main session receives the Orchestrator model, while each project agent receives its role-specific values. Model selection is deterministic setup behavior, not runtime plugin mutation.

These JSON profiles apply only to the Codex scaffold. Claude Code uses Haiku low for Explorer and inherits the active session model for the opt-in Architect, Worker, and Reviewer agents.
