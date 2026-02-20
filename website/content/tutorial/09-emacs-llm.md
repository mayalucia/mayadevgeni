+++
title = "Tutorial Chapter 9: The Workspace"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-20T12:00:00+01:00
tags = ["tutorial"]
draft = false
+++

The previous chapters developed a craft: how to write system-prompts that shape LLM behavior with precision. But craft requires a medium. A sculptor needs clay, not a description of clay. This chapter concerns the environment where system-prompts are authored, tested, deployed, and refined---the workspace in which the collaboration actually unfolds.

The thesis is specific: _Emacs_, a programmable text environment, has become the most capable platform for operationalizing the system-prompt craft developed in this tutorial. Not because Emacs is trendy (it is nearly fifty years old), but because its architecture---transparent, extensible, text-native---aligns with what LLM collaboration demands. The medium shapes the practice.


## The Argument for a Shared Workspace {#the-argument-for-a-shared-workspace}

Most people interact with LLMs through a chat interface: a text field on one side, responses on the other, a clipboard mediating between the chat and wherever the real work happens. This architecture imposes a structural bottleneck. The model sees only what you paste. It cannot observe your project, read your open files, or propose changes you review in place. Context must be manually curated at every exchange.

A _shared workspace_ removes this bottleneck. The human and the AI operate within the same environment---the same files, buffers, and project structure. The model reads what you are editing. It proposes changes you review in a diff viewer. It executes code in the same runtime. The conversation and the work are not two separate activities mediated by copy-paste; they are one activity in one place.

Emacs enables this because it is a _Lisp machine_. Every buffer, every action, every piece of state is a programmable object. When an LLM agent runs inside Emacs, it inherits this programmability: it can read buffers, navigate symbols, execute code, and propose edits through well-defined interfaces. The editor is not a container for the AI; it is a shared substrate.


## Org-Mode as Joint-Thought Medium {#org-mode-as-joint-thought-medium}

The substrate of the shared workspace is Org-mode---Emacs's plain-text format for structured documents. We have encountered org-mode indirectly throughout this tutorial: the system-prompts, agent definitions, and skill files that embody the craft of the previous chapters. Now we examine org-mode directly as the medium in which LLM collaboration _happens_.

Three properties make org-mode uniquely suited:


### Executable Code Blocks {#executable-code-blocks}

Org-mode supports _literate programming_: code blocks in any language, embedded in prose, executable in place. Press `C-c C-c` and the result appears below the block. Python, Julia, shell, Emacs Lisp---all interleaved with explanatory text.

This matters for system-prompt work because testing a prompt is an empirical act. You write the prompt, send it, observe the output, and revise. When the prompt, the test, and the analysis live in the same document, the iteration cycle tightens.


### Structured Message Blocks {#structured-message-blocks}

With `ob-gptel` (an org-babel backend for gptel), org files become LLM conversation transcripts:

```text
#+begin_message :role user :name mu2tau
Given the attractor structure of my system-prompt,
where are the failure modes most likely to emerge?
#+end_message

#+begin_message :role assistant :name claude
The priority ordering between your identity section
and the epistemic constraints creates a potential...
#+end_message
```

Structure templates accelerate the workflow. Type `<mu TAB` for a user message block, `<ma TAB` for an assistant block, `<ms TAB` for a system message. The conversation accumulates structure: your annotations, code experiments, and the LLM's responses coexist in a single, navigable document.

This is not a chat log. It is a _joint document_---the kind of artifact where system-prompt refinement, described in [Chapter 6](/tutorial/06-iterate/), becomes a sustained practice rather than a transient exchange.


### Literate Tangling {#literate-tangling}

Code blocks can be _tangled_---extracted into standalone source files. A system-prompt authored as an org document can be tangled into the `.md` files that gptel-agent or Claude Code expect. The prose explains the design rationale; the code blocks contain the operational prompt. They live together, are version-controlled together, and are exported separately.


## gptel: The Universal LLM Gateway {#gptel-the-universal-llm-gateway}

The practical machinery begins with [gptel](https://github.com/karthink/gptel)---a package that connects Emacs to any LLM provider through a uniform interface. One registers providers (Anthropic, Google, OpenAI, DeepSeek, local Ollama models, aggregators like OpenRouter) and switching between them is a single keybinding. The API key management follows a consistent pattern: keys live in `~/.authinfo.gpg`, a GPG-encrypted credential store, and are retrieved at runtime by lambda functions---never hardcoded.

```elisp
(gptel-make-anthropic "Claude"
  :stream t
  :key #'(lambda ()
           (auth-source-pick-first-password
            :host "api.anthropic.com" :user "apikey"))
  :models '(claude-opus-4-6
            claude-sonnet-4-5-20250929))
```

The uniformity is the point. Whether you are testing a system-prompt against Claude Opus, comparing its behavior on Gemini, or running a cost-effective iteration with DeepSeek, the interface is identical. The _model_ varies; the _workflow_ does not. This is essential for the iterative refinement process of [Chapter 6](/tutorial/06-iterate/): you need to test the same prompt against different models without changing your process.


## gptel-agent: System-Prompts Made Operational {#gptel-agent-system-prompts-made-operational}

Here the tutorial comes full circle. Everything you learned about crafting system-prompts---the priority ordering of [Chapter 4](/tutorial/04-craft/), the failure diagnostics of [Chapter 5](/tutorial/05-failures/), the scaling architecture of [Chapter 7](/tutorial/07-scaling/), the skill system of [Chapter 8](/tutorial/08-skills/)---converges in [gptel-agent](https://github.com/karthink/gptel-agent).

gptel-agent lets you save a system-prompt as a _reusable agent definition_: a markdown file with YAML frontmatter specifying the model, tools, and behavior, followed by the system-prompt body.

```text
---
name: Statistical Physicist
description: Collaborator fluent in stat-mech and stochastic processes
model: claude-opus-4-6
tools:
  - python
  - shell
---

You are a theoretical statistical physicist with deep expertise
in interacting particle systems, Markov processes, and ...
```

Register an agents directory, and every file becomes a loadable persona:

```elisp
(use-package! gptel-agent
  :after gptel
  :config
  (add-to-list 'gptel-agent-dirs
               (expand-file-name "~/agents"))
  (gptel-agent-update))
```

The agents are plain files. They live in git. They are portable, diffable, shareable. When you refine a system-prompt through the iterative process---test, observe, revise---you are editing a file that _is_ the deployed agent. There is no gap between the craft and its application.

This connects directly to the skill system described in [Chapter 8](/tutorial/08-skills/). An agent definition sets the baseline persona; skills expand its competence on demand. The agent _is_ the system-prompt; the skills are its training manuals. Together, they form a complete specification of a shaped intelligence---authored in plain text, version-controlled, and activated within the same Emacs environment where all other work happens.


## Claude Code and MCP: The Agent in Your Editor {#claude-code-and-mcp-the-agent-in-your-editor}

The deepest form of the shared workspace is [claude-code-ide](https://github.com/manzaltu/claude-code-ide.el), which embeds Claude Code CLI in Emacs with _Model Context Protocol_ (MCP) tools. MCP is what transforms an LLM from a conversational partner into a co-editor.

With MCP enabled, Claude can:

-   Read the buffer you are currently editing
-   Navigate your project's file structure
-   Find symbol definitions and references via the language server
-   Inspect the syntax tree
-   Propose edits that appear in Emacs's diff viewer

```elisp
(use-package! claude-code-ide
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config
  (claude-code-ide-emacs-tools-setup)  ; Enable MCP tools
  (setq claude-code-ide-window-side 'right
        claude-code-ide-window-width 100))
```

The practical experience: you have a source file open on the left, Claude Code on the right. You describe a change in natural language. Claude reads your file through MCP, understands the structure, and proposes a diff. You review each hunk in `ediff`, accept or reject, and continue. The system-prompt governing Claude Code's behavior---the very kind of prompt this tutorial teaches you to write---shapes every interaction.

A complementary approach is [agent-shell](https://github.com/xenodium/agent-shell), which runs AI agents (Claude Code, Gemini CLI, OpenAI Codex) in native Emacs buffers via the _Agent Client Protocol_. Where claude-code-ide provides deep MCP integration, agent-shell provides breadth: multiple agents in parallel, each in its own buffer, with full Emacs text manipulation on their output.


## The Craft and the Medium {#the-craft-and-the-medium}

This chapter has described a workspace, not a philosophy. But the workspace embodies a philosophy: that the collaboration between human and machine is best served by a _shared, transparent, programmable medium_. Org-mode provides the structure. gptel provides the connection. gptel-agent operationalizes the system-prompt craft. Claude Code with MCP makes the editor itself a shared space.

The previous chapters taught you to shape what the LLM thinks. This chapter showed you where that thinking happens. The two are not separable: the quality of the system-prompt depends on the tightness of the iteration loop, and the iteration loop depends on the workspace.

Plain text, version-controlled, executable, owned by you. That is the medium. The collaboration is what you make of it.

> _Previous: [Skills: Portable Knowledge for Agents](/tutorial/08-skills/)_
> _Back to: [Tutorial Index](/tutorial/)_
