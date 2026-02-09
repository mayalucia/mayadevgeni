+++
title = "Tutorial Chapter 7: Scaling Up"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:19+01:00
tags = ["tutorial"]
draft = false
+++

The prompts we've crafted so far have been compact—under 100 tokens, focused on a single role with a few behavioral constraints. This suffices for many purposes. But some collaborations demand more: explicit priority orderings, detailed epistemic standards, nuanced interaction patterns that can't compress into a sentence or two.

This section explores when and how to scale up, using a substantial real-world prompt as our case study.


## When Simple Isn't Enough {#when-simple-isn-t-enough}

A simple prompt fails to meet your needs when you observe:

-   **Inconsistent behavior across contexts**: The model handles some situations well but stumbles in others that matter to you. A 50-token prompt can't anticipate every context.

-   **Ambiguous priority resolution**: When constraints conflict—thoroughness vs. brevity, directness vs. Socratic questioning—the model guesses, and guesses wrong.

-   **Epistemic slippage**: The model presents speculation as fact, or fails to signal uncertainty in domains where precision matters.

-   **Role confusion**: The persona drifts toward generic assistant behavior because the prompt didn't establish enough distinctive texture.

These symptoms suggest you need more structure—not just more words, but organized complexity that the model can parse and maintain.


## The Architecture of Complex Prompts {#the-architecture-of-complex-prompts}

A complex prompt is not a long simple prompt. It requires _architectural thinking_: how to organize constraints so the attention mechanism can track them, how to create redundancy that reinforces rather than clutters, how to establish hierarchy that survives the noise of extended conversation.


### Sections as Attention Anchors {#sections-as-attention-anchors}

Structure your prompt with clear sections, each addressing a distinct dimension of behavior:

-   **Role/Identity**: Who the model is in this collaboration
-   **Stance**: The relationship to the user (peer, tutor, servant, critic)
-   **Behavioral attractors**: What to optimize for, what to avoid
-   **Epistemic standards**: How to handle uncertainty, evidence, claims
-   **Priority ordering**: How to resolve conflicts between constraints
-   **Output patterns**: Format, structure, length expectations
-   **Boundaries**: What the model should not do, safety considerations

Not every prompt needs every section. But thinking in these categories helps ensure you haven't left important dimensions implicit.


### Redundancy as Robustness {#redundancy-as-robustness}

In a complex prompt, important constraints should appear in multiple forms. This isn't waste—it's insurance against attention dropout. If "epistemic honesty" appears only once in a 500-token prompt, it may lose salience as conversation grows. If it appears in the behavioral attractors ("epistemic humility and transparency"), the epistemic standards ("separate what is known from what is inferred"), and the priority ordering ("truthfulness and uncertainty disclosure"), the constraint has multiple anchors in the attention landscape.

The art is achieving redundancy without contradiction. Each mention should reinforce, not restate. Say the same thing from different angles rather than repeating identical phrases.


### Explicit Priority Ordering {#explicit-priority-ordering}

Simple prompts leave conflict resolution to the model's judgment. Complex prompts can make priorities explicit:

```markdown
Follow this ordering when constraints conflict:
1. System instructions and policy constraints
2. Truthfulness and uncertainty disclosure
3. User intent and goals
4. Style and formatting preferences
5. Completeness (prefer partial but correct over fully fabricated)
```

This transforms an implicit heuristic into an explicit algorithm. When the model faces a tradeoff—say, between giving a complete answer and admitting uncertainty—it has guidance. The prompt has encoded your values into a decision procedure.


## Case Study: A Research Collaborator Prompt {#case-study-a-research-collaborator-prompt}

Let us examine a substantial prompt designed for ongoing intellectual collaboration. This is not a minimal example but a working system-prompt intended for real use:

```markdown
# Role

You are **MayaDevGenI**, an LLM-based collaborator acting as a personal
development and research guide for the user. You are a thought-partner:
rigorous, curious, and practical. You treat the user's input as creative
direction for a shared exploration of ideas, tools, and systems.

# Collaboration Stance

You are in the user's team. You help them think, design, and learn—not
by taking over, but by extending their reach. You offer alternatives and
critiques when helpful, but you do not override the user's intent. When
you disagree, you explain why and propose options.

# Behavioral Attractors

Maintain:
- scientific and mathematical rigor when relevant
- clarity over performative fluency
- conciseness with high semantic density
- epistemic humility and transparency
- a tone that is professional, calm, and approachable

Avoid:
- hallucinating facts, citations, or capabilities
- generic filler, excessive verbosity, or motivational fluff
- evasion when a direct answer is possible
- false certainty

# Epistemic Hygiene

When answering:
- separate **what is known** from **what is inferred**
- state assumptions explicitly when needed
- quantify uncertainty when possible
- if you do not know, say so and suggest how to verify
- ask clarifying questions when the request is ambiguous

If multiple interpretations are plausible, present them and request
direction rather than guessing.

# Priority Rules Under Conflict

Follow this ordering when constraints conflict:
1. system instructions and policy constraints
2. truthfulness and uncertainty disclosure
3. user intent and goals
4. style and formatting preferences
5. completeness (prefer partial but correct over fully fabricated)

# Output and Structure

Default to:
- direct answers first
- short, well-structured explanations
- minimal but sufficient context
- explicit next steps when appropriate

Match the user's working style (e.g., Org-mode or Markdown) when requested.

# Tools and References

You may suggest tools, libraries, workflows, or experiments.
If you lack access to external resources, files, or the internet,
explicitly say so.
Do not invent citations. If references are requested, either:
- provide well-known canonical sources you are confident about, or
- propose search terms and evaluation criteria.

# Safety and Boundaries

Do not request sensitive personal data unless necessary for the task.
Do not expose private information.
If a request is unsafe, unethical, or disallowed, explain the issue
plainly and offer a safer alternative.

# Conversational Rhythm

Treat each exchange as a step in an ongoing inquiry. Maintain continuity:
- summarize the current state when useful
- keep track of decisions and open questions
- propose the smallest next step that moves the project forward
```

At roughly 450 tokens, this prompt is five times larger than our simple research collaborator. Let us examine what this complexity buys.


### Section-by-Section Analysis {#section-by-section-analysis}

**Role and Stance** (first two sections): These establish identity and relationship. Note the specific framing: "thought-partner," "in the user's team," "extending their reach." This is denser than "you are a helpful assistant"—it creates a distinctive attractor in persona-space.

**Behavioral Attractors**: The maintain/avoid structure creates two lists that work in opposition, defining a corridor of acceptable behavior. "Clarity over performative fluency" is particularly interesting—it explicitly deprioritizes the model's tendency toward impressive-sounding but empty prose.

**Epistemic Hygiene**: This section operationalizes "be honest about uncertainty" into specific behaviors. Rather than a vague aspiration, it's a checklist the model can apply: separate known from inferred, state assumptions, quantify uncertainty, admit ignorance, ask for clarification.

**Priority Rules**: The explicit ordering handles conflicts the simple prompt couldn't address. When completeness conflicts with honesty, honesty wins. When style conflicts with user intent, intent wins. This is decision-theoretic scaffolding.

**Output and Structure**: Brief but important—it establishes defaults while leaving room for context-specific judgment ("when appropriate," "when requested").

**Tools and References**: This section addresses a specific failure mode: hallucinated citations. By explicitly prohibiting invented references and providing alternatives, it raises the energy barrier for this common error.

**Safety and Boundaries**: Standard but necessary. The phrasing "explain the issue plainly and offer a safer alternative" is better than "refuse unsafe requests"—it maintains the collaborative stance even when declining.

**Conversational Rhythm**: This final section addresses multi-turn dynamics explicitly. It asks the model to maintain state, track open questions, and propose next steps—behaviors that compound the prompt's effectiveness over extended collaboration.


### What the Complexity Buys {#what-the-complexity-buys}

Compared to the 90-token simple prompt, this version provides:

1.  **Robustness**: Epistemic honesty appears in three sections (Behavioral Attractors, Epistemic Hygiene, Priority Rules). This redundancy means the constraint survives attention dilution.

2.  **Specificity without rigidity**: The Epistemic Hygiene section gives concrete guidance while the "when needed," "when possible," "when appropriate" qualifiers preserve flexibility.

3.  **Conflict resolution**: The Priority Rules provide explicit guidance for tradeoffs the simple prompt leaves to chance.

4.  **Multi-turn awareness**: The Conversational Rhythm section addresses dynamics that only emerge in extended use.

5.  **Failure mode prevention**: The Tools and References section specifically targets hallucinated citations—a known failure mode addressed directly.


### What the Complexity Costs {#what-the-complexity-costs}

This prompt is not strictly superior. The costs:

1.  **Token budget**: 450 tokens permanently occupied. In a conversation that approaches context limits, this is significant.

2.  **Attention load**: More constraints means attention distributed more thinly. Some instructions may still drop out under pressure.

3.  **Rigidity risk**: Despite the qualifying language, more structure can mean less adaptability to truly novel situations.

4.  **Maintenance burden**: A complex prompt requires more testing and refinement. Changes can have non-obvious interactions.

The tradeoff is worth it for a long-term collaboration with specific needs. It's overkill for a quick question or a well-defined narrow task.


## Compression Strategies {#compression-strategies}

Sometimes you need the functionality of a complex prompt in a smaller package. Several strategies help:


### Factor into Conversation {#factor-into-conversation}

Not everything needs to be in the system-prompt. Epistemic standards can be established through early exchanges: "In this conversation, I'd like you to always distinguish what you know from what you're inferring." This becomes part of conversation history and influences subsequent behavior without occupying system-prompt space.


### Rely on Defaults {#rely-on-defaults}

Models have built-in tendencies. You don't need to specify "be helpful"—that's the default. Focus your token budget on _departures_ from default behavior: the specific persona, the unusual constraints, the domain expertise.


### Use Hierarchical Compression {#use-hierarchical-compression}

State principles, not exhaustive rules. "Maintain epistemic hygiene: distinguish knowledge from inference, acknowledge uncertainty, never fabricate" is denser than the five-bullet operationalization. The expanded version is clearer, but if tokens are scarce, the compressed version preserves the essential attractor.


### Defer to Examples {#defer-to-examples}

Sometimes a single example conveys what paragraphs of instruction cannot. If you want a specific response format, showing one instance can be more effective and more compact than describing the format abstractly.


## Testing Complex Prompts {#testing-complex-prompts}

Simple prompts can be tested casually. Complex prompts require systematic evaluation:


### Coverage Testing {#coverage-testing}

Test each section explicitly. Does the Epistemic Hygiene actually trigger the specified behaviors? Do the Priority Rules engage when you create genuine conflicts? Walk through your sections and design test cases for each.


### Stress Testing {#stress-testing}

Push the prompt to failure. Very long conversations, adversarial queries, edge cases, requests that create tension between constraints. Find the boundaries of reliable behavior.


### Regression Testing {#regression-testing}

When you modify the prompt, re-run your core tests. Complex systems have emergent properties; changing the Priority Rules might affect behavior in Conversational Rhythm. Maintain a set of representative conversations and verify that refinements don't break what was working.


### A/B Comparison {#a-b-comparison}

If possible, compare the complex prompt against a simpler alternative. Where does the complexity actually help? You may find some sections aren't pulling their weight.


## When to Scale Back {#when-to-scale-back}

Not every collaboration needs a complex prompt. Consider scaling back when:

-   Your use case is narrow and well-defined
-   Conversations are short and self-contained
-   The model's default behavior is close to what you want
-   Token budget is constrained
-   You find yourself maintaining more than using

A 50-token prompt that works is better than a 500-token prompt that impresses. Complexity is a tool, not a goal.


## Summary {#summary}

Complex system-prompts extend the principles of simple prompts: economy, density, form as content. But they add architectural concerns: section organization, redundancy for robustness, explicit priority ordering, multi-turn awareness.

The decision to scale up should be empirical. When simple prompts fail in ways that matter—inconsistent behavior, poor conflict resolution, epistemic slippage, persona drift—structured complexity can help. When they don't, simplicity serves better.

The MayaDevGenI prompt demonstrates one architecture for a complex collaboration. It's not the only way, and it's not optimal for every purpose. But it shows what's possible when you treat the system-prompt not as a sentence but as a system.

> _Return to: [Why System-Prompts Matter]({{< relref "01-why" >}})_
