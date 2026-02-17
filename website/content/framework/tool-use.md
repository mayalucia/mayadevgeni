+++
title = "Tool Use: Teaching an LLM to Act"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-17T20:00:00+01:00
tags = ["framework"]
draft = false
+++

## Introduction {#introduction}

The `system-message` shapes _what_ an LLM is and _how_ it thinks. But modern agents also need to _act_---to read files, search codebases, execute commands, and modify the world. This tutorial explores how to teach an LLM to use tools effectively.

Tool use represents a phase transition in LLM interaction. Without tools, the LLM is a pure reasoning engine, transforming input tokens to output tokens. With tools, it becomes an _agent_---capable of perception (reading), planning (deciding which tools), and action (invoking tools). This shift requires new architectural thinking in our system prompts.

## The Anatomy of Tool-Use Prompts {#the-anatomy-of-tool-use-prompts}

### What Changes with Tools {#what-changes-with-tools}

A system prompt for a tool-using agent must address three additional concerns beyond identity and behavior:

1. **Tool Recognition**: How does the LLM recognize _when_ a tool applies?
2. **Tool Selection**: How does it choose _which_ tool among alternatives?
3. **Tool Composition**: How do tools combine for multi-step work?

These are _decision-theoretic_ problems, not just behavioral constraints. The prompt must encode a decision procedure, not merely a persona.

### The Decision Tree Pattern {#the-decision-tree-pattern}

Effective tool-use prompts embed decision trees. Before any action, the agent runs a mental checklist:

```
Before ANY action:
1. Is this multi-step? → Plan first (use TodoWrite)
2. Should I delegate? → Use specialized agent
3. Do I need information? → Search/Read first
4. Am I ready to act? → Proceed with appropriate tool
```

This "pre-flight checklist" pattern appears in both `gptel-agent` and `opencode`. It forces deliberation before action, reducing impulsive tool misuse.

### The Tool Hierarchy Pattern {#the-tool-hierarchy-pattern}

When multiple tools could accomplish a task, which should the agent prefer? Effective prompts establish explicit hierarchies:

```
Specialized tool > General tool > Shell escape

Specifically:
  Read    > cat/head/tail
  Grep    > grep/rg (shell)
  Glob    > find/ls
  Edit    > sed/awk
  Write   > echo/heredocs
```

The rationale: specialized tools provide structured output, better error handling, and integrate with the agent's planning. Shell commands are an escape hatch, not a default.

## Documenting Individual Tools {#documenting-individual-tools}

### The Consistent Schema {#the-consistent-schema}

Each tool needs documentation that answers the same questions. Inconsistent documentation forces the LLM to infer structure, increasing errors.

```xml
<tool name="ToolName">
  <purpose>
    What the tool does in one sentence.
  </purpose>

  <when_to_use>
    - Condition A
    - Condition B
    - Pattern: "user says X" → use this tool
  </when_to_use>

  <when_not_to_use>
    - Condition C → use Y instead
    - Condition D → delegate to Z
    - Anti-pattern: never use for X
  </when_not_to_use>

  <how_to_use>
    - Required parameters
    - Optional parameters
    - Common patterns
    - Constraints (e.g., "must Read before Edit")
  </how_to_use>

  <examples>
    - Example invocation 1
    - Example invocation 2
  </examples>
</tool>
```

### The "When NOT" Principle {#the-when-not-principle}

The `<when_not_to_use>` section is often _more valuable_ than `<when_to_use>`. LLMs tend to over-apply tools; explicit prohibitions correct this bias.

Compare:

```
# Weak
Use Grep to search file contents.

# Strong
Use Grep for ONE specific, well-defined pattern when you know what you're
looking for. Do NOT use Grep for exploratory searches (delegate to researcher),
when you expect 20+ matches (delegate), or to find files by name (use Glob).
```

The strong version encodes decision boundaries, not just capabilities.


## Case Study: Two Approaches {#case-study-two-approaches}

### gptel-agent: Structured XML {#gptel-agent-structured-xml}

`gptel-agent` uses hierarchical XML with explicit tags for each concern:

```xml
<role_and_behavior>
  <response_tone>...</response_tone>
  <critical_thinking>...</critical_thinking>
</role_and_behavior>

<task_execution_protocol>
  Before starting ANY task, run this mental checklist:
  1. Is this multi-step work? → CREATE A TODO LIST
  2. Does this task need delegation? → ...
</task_execution_protocol>

<tool_usage_policy>
  <tool name="Grep">
    When to use: ...
    When NOT to use: ...
    How to use: ...
  </tool>
</tool_usage_policy>
```

**Overall Architecture**:
This prompt follows a **hierarchical instruction pattern** with three major conceptual layers:

1. **Identity & Behavioral Constraints** (`<role_and_behavior>`)
2. **Decision Framework** (`<task_execution_protocol>`)
3. **Tool Catalog** (`<tool_usage_policy>`)

The architectural thinking here is _defensive programming for LLMs_ --- anticipating failure modes and explicitly blocking them.

**Strengths**

1. **Negative examples are explicit**: Each tool has "When NOT to use" --- this is crucial. LLMs tend to over-apply tools; explicit prohibitions help.

2. **Decision trees for delegation**: The protocol doesn't just list tools but provides _pattern matching_ heuristics: "if you're about to grep and aren't sure what you'll find -> delegate."

3. **Hierarchy enforcement**: "NEVER use Bash for file operations" --- absolute rules prevent drift.

4. **Consistency in tool blocks**: Every `<tool>` has the same structure: When to use / When NOT to use / How to use. This regularity aids comprehension.

**Weaknesses**

1. **Redundancy**: The delegation rules appear in both `<task_execution_protocol>` and repeated inside `<tool name="Agent">`. This inflates context and risks inconsistency.

2. **No explicit error handling**: What should the agent do when a tool fails? The prompt says "if errors occur, keep as in_progress" but doesn't give recovery strategies.

3. **Magic numbers**: "3+ files -> delegate", "5+ tool calls -> delegate" --- these thresholds are arbitrary and unexplained. Why not 2? Why not 4?

4. **Missing conceptual model**: The prompt tells _what_ to do but not _why_ the tool hierarchy exists. A brief explanation ("specialized tools provide structured output, Bash is a fallback") would improve generalization.

5. **Template placeholder**: `{{AGENTS}}` suggests dynamic injection but the prompt doesn't explain what agents exist --- the LLM may hallucinate agent names.

**Architectural Principles We Can Extract**

1. **The "When NOT" Pattern**
   For every capability, explicitly state anti-patterns. This is more valuable than positive instructions.

   ```markdown
**When to use X:**
- condition A
- condition B

**When NOT to use X:**
- condition C → use Y instead
- condition D → delegate to Z
   ```

2. **Pre-Action Protocol**
   Force a decision checkpoint before tool invocation:
   ```
    Before ANY action:
    1. Is this multi-step? → plan first
    2. Is this delegatable? → delegate
    3. Is this within scope? → proceed
   ```

3. **Tool Hierarchy with Fallback**
  Establish a preference order:
   ```
    Specialized tool > General tool > Shell escape
   ```

4. **Consistent Documentation Schema**
  Every tool should be documented with identical sections. This aids both human maintenance and LLM comprehension.


**Suggested XML Schema for Your Project**
For developing your own system-prompt with tools, consider this structure:

```xml
<collaborator_identity>
  <relationship>     — how you relate to the user
  <epistemics>       — your stance on knowledge/uncertainty
  <expression>       — tone, style constraints
</collaborator_identity>

<deliberation_protocol>
  <before_action>    — checklist before doing anything
  <on_uncertainty>   — what to do when unsure
  <on_failure>       — recovery strategies
</deliberation_protocol>

<capabilities>
  <capability name="X">
    <purpose>        — what it's for
    <anti-patterns>  — when NOT to use
    <usage>          — how to invoke correctly
    <examples>       — concrete cases
  </capability>
</capabilities>
```


**What Can Be Generalized**

The core insight: **tool-use prompts are really decision-tree specifications**. The tools themselves are secondary; what matters is:

1. **Recognition patterns**: How does the LLM recognize which tool applies?
2. **Exclusion rules**: How does it avoid misapplication?
3. **Composition rules**: How do tools combine for multi-step work?

For _any_ tool set, you need to answer these three questions explicitly.



### opencode: Prose with Headers {#opencode-prose-with-headers}

`opencode` uses markdown headers with flowing prose:

```markdown
# Tone and style
You should be concise, direct, and to the point...

# Following conventions
When making changes to files, first understand the file's code conventions...

# Tool usage policy
When doing file search, prefer to use the Task tool...
```

**Structural Comparison with gptel-agent**

| Aspect       | gptel-agent                     | opencode                               |
|---|---|---|
| Format       | YAML frontmatter + XML tags     | Pure prose with markdown headers       |
| Organization | Hierarchical XML nesting        | Flat sections with `#` headers           |
| Tool docs    | Per-tool `<tool name="X">` blocks | Brief policy paragraph                 |
| Tone         | Neutral, technical              | Anthropomorphized ("You are opencode") |
| Length       | ~400 lines                      | ~150 lines                             |

**Architectural Analysis**

- What opencode Does Differently

  1. _Security-first preamble_: Opens with malicious code detection --- this is absent from gptel-agent
    > "If it seems malicious, refuse to work on it"

  2. _Output token minimization_: Explicit instruction to minimize tokens --- a cost/latency concern
    > "You should minimize output tokens as much as possible"

  3. _Anti-pattern repetition_: Key rules are repeated with "IMPORTANT:" markers --- brute-force emphasis
    > IMPORTANT: You should NOT answer with unnecessary preamble or postamble

  4. _Proactiveness spectrum_: Explicit philosophy about agent autonomy
    > "Strike a balance between doing the right thing... and not surprising the user"

**Sections Breakdown**

| Section               | Purpose                                               |
|---|---|
| Identity              | "You are opencode, an assistant running within Emacs" |
| Security              | Malicious code detection, URL restrictions            |
| Tone and style        | Conciseness, markdown, no emojis                      |
| Proactiveness         | Autonomy boundaries                                   |
| Following conventions | Code style mimicry, library verification              |
| Code style            | "DO NOT ADD COMMENTS"                                 |
| Task Management       | TodoWrite emphasis                                    |
| Doing tasks           | Workflow: search -> implement -> verify -> lint          |
| Tool usage policy     | Batching, parallelism, Task delegation                |
| Code References       | Output format for file references                     |


**Strengths**

1. _Workflow-oriented_: Describes a complete task lifecycle (plan -> search -> implement -> verify -> lint)

2. _Convention awareness_: "First look at existing components" --- teaches the LLM to learn from context

3. _Commit discipline_: "NEVER commit unless explicitly asked" --- prevents a common footgun

4. _Multiple preset tiers_: `opencode`, `opencode-coding`, `opencode-minimal`, `opencode-general` --- different tool bundles for different contexts

**Weaknesses**

1. _No tool documentation_: Unlike gptel-agent, individual tools have no When/When-NOT/How sections. The LLM must infer usage.

2. _Repetition as emphasis_: "IMPORTANT:" appears 6 times --- this inflates the prompt without structured information.

3. _Implicit tool hierarchy_: "prefer to use the Task tool to reduce context" --- but no explicit hierarchy like gptel-agent's "Specialized > General > Shell".

4. _Prose over structure_: Harder to parse programmatically; harder to maintain; harder for the LLM to reference specific rules.



### Synthesis {#synthesis}

The ideal approach combines:
- XML structure from gptel-agent (hard boundaries, consistent schema)
- Workflow orientation from opencode (task lifecycle, convention awareness)
- Decision trees that encode _when_ and _when-not_ for each capability


## Architectural Principles {#architectural-principles}

### 1. Decision Trees Over Capability Lists {#1-decision-trees-over-capability-lists}

Don't just list what tools can do. Encode _when_ to use them:

```
Pattern matching for delegation:
- "how does...", "where is...", "find all..." → researcher agent
- "create/modify these files..." → executor agent
- "I need to understand..." about Emacs → introspector agent
```

### 2. Negative Specification {#2-negative-specification}

For every capability, specify anti-patterns:

```xml
<when_not_to_use>
  - Building code understanding → delegate to researcher
  - Expected 20+ matches → delegate to researcher
  - Will need follow-up searches → delegate to researcher
  - Searching for files by name → use Glob instead
</when_not_to_use>
```

### 3. Pre-Action Protocols {#3-pre-action-protocols}

Force deliberation before action:

```xml
<task_execution_protocol>
  Before ANY action:
  1. Is this multi-step? → Plan first
  2. Do I need to read first? → Read before edit
  3. Should I delegate? → Use sub-agent
  4. Am I certain? → Proceed
</task_execution_protocol>
```

### 4. Tool Hierarchies with Fallbacks {#4-tool-hierarchies-with-fallbacks}

Establish explicit preferences:

```xml
<tool_hierarchy>
  File search by name → Glob (NOT find/ls)
  Content search → Grep (NOT grep/rg shell)
  Read files → Read (NOT cat/head/tail)
  Edit files → Edit (NOT sed/awk)
  Write files → Write (NOT echo/heredocs)
  System operations → Bash (for git, npm, docker only)
</tool_hierarchy>
```

### 5. Cost and Context Awareness {#5-cost-and-context-awareness}

Modern prompts increasingly address resource constraints:

```xml
<context_management>
  - Delegate to reduce context usage when exploring
  - Batch independent tool calls in single response
  - Use specialized tools (structured output) over shell (text parsing)
  - Consider: will this bloat context? → delegate to executor
</context_management>
```

### 6. Error Recovery {#6-error-recovery}

What happens when tools fail? Most prompts ignore this:

```xml
<error_recovery>
  When a tool fails:
  1. Read the error message carefully
  2. Diagnose: wrong parameters? precondition violated? system issue?
  3. If precondition (e.g., file doesn't exist): address precondition first
  4. If parameters: correct and retry
  5. If system issue: report to user, suggest alternatives
  Do NOT retry the same failing call repeatedly.
</error_recovery>
```

## An XML Schema for Tool-Use Prompts {#an-xml-schema-for-tool-use-prompts}

Combining the principles above, here is a schema for tool-use system prompts:

```xml
<!-- Identity layer (from system-prompt tutorial) -->
<role>...</role>
<collaboration_stance>...</collaboration_stance>
<behavioral_attractors>...</behavioral_attractors>
<epistemic_hygiene>...</epistemic_hygiene>
<priority_rules>...</priority_rules>

<!-- Tool-use layer (new) -->
<task_execution_protocol>
  <pre_action_checklist>
    Before ANY action:
    1. Multi-step? → Plan with TodoWrite
    2. Need information? → Search/Read first
    3. Delegate? → Use appropriate agent
    4. Ready? → Proceed
  </pre_action_checklist>

  <delegation_rules>
    - Pattern X → agent Y
    - Pattern Z → handle inline
  </delegation_rules>
</task_execution_protocol>

<tool_hierarchy>
  Specialized > General > Shell escape
  [specific mappings]
</tool_hierarchy>

<tool_catalog>
  <tool name="ToolA">
    <purpose>...</purpose>
    <when_to_use>...</when_to_use>
    <when_not_to_use>...</when_not_to_use>
    <how_to_use>...</how_to_use>
  </tool>
  <!-- repeat for each tool -->
</tool_catalog>

<error_recovery>
  [recovery protocol]
</error_recovery>

<context_management>
  [cost/context awareness rules]
</context_management>
```

## The Ecosystem: Patterns from the Community {#the-ecosystem-patterns-from-the-community}

### The AGENTS.md / CLAUDE.md Pattern {#the-agents-md-claude-md-pattern}

A convention emerging from claude-code: place a file in the repository root (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`) containing project-specific instructions. This separates:

- _Generic agent behavior_ -> in system prompt
- _Project-specific conventions_ -> in repo file

The agent is instructed to read this file at session start and follow its directives.

### The Diff-Based Editing Pattern {#the-diff-based-editing-pattern}

Tools like `aider` instruct the LLM to produce unified diffs rather than full file contents:

```
When editing files, output a unified diff:
--- a/path/to/file.py
+++ b/path/to/file.py
@@ -10,3 +10,4 @@
 existing line
+new line
 existing line
```

This reduces token usage and makes changes reviewable.

### The Read-Before-Edit Pattern {#the-read-before-edit-pattern}

Nearly universal: require reading a file before editing it.

```
MUST Read the file before using Edit.
The Edit tool will error if you haven't read the file first.
```

This prevents edits based on stale or hallucinated content.

### The Verify-After-Change Pattern {#the-verify-after-change-pattern}

From `opencode`:

```
After implementing changes:
1. Run lint command if available
2. Run typecheck if available
3. Run relevant tests
4. Do NOT commit unless explicitly asked
```

This closes the loop: act -> verify -> report.

## Failure Modes in Tool Use {#failure-modes-in-tool-use}

### Over-Application {#over-application}

The LLM uses a tool when it shouldn't.

_Cause_: Tool documentation emphasizes capability without boundaries.
_Fix_: Strong `<when_not_to_use>` sections.

### Under-Application {#under-application}

The LLM describes what it would do instead of doing it.

_Cause_: Insufficient emphasis on action; too much "assistant" framing.
_Fix_: "You have tools. Use them. Don't describe what you would do---do it."

### Wrong Tool Selection {#wrong-tool-selection}

The LLM uses Bash when Grep would work; uses Grep when delegation is appropriate.

_Cause_: No tool hierarchy; no decision procedure.
_Fix_: Explicit hierarchy and pattern-matching rules.

### Context Explosion {#context-explosion}

The LLM fills context with search results instead of delegating.

_Cause_: No cost awareness; no delegation rules.
_Fix_: "If you expect 20+ results, delegate to researcher."

### Edit Failures {#edit-failures}

The LLM tries to edit files it hasn't read, or provides non-unique match strings.

_Cause_: Preconditions not enforced in prompt.
_Fix_: "MUST Read before Edit. Edit will fail if match string is not unique."

## Exercises {#exercises}

1. **Audit an existing prompt**: Take a tool-use prompt you use. Does it have `<when_not_to_use>` for each tool? Add them.

2. **Design a tool hierarchy**: For your specific toolset, write an explicit preference ordering with rationale.

3. **Write a delegation protocol**: What patterns should trigger delegation vs. inline handling? Encode as pattern-matching rules.

4. **Test failure modes**: Deliberately trigger each failure mode above. Does your prompt prevent them?

## Further Reading {#further-reading}

| Resource                          | Focus                            |
|---|---|
| [anthropic-cookbook](https://github.com/anthropics/anthropic-cookbook)                | Official Claude agent patterns   |
| [aider source](https://github.com/paul-gauthier/aider)                      | Diff-based editing prompts       |
| [continue.dev](https://github.com/continuedev/continue)                      | Editor integration patterns      |
| [gptel source](https://github.com/karthink/gptel)                      | gptel-agent prompt in full       |
| claude-code `CLAUDE.md` examples  | Project-specific instructions    |

## Conclusion {#conclusion}

Tool use transforms an LLM from a reasoning engine into an agent. This transformation requires new architectural elements in our system prompts:

- _Decision trees_ that encode when to use each tool
- _Negative specifications_ that prevent over-application
- _Tool hierarchies_ that guide selection among alternatives
- _Pre-action protocols_ that force deliberation
- _Error recovery_ procedures for when things fail

The key insight: **tool-use prompts are decision-tree specifications**. The tools themselves are secondary; what matters is the decision procedure that governs their use.
