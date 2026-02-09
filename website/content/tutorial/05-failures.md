+++
title = "Tutorial Chapter 5: When Prompts Fail"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["tutorial"]
draft = false
+++

A system-prompt that works perfectly on first draft is rare. More often, you'll observe behaviors that diverge from your intent. This section catalogs common failure modes and their remedies—a diagnostic toolkit for prompt refinement.


## Failure Mode 1: Conflicting Instructions {#failure-mode-1-conflicting-instructions}


### Symptoms {#symptoms}

The model oscillates between behaviors, produces incoherent compromises, or seems to ignore parts of your prompt. Responses feel inconsistent across turns.


### Cause {#cause}

Your prompt asks for incompatible things. "Be thorough and comprehensive" conflicts with "Keep responses under 100 words." "Always ask clarifying questions" conflicts with "Respond immediately to requests." The probability landscape has multiple competing minima; the model bounces between them.


### Remedy {#remedy}

Identify the tension and resolve it. Decide which behavior matters more, or specify when each applies: "For complex questions, ask for clarification first. For simple requests, respond directly." Make the constraint conditional rather than absolute.


## Failure Mode 2: Over-Specification {#failure-mode-2-over-specification}


### Symptoms {#symptoms}

Responses feel mechanical, rigid, predictable. The model follows your format precisely but misses opportunities for insight. Conversations lack productive surprise.


### Cause {#cause}

You've constrained too tightly. Every aspect of response is prescribed, leaving no room for the model to exercise judgment. The potential well is so deep and narrow that thermal fluctuations can't explore alternatives.


### Remedy {#remedy}

Relax. Remove format requirements that aren't essential. Replace "Always structure your response as: 1) Summary, 2) Analysis, 3) Conclusion" with "Structure longer responses clearly." Trust the model to make contextual choices. Keep constraints for what truly matters; release the rest.


## Failure Mode 3: Under-Specification {#failure-mode-3-under-specification}


### Symptoms {#symptoms}

Responses are generic, bland, indistinguishable from the model's default behavior. The persona you intended doesn't manifest. The model is "helpful" but not distinctively _yours_.


### Cause {#cause}

Your prompt doesn't provide enough signal. "Be a good assistant" or "Help me with my work" adds nothing to the model's priors. The landscape is flat; there are no clear attractors pulling toward your desired behavior.


### Remedy {#remedy}

Add specificity. What _kind_ of assistant? With what expertise? What interaction style? What should it prioritize? What should it avoid? You don't need exhaustive detail, but you need enough texture to distinguish your intended behavior from the generic default.


## Failure Mode 4: Semantic Overload {#failure-mode-4-semantic-overload}


### Symptoms {#symptoms}

The model follows some instructions but ignores others. Important constraints seem to "drop out." The prompt works partially but not completely.


### Cause {#cause}

Your prompt is too long or too dense. The attention mechanism, distributing weights across many tokens, can't maintain focus on everything simultaneously. Some instructions effectively disappear from working context—noise overwhelming signal.


### Remedy {#remedy}

Compress. Identify the essential instructions and keep those; remove or condense the rest. Prioritize ruthlessly. If you have ten instructions and attention can reliably track five, decide which five matter most. A shorter prompt with core constraints will outperform a longer prompt that overwhelms.


## Failure Mode 5: Persona Drift {#failure-mode-5-persona-drift}


### Symptoms {#symptoms}

The model starts well but gradually loses its character over long conversations. The careful editor becomes a generic assistant. The Socratic tutor starts giving direct answers.


### Cause {#cause}

As conversation grows, the system-prompt's influence dilutes. The accumulated weight of user and assistant messages begins to dominate. The mean field weakens relative to the local conversational context.


### Remedy {#remedy}

Re-ground periodically. Reference the collaboration's purpose explicitly in your messages: "As my scientific editor, what do you think of..." Summarize and restart long conversations. If your interface permits, consider re-injecting key system-prompt elements. Help the model remember what it's supposed to be.


## Failure Mode 6: Instruction Literalism {#failure-mode-6-instruction-literalism}


### Symptoms {#symptoms}

The model follows instructions too literally, missing the intent behind them. Asked to "be concise," it becomes terse to the point of unhelpfulness. Asked to "ask questions," it asks questions even when unnecessary.


### Cause {#cause}

The model optimizes for the letter of the instruction, not its spirit. Your phrasing triggered a behavior pattern more extreme than you intended.


### Remedy {#remedy}

Add nuance and context. "Be concise—but not at the expense of clarity" rather than just "Be concise." "Ask clarifying questions when the request is ambiguous" rather than "Ask clarifying questions." Qualify absolute instructions with the judgment you expect.


## Using This Guide {#using-this-guide}

When a prompt underperforms, resist the urge to add more instructions. First, diagnose. Which failure mode are you observing? The remedy for over-specification is _less_ constraint; the remedy for under-specification is _more_. Adding words won't help if the problem is semantic overload.

Treat prompt refinement as empirical investigation. Observe behavior, form hypotheses about causes, make targeted adjustments, observe again. The prompt converges through iteration, not through getting it right the first time.

> _Next: [The Practice: Iterative Refinement]({{< relref "06-iterate" >}})_
