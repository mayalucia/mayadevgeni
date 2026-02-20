+++
title = "Tutorial Index"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-20T12:00:00+01:00
tags = ["tutorial"]
draft = false
+++

A practical guide to crafting system-prompts for LLM collaboration.


## Overview {#overview}

This tutorial develops fluency in writing system-prompts—the hidden preambles that shape LLM behavior before conversation begins. We move from foundational concepts through practical craft to advanced techniques.

The approach is grounded in a statistical-physics perspective: system-prompts as potential landscapes that bias token generation toward desired behaviors. But you don't need physics to benefit. The principles translate into concrete practices that work.


## The Tutorial {#the-tutorial}

| Chapter                        | Title                                                 | Focus                                                                    |
|--------------------------------|-------------------------------------------------------|--------------------------------------------------------------------------|
| [01](/tutorial/01-why/)        | Why System-Prompts Matter                             | Motivation: from generic assistant to shaped collaborator                |
| [02](/tutorial/02-anatomy/)    | The Mechanics: Messages and Roles                     | Foundation: how prompts enter the conversation via JSON API              |
| [03](/tutorial/03-landscape/)  | An Interpretive Lens: Prompts as Potential Landscapes | Theory: a statistical-physics framework for understanding prompt effects |
| [04](/tutorial/04-craft/)      | Crafting Your System-Prompt                           | Practice: principles and worked examples for simple prompts              |
| [05](/tutorial/05-failures/)   | When Prompts Fail: A Diagnostic Guide                 | Diagnosis: six failure modes and their remedies                          |
| [06](/tutorial/06-iterate/)    | The Practice: Iterative Refinement                    | Process: the experimental loop of test, observe, revise                  |
| [07](/tutorial/07-scaling/)    | Scaling Up: Complex System-Prompts                    | Advanced: architecture and tradeoffs for sophisticated prompts           |
| [08](/tutorial/08-skills/)     | Skills: Portable Knowledge for Agents                 | Comparative: how gptel-agent and Claude Code implement on-demand skills  |
| [09](/tutorial/09-emacs-llm/)  | The Workspace: Where System-Prompts Come Alive        | Tooling: Emacs as a shared workspace for LLM collaboration              |


## Reading Paths {#reading-paths}


### The Quick Path {#the-quick-path}

If you want to start writing prompts immediately:

1.  [01-why](/tutorial/01-why/) — understand the stakes
2.  [04-craft](/tutorial/04-craft/) — learn the principles
3.  [05-failures](/tutorial/05-failures/) — know the pitfalls


### The Complete Path {#the-complete-path}

For a thorough understanding, read sequentially from [01-why](/tutorial/01-why/) through [09-emacs-llm](/tutorial/09-emacs-llm/). Each chapter builds on the previous.


### The Practitioner's Path {#the-practitioner-s-path}

If you're ready to build a complex prompt for a real collaboration:

1.  Skim [07-scaling](/tutorial/07-scaling/) to understand the architecture
2.  Study the [System-Prompt Engineering](/framework/system-prompt-engineering/) framework
3.  Test and refine using [06-iterate](/tutorial/06-iterate/) as your guide


### The Tooling Path {#the-tooling-path}

If you want to set up the workspace where system-prompt craft happens:

1.  [08-skills](/tutorial/08-skills/) — understand how prompts become deployable skills
2.  [09-emacs-llm](/tutorial/09-emacs-llm/) — build the Emacs workspace where it all converges
