+++
title = "Tutorial Chapter 4: Crafting Your System-Prompt"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["tutorial"]
draft = false
+++

Theory informs; practice teaches. Here we construct system-prompts from first principles, developing intuition through concrete examples.


## The Core Principles {#the-core-principles}


### Economy {#economy}

The context window is finite. Your system-prompt competes with conversation history for the model's attention. Every unnecessary token dilutes the signal. Be concise—not terse, but _dense_. Say what matters; omit what doesn't.


### Semantic Density {#semantic-density}

Maximize meaning per token. Prefer "Respond with scientific rigor" over "Make sure your responses are accurate and based on scientific evidence." The first is five tokens; the second is twelve. Both convey similar intent, but the first leaves more room for conversation.


### Form as Content {#form-as-content}

The LLM is an imitation engine. It will echo the patterns it observes. If your system-prompt is structured and precise, responses tend toward structure and precision. If your prompt rambles, responses may ramble. _Demonstrate_ the behavior you want; don't just describe it.


### Specificity Without Rigidity {#specificity-without-rigidity}

Constrain enough to shape behavior; leave room for the model to exercise judgment. "You are a scientific editor" is too vague. "You must always respond with exactly three bullet points" is too rigid. "You are a scientific editor who prioritizes clarity and precision, and who flags unsupported claims" hits a productive middle.


## Building a System-Prompt: A Worked Example {#building-a-system-prompt-a-worked-example}

Let us construct a prompt for a /research collaborator/—an LLM persona that helps think through scientific problems.


### Start with Identity {#start-with-identity}

```markdown
You are a research collaborator with expertise in statistical physics and complex systems.
```

This establishes domain and role. The model will draw on relevant knowledge and adopt an appropriate register.


### Add Behavioral Constraints {#add-behavioral-constraints}

```markdown
You are a research collaborator with expertise in statistical physics and complex systems. You think carefully before responding, acknowledge uncertainty, and distinguish between established results and speculation.
```

Now we've shaped _how_ it engages—reflective, honest about limits, epistemically careful.


### Specify Interaction Style {#specify-interaction-style}

```markdown
You are a research collaborator with expertise in statistical physics and complex systems. You think carefully before responding, acknowledge uncertainty, and distinguish between established results and speculation.

Engage as a peer: ask clarifying questions, push back on weak arguments, suggest alternative framings. Be concise but not curt.
```

The model now knows the /relationship/—peer, not servant. It has permission to challenge, to question, to contribute actively.


### Add Format Guidance (If Needed) {#add-format-guidance--if-needed}

```markdown
You are a research collaborator with expertise in statistical physics and complex systems. You think carefully before responding, acknowledge uncertainty, and distinguish between established results and speculation.

Engage as a peer: ask clarifying questions, push back on weak arguments, suggest alternative framings. Be concise but not curt.

When discussing mathematics, use LaTeX notation. Structure longer responses with clear sections.
```

Format guidance helps when you have specific output needs. But don't over-specify—leave room for contextual judgment.


## The Complete Prompt {#the-complete-prompt}

Our worked example yields a prompt of roughly 90 tokens—compact enough to leave ample room for conversation, dense enough to meaningfully shape behavior:

```markdown
You are a research collaborator with expertise in statistical physics and complex systems. You think carefully before responding, acknowledge uncertainty, and distinguish between established results and speculation.

Engage as a peer: ask clarifying questions, push back on weak arguments, suggest alternative framings. Be concise but not curt.

When discussing mathematics, use LaTeX notation. Structure longer responses with clear sections.
```


## Variations for Different Purposes {#variations-for-different-purposes}

The same principles apply across contexts. A few brief examples:


### Technical Editor {#technical-editor}

```markdown
You are a technical editor for scientific manuscripts. Flag unclear passages, identify logical gaps, suggest more precise phrasings. Be direct; the author wants honest critique, not encouragement.
```


### Socratic Tutor {#socratic-tutor}

```markdown
You are a tutor who teaches through questions. When the student asks something, respond with a question that guides them toward the answer themselves. Only provide direct explanation if they're stuck after genuine effort.
```


### Code Reviewer {#code-reviewer}

```markdown
You review code for correctness, clarity, and maintainability. Point out bugs, suggest improvements, explain your reasoning. Assume the author is competent but may have missed something.
```

Each prompt is brief—under 50 tokens—yet each creates a distinct interaction pattern. The art lies in finding the minimal specification that produces the desired behavior.


## What to Avoid {#what-to-avoid}

-   **Contradictory instructions**: "Be thorough but extremely brief" creates an impossible constraint.
-   **Vague aspirations**: "Be helpful and good" adds nothing; the model defaults to this anyway.
-   **Exhaustive lists**: Specifying every possible behavior overwhelms attention and creates rigidity.
-   **Threatening language**: "You MUST always..." and "NEVER do..." often backfire; the model responds better to positive framing.

With a prompt drafted, the real work begins: testing it in practice and refining based on what you observe.

> _Next: [When Prompts Fail: A Diagnostic Guide]({{< relref "05-failures" >}})_
