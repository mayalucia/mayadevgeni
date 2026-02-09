+++
title = "System-Prompt Engineering"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["framework"]
draft = false
+++

A well-crafted system-prompt doesn't merely instruct; it _constrains the space of possible responses_, creating channels through which the conversation flows.

We draw on statistical physics—not as metaphor, but as diagnostic tool. The concepts of potential landscapes, random walks, and phase transitions illuminate why some prompts succeed and others fail.


## The Statistical Physics Lens {#the-statistical-physics-lens}


### Token Generation as Random Walk {#token-generation-as-random-walk}

An LLM operates in a high-dimensional vector space where token generation can be viewed as a random walk. Each token choice depends probabilistically on all preceding tokens, with the probability distribution shaped by the model's training and the current context.

The system-prompt occupies the initial segment of the sequence. It defines the _potential landscape_ for all subsequent tokens—lowering energy states for desired behaviors (rigor, conciseness, epistemic honesty) and raising them for unwanted ones (hallucination, verbosity, sycophancy).

We craft a system-prompt so that conversational trajectories fall naturally into desired regions of the output space, rather than wandering via Brownian motion into generic responses.


### The Mean Field of Attention {#the-mean-field-of-attention}

Modern LLMs use the Transformer architecture, where every token interacts with every other through self-attention. The system-prompt tokens retain high attention weights throughout the conversation—they act as a persistent _mean field_ or boundary condition influencing every generated token.

This has implications:

-   _Position matters_: Early tokens in the system-prompt receive more consistent attention. Place critical constraints prominently.

-   _Structure aids attention_: XML tags and section headers act as attention anchors, helping the model locate and maintain focus on relevant constraints.

-   _Redundancy creates robustness_: Critical constraints appearing in multiple forms create multiple attractors. If one mention loses salience, others persist.


### Temperature and the Energy Landscape {#temperature-and-the-energy-landscape}

The system-prompt shapes the probability distribution; temperature controls how we sample from it.

| Temperature   | Behavior                                     | Character               |
|---------------|----------------------------------------------|-------------------------|
| Low (~0.3)    | Near-deterministic, high-probability tokens  | Focused, predictable    |
| Medium (~0.7) | Balanced exploration and coherence           | Adaptive, natural       |
| High (~1.2)   | Flattened distribution, rare tokens possible | Creative, unpredictable |

The interplay is subtle. A highly constrained prompt at low temperature yields brittle predictability. The same prompt at higher temperature retains directional bias while permitting exploration. For collaboration, we seek enough constraint for coherence, enough stochasticity for surprise.


## Dynamics Over Time {#dynamics-over-time}


### The Dilution Problem {#the-dilution-problem}

A conversation is not a single query but an evolving trajectory. With each exchange, the context grows, and attention must distribute across more tokens.

In early turns, the system-prompt dominates—the conversation has little momentum. As dialogue develops, accumulated messages exert their own pull. Over very long sessions, even strong system-prompts see their influence diluted.


### Strategies for Persistence {#strategies-for-persistence}

Several strategies counter dilution:

-   _Self-reinforcing patterns_: If early assistant responses embody the desired behavior, they become additional attractors, compounding the prompt's effect.

-   _Periodic re-grounding_: Explicitly referencing the collaboration's purpose or principles mid-conversation refreshes the signal.

-   _Structured summarization_: Condensing prior context preserves relevant information while reducing noise.

-   _Behavioral consistency_: A prompt that produces consistent early behavior creates path-dependence that resists drift.


## Failure Modes {#failure-modes}

Understanding how prompts fail illuminates what makes them succeed.


### Conflicting Instructions {#conflicting-instructions}

The prompt demands incompatible behaviors—exhaustive detail _and_ extreme brevity. The model oscillates or produces incoherent compromises. The probability landscape develops competing minima.

_Diagnosis_: Responses that seem to switch personality mid-stream, or that satisfy one constraint while violating another.


### Over-Specification {#over-specification}

The prompt prescribes every aspect of response. For narrow tasks this works; for open collaboration it creates rigidity. The potential well is so deep and narrow that thermal fluctuations cannot escape.

_Diagnosis_: Responses that feel mechanical, unable to adapt to novel contexts.


### Under-Specification {#under-specification}

The prompt is too vague. The model defaults to its prior distribution—a helpful but bland assistant persona. The landscape is flat; there are no clear attractors.

_Diagnosis_: Generic responses that could come from any interaction.


### Semantic Overload {#semantic-overload}

The prompt is internally consistent but too dense. Attention distributes too thinly; some instructions effectively disappear. Entropy overwhelms information.

_Diagnosis_: Inconsistent adherence—some constraints honored, others ignored unpredictably.


## Architectural Strategies {#architectural-strategies}

When simple prompts reach their limits—inconsistent behavior, role confusion, epistemic slippage—we need _organized complexity_: structure that the attention mechanism can parse and maintain.


### Sectioning for Attention {#sectioning-for-attention}

Distinct sections act as attention anchors. Each addresses one dimension of behavior:

| Section                   | Purpose                                  |
|---------------------------|------------------------------------------|
| `<identity>`              | Who the LLM is; frames the collaboration |
| `<behavioral_attractors>` | What to optimize, what to avoid          |
| `<epistemic_hygiene>`     | Standards for uncertainty and claims     |
| `<priority_rules>`        | Explicit conflict resolution             |
| `<failure_modes>`         | Patterns to actively counteract          |
| `<boundaries>`            | Scope, safety, editorial authority       |


### XML Tags vs. Markdown Headers {#xml-tags-vs-dot-markdown-headers}

We use XML-style tags (`<role>`) rather than Markdown headers (`# Role`):

1.  _Hard boundaries_: Tags explicitly delimit scope, preventing instruction leakage.
2.  _Attention anchoring_: Models trained on code recognize tags as structural delimiters.
3.  _Namespace separation_: Clearly distinguishes system instructions from user content.


### Redundancy as Robustness {#redundancy-as-robustness}

Critical constraints should appear in multiple forms. "Epistemic honesty" might surface in:

-   `<behavioral_attractors>` as something to maintain
-   `<epistemic_hygiene>` as operational practice
-   `<priority_rules>` as second-highest priority

The art: redundancy without contradiction. Say the same thing from different angles rather than repeating identical phrases.


### Explicit Priority Ordering {#explicit-priority-ordering}

Simple prompts leave conflict resolution to chance. Complex prompts make priorities explicit:

1.  System instructions and safety constraints
2.  Truthfulness and uncertainty disclosure
3.  Human's stated intent and goals
4.  Collaborative stance and tone
5.  Formatting and style preferences
6.  Completeness (prefer partial-but-correct over complete-but-fabricated)

This transforms implicit heuristics into decision procedures.


## The Costs of Complexity {#the-costs-of-complexity}

Complex prompts are not strictly superior. The tradeoffs:

-   _Token budget_: A 500-token prompt permanently occupies context space.
-   _Attention load_: More constraints means attention distributed more thinly.
-   _Rigidity risk_: More structure can mean less adaptability.
-   _Maintenance burden_: Complex prompts require systematic testing.


### When to Simplify {#when-to-simplify}

Consider scaling back when:

-   The use case is narrow and well-defined
-   Conversations are short and self-contained
-   The model's default behavior is close to what you want
-   Token budget is constrained

A 50-token prompt that works is better than a 500-token prompt that impresses.


## Next Steps {#next-steps}

Continue to the [System-Prompt Tutorial](/tutorial/) for hands-on practice with these principles.
