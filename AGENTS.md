# Agent Instructions

Instructions for autonomous agents (Hermes, Claude Code, Codex, …) working in this repository.

## Git commits — co-sign every agent commit

Every commit made by an agent must be co-signed so it can be told apart from a human-authored
commit. Human commits have no such trailer.

- Append this trailer as the last block of the commit message:

  ```
  Co-authored-by: Hermes Homelab agent (<MODEL>) <hermes@homelab.gothuey.dev>
  ```

- `<MODEL>` is the **exact model identifier** used for the current session, e.g.
  `deepseek/deepseek-v4-flash-0731`, `z-ai/glm-5.3`, `anthropic/claude-...`. Use the same value as
  the session's active model.
- Never rewrite, amend, or reword a human-authored commit, and never add this trailer to one.
- If you create a PR, reference the branch and include the same trailer context in the PR body is
  optional (the commit trailer is the source of truth).

Example commit message:

```
fix: allow hermes to see system logs

Co-authored-by: Hermes Homelab agent (z-ai/glm-5.3) <hermes@homelab.gothuey.dev>
```
