+++
title = "Tutorial Chapter 6: Iterative Refinement"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["tutorial"]
draft = false
+++

A system-prompt is not written; it is evolved. The process resembles experimental science more than engineering—you form hypotheses, test them empirically, and refine based on observation. This final section describes the practice.


## The Experimental Loop {#the-experimental-loop}


### 1. Draft {#1-dot-draft}

Begin with a candidate prompt based on the principles in [Crafting Your System-Prompt]({{< relref "04-craft" >}}). Don't aim for perfection; aim for a reasonable starting point. Explicit is better than clever. Clear is better than complete.


### 2. Test {#2-dot-test}

Engage in representative conversations. Don't just try your best-case scenarios—probe the edges. Ask questions that might reveal weaknesses. Push into areas where you're uncertain how the model will behave. Vary your interaction style.


### 3. Observe {#3-dot-observe}

Note where behavior aligns with intent and where it diverges. Be specific: not "it didn't work well" but "it gave direct answers when I wanted it to ask questions" or "it was verbose when I needed concision." Specific observations enable targeted diagnosis.


### 4. Diagnose {#4-dot-diagnose}

Consult the [failure modes]({{< relref "05-failures" >}}). Which pattern matches what you observed? Is the prompt under-specified, over-specified, internally contradictory? Is attention overloaded? Is the persona drifting over turns? Name the problem before attempting a fix.


### 5. Revise {#5-dot-revise}

Make targeted adjustments. Change one thing at a time when possible—this isolates the effect of each modification. If you change multiple aspects simultaneously and behavior improves, you won't know which change mattered.


### 6. Repeat {#6-dot-repeat}

Return to testing. The revision may solve one problem while creating another. Iteration continues until the prompt reliably produces desired behavior across your representative test cases.


## What "Good Enough" Looks Like {#what-good-enough-looks-like}

Perfection is not the goal. You're seeking a prompt that:

-   Produces desired behavior in the _common_ cases
-   Fails gracefully in edge cases (predictably, not catastrophically)
-   Leaves room for the conversation to develop naturally
-   Remains stable over multi-turn interactions

When you reach this point, stop refining. Further optimization yields diminishing returns. Use the prompt, and let real conversations teach you what adjustments might help next.


## Learning the Medium {#learning-the-medium}

The iterative process teaches you more than prompt-writing. Each failure mode reveals something about how the model processes language—what it attends to, what it ignores, how it balances competing constraints. Over time, you develop intuition for the medium itself.

This intuition is valuable beyond any single prompt. You learn to anticipate how phrasing choices will land, to sense when a prompt is too heavy or too light, to feel the difference between productive constraint and unproductive rigidity. You learn to work _with_ the model's tendencies rather than against them.


## Beginning {#beginning}

You have the concepts: the mechanics of messages and roles, the interpretive framework of potential landscapes, the craft principles of economy and density, the diagnostic categories of failure modes, and the practice of iterative refinement.

Now: draft a prompt for a collaboration you actually want. Test it. Observe what happens. Adjust. The only way to develop fluency is through practice—through the accumulating experience of shaping conversations and noticing how they unfold.

The system-prompt is your first word in a dialogue. Make it count, then let the conversation teach you the rest.

For some collaborations, a simple prompt suffices. For others—long-term partnerships with specific epistemic standards, explicit priority orderings, or complex interaction patterns—you may need more structure.

> _Next: [Scaling Up: Complex System-Prompts]({{< relref "07-scaling" >}})_
