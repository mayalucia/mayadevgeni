+++
title = "Tutorial Chapter 2: The Mechanics"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-05T16:59:18+01:00
tags = ["tutorial"]
draft = false
+++

Communication with an LLM occurs through an API—typically a JSON-based protocol that structures every interaction. Understanding this structure demystifies what happens when you "talk" to a model.


## The Request Anatomy {#the-request-anatomy}

A typical API request contains:

-   **Endpoint**: The URL you're addressing (e.g., `/v1/chat/completions`)
-   **Headers**: Authentication and content-type metadata
-   **Body**: The payload containing your actual request

The body carries three essential components:

-   `model`: Which LLM you're addressing
-   `parameters`: Generation settings (temperature, max tokens, etc.)
-   `messages`: The conversation itself


## The Messages Array {#the-messages-array}

The `messages` array is where interaction lives. It is an ordered list of message objects, each with a `role` and `content`:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a careful scientific editor..."
    },
    {
      "role": "user",
      "content": "Please review this paragraph for clarity."
    },
    {
      "role": "assistant",
      "content": "I notice three areas where precision could improve..."
    },
    {
      "role": "user",
      "content": "Can you elaborate on the second point?"
    }
  ]
}
```


## The Three Roles {#the-three-roles}


### `system` {#system}

The system message appears first (when present) and establishes context for the entire conversation. The model treats it as persistent background—instructions that color every subsequent response. You, as user, typically set this once; it doesn't appear in the visible conversation flow.


### `user` {#user}

Your messages. Questions, requests, input text, corrections. Each user message advances the conversation and prompts a response.


### `assistant` {#assistant}

The model's responses. These accumulate in the array alongside user messages, forming the conversation history that the model sees when generating its next response.


## Context as Memory {#context-as-memory}

Here is a crucial point: the model has no memory beyond what appears in the `messages` array. Each API call sends the _entire_ conversation history. The model reads from the beginning—system message first—and generates the next assistant response based on everything it sees.

This means the system-prompt is re-read with every turn. It occupies the "zeroth position" in the sequence, anchoring the conversation's beginning. As the array grows, more tokens compete for the model's attention, but the system-prompt remains, a persistent presence shaping interpretation.


## A Minimal Example {#a-minimal-example}

The simplest possible system-prompt interaction:

```json
{
  "model": "claude-sonnet-4-20250514",
  "messages": [
    {"role": "system", "content": "Respond only in haiku."},
    {"role": "user", "content": "Explain recursion."}
  ]
}
```

The system message is seventeen tokens. Yet it completely transforms the response—from a technical explanation to a poetic compression. This is the leverage a system-prompt provides: minimal input, maximal behavioral shift.

With the mechanics understood, we can now ask a deeper question: _what is actually happening_ when a system-prompt shapes model behavior? For this, we need an interpretive lens.

> _Next: [An Interpretive Lens: Prompts as Potential Landscapes]({{< relref "03-landscape" >}})_
