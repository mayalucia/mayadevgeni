+++
title = "Tool Integration"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["framework"]
draft = false
+++

Tool use represents a phase transition in LLM interaction. Without tools, the LLM is a pure reasoning engine, transforming input tokens to output tokens. With tools, it becomes an /agent/—capable of perception (reading), planning (deciding which tools), and action (invoking tools).


## Decision Trees Over Capability Lists {#decision-trees-over-capability-lists}

Effective tool-use prompts embed decision trees, not just capability lists. Before any action, the agent runs a mental checklist:

```text
Before ANY action:
1. Is this multi-step? → Plan first
2. Should I delegate? → Use specialized agent
3. Do I need information? → Search/Read first
4. Am I ready to act? → Proceed with appropriate tool
```

This "pre-flight checklist" pattern forces deliberation before action, reducing impulsive tool misuse.


## The Tool Catalog Pattern {#the-tool-catalog-pattern}

Each tool needs consistent documentation:

-   **Purpose**: What the tool does
-   **When to use**: Conditions and patterns that trigger this tool
-   **When NOT to use**: Anti-patterns and alternatives (often more valuable than positive instructions)
-   **How to use**: Parameters, constraints, common patterns

The `<when_not_to_use>` section is critical. LLMs tend to over-apply tools; explicit prohibitions correct this bias.


## Tool Hierarchies {#tool-hierarchies}

When multiple tools could accomplish a task, establish explicit preferences:

```text
Specialized tool > General tool > Shell escape

Specifically:
  Read    > cat/head/tail
  Grep    > grep/rg (shell)
  Glob    > find/ls
  Edit    > sed/awk
```

Rationale: specialized tools provide structured output, better error handling, and integrate with the agent's planning.


## Failure Modes in Tool Use {#failure-modes-in-tool-use}

| Failure Mode         | Cause                              | Fix                                     |
|----------------------|------------------------------------|-----------------------------------------|
| Over-Application     | No boundaries on tool use          | Strong `<when_not_to_use>` sections     |
| Under-Application    | Too much "assistant" framing       | "Use tools. Don't describe—do."         |
| Wrong Tool Selection | No hierarchy or decision procedure | Explicit hierarchy and pattern-matching |
| Context Explosion    | No cost awareness                  | Delegation rules for large result sets  |
| Edit Failures        | Preconditions not enforced         | "MUST Read before Edit"                 |
