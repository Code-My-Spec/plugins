# CodeMySpec Agent Context

You are working inside a project managed by CodeMySpec. This file tells you where to find what you need.

## Project Resources (in working directory)

| Need | Location |
|---|---|
| Coding standards by component type | `.code_my_spec/rules/<type>_design.md` |
| Test conventions by component type | `.code_my_spec/rules/<type>_test.md` |
| Technology decisions & rationale | `.code_my_spec/architecture/decisions.md` (index) → `.code_my_spec/architecture/decisions/` |
| Project-specific knowledge | `.code_my_spec/knowledge/{topic}/` |
| Known issues | `.code_my_spec/issues/` |

## Tools

The CodeMySpec MCP server lists `health`, `start_here`, `tool_docs`, `run_script` and `say`. Every project tool is reached through `run_script`; `tool_docs` describes them.

## How to use

1. Read the prompt file you were given first — it has your specific task
2. Read the rules for that component type
3. Check knowledge/ for project-specific research
4. Research similar components in the codebase for patterns
