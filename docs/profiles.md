# Model profiles

Profile values are centralized in `profiles/*.json` and use current Codex GPT-5.6 IDs: `gpt-5.6-sol`, `gpt-5.6-terra`, and `gpt-5.6-luna`.

| Role | Balanced | Quality | Economy |
|---|---|---|---|
| Orchestrator | Sol medium | Sol high | Terra medium |
| Explorer | Luna medium | Terra high | Luna medium |
| Architect | Sol xhigh | Sol xhigh | Sol xhigh |
| Worker | Sol medium | Sol high | Terra medium |
| Reviewer | Sol high | Sol xhigh | Terra high |

Balanced is the default. Edit the JSON files to tune a team fork; role instructions remain unchanged. Switch an installed repository without reinstalling other scaffold files:

```bat
scripts\setup.bat C:\path\to\project economy --profile-only
```

The main session receives the Orchestrator model, while each project agent receives its role-specific values. Model selection is deterministic setup behavior, not runtime plugin mutation.
