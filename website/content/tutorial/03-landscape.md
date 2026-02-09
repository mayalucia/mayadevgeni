+++
title = "Tutorial Chapter 3: Prompts as Potential Landscapes"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["tutorial"]
draft = false
+++

You need not read this section to write effective system-prompts. But if you wish to _understand_ what you're doing—to develop intuition rather than follow recipes—a conceptual framework helps. We offer one drawn from statistical physics.


## Token Generation as Random Walk {#token-generation-as-random-walk}

An LLM generates text one token at a time. At each step, it computes a probability distribution over all possible next tokens, then samples from that distribution. The sequence of choices traces a path through a high-dimensional space of possibilities.

This is, mathematically, a random walk—but not an unbiased one. The probability distribution at each step depends on everything that came before: the system-prompt, the conversation history, the tokens already generated in the current response. The walk is guided.


## The Potential Landscape {#the-potential-landscape}

Imagine this guidance as a _potential-energy landscape_. Certain regions of response-space are "downhill"—the model flows toward them naturally. Others are "uphill"—the model avoids them unless pushed.

The system-prompt _sculpts_ this landscape. When you write "You are a rigorous scientific editor," you lower the energy of precise, critical responses and raise the energy of vague, agreeable ones. When you write "Be concise," you create a gradient away from verbosity.

The model doesn't follow rules; it follows probability gradients. The system-prompt establishes the topology that those gradients descend.


## Attention as Mean Field {#attention-as-mean-field}

The Transformer architecture—underlying all modern LLMs—uses a mechanism called _self-attention_. Every token can "look at" every other token, weighted by relevance. The system-prompt tokens sit at the beginning of the sequence and maintain attention connections throughout.

Think of the system-prompt as a /mean field/—a persistent background influence that every subsequent token feels. It doesn't determine responses directly, but it biases the attention patterns, shifting what the model considers relevant at each generation step.

As conversation grows, more tokens compete for attention. The mean field's influence can dilute—but it never disappears entirely. A well-crafted system-prompt creates patterns that reinforce themselves through the model's own responses, compounding its initial bias.


## Temperature as Kinetic Energy {#temperature-as-kinetic-energy}

The `temperature` parameter controls how the model samples from its probability distribution. Low temperature: sample the most likely tokens, producing predictable output. High temperature: flatten the distribution, allowing less probable tokens to emerge.

In our landscape metaphor, temperature is kinetic energy. Low temperature: the random walk settles into the nearest minimum, following the steepest descent. High temperature: the walk has energy to explore, to hop between valleys, to find unexpected paths.

The interplay matters. A constrained system-prompt with low temperature produces focused, predictable output—useful for structured tasks. The same prompt with higher temperature permits creative variation while maintaining directional bias. A loose prompt with high temperature approaches unconstrained generation—maximum entropy, minimum structure.


## Why This Matters {#why-this-matters}

This framework is not mere metaphor. It provides diagnostic power.

When a model ignores your instructions, ask: is the potential gradient too weak? Perhaps the instruction needs emphasis or reinforcement.

When responses feel rigid and brittle, ask: is the potential well too deep? Perhaps you've over-constrained, leaving no room for productive exploration.

When the model drifts off-topic in long conversations, ask: has the mean field diluted? Perhaps you need to re-ground the conversation or summarize accumulated context.

The physics language gives us /handles/—ways to reason about failure and adjust systematically. We turn now to the craft of applying these insights.

> _Next: [Crafting Your System-Prompt]({{< relref "04-craft" >}})_
