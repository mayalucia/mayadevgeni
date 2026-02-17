+++
title = "Tutorial Chapter 8: Skills"
author = ["MayaDevGenI Collaboration"]
lastmod = 2026-02-17T20:00:00+01:00
tags = ["tutorial"]
draft = false
+++

Tools let an agent act. System-prompts shape how it thinks. But there is a gap between the two: domain knowledge that is too specific for a system-prompt yet too procedural for a tool. A commit workflow. A code review checklist. A deployment runbook. Knowledge that says not "here is a capability" but "here is how to do this particular thing well."

This is what _skills_ address. A skill is a packet of specialized instructions that an agent loads on demand---expanding its competence for a specific task without permanently consuming context. If system-prompts are the agent's character and tools are its hands, skills are its training manuals, pulled from the shelf when the task requires them.

Two implementations of this idea are worth studying side by side: Claude Code's skills system (which originated the [Agent Skills](https://agentskills.io) open specification) and gptel-agent's Emacs-native adaptation of the same concept. The comparison illuminates both the universal pattern and the design choices that diverge.


## The Universal Pattern {#the-universal-pattern}

Both implementations share a three-phase lifecycle:

1. **Discovery** --- Scan known directories for skill definitions. Extract only metadata (name, description). This is cheap: ~100 tokens per skill.

2. **Advertisement** --- Present the available skills to the LLM as a summary list. The model sees _what_ skills exist and _when_ to use them, but not the full instructions. This fits in the tools description or system message without bloating context.

3. **Activation** --- When the LLM (or user) invokes a skill, load the full body. The detailed instructions enter the conversation only when needed. This is the key efficiency: progressive disclosure.

The directory convention is shared across tools:

```
<skill-name>/
  SKILL.md          # Required entry point
  templates/        # Optional supporting files
  scripts/
  references/
```

The `SKILL.md` file has YAML frontmatter (metadata) followed by Markdown body (instructions). This format is the core of the [agentskills.io specification](https://agentskills.io/specification), adopted by Claude Code, OpenAI Codex, Gemini CLI, GitHub Copilot, OpenCode, and others.


## Claude Code: Skills as Tool-Embedded Prompts {#claude-code-skills-as-tool-embedded-prompts}

In Claude Code, skills live in the `Skill` tool's description---not the system prompt. This is an important architectural choice. The tool definition is dynamically generated at startup to include an `<available_skills>` block:

```xml
<available_skills>
  <skill>
    <name>commit</name>
    <description>Create a git commit following project conventions</description>
  </skill>
  <skill>
    <name>review-pr</name>
    <description>Review a pull request by number</description>
  </skill>
</available_skills>
```

When Claude decides a task matches a skill (or the user types `/commit`), it calls the `Skill` tool. The runtime then:

1. Loads the full `SKILL.md` body
2. Performs string substitutions (`$ARGUMENTS`, shell preprocessing)
3. Injects the content as a hidden message (`isMeta: true`)---Claude sees it, the user does not
4. Optionally grants scoped tool permissions (`allowed-tools`) and model overrides


### Directory Precedence {#directory-precedence}

Claude Code scans multiple locations with a clear priority order:

| Priority | Location                        | Scope              |
|----------|---------------------------------|--------------------|
| Highest  | Enterprise (managed settings)   | Organization-wide  |
|          | `~/.claude/skills/`             | Personal           |
|          | `.claude/skills/`               | Project-specific   |
| Lowest   | Plugin skills                   | Namespaced         |


### Invocation Control {#invocation-control}

A distinctive feature is the dual-invocation model. Skills can be invoked by the user (`/name`) or by the model (auto-selected based on task matching). Two frontmatter flags control this:

| Flag                              | Effect                                             |
|-----------------------------------|------------------------------------------------------|
| `disable-model-invocation: true`  | Only user can invoke; description hidden from LLM  |
| `user-invocable: false`           | Only model can invoke; hidden from `/` menu        |

This gives fine-grained control over when domain knowledge activates. A destructive operation (e.g., force-push) might be `disable-model-invocation: true`---the model should never auto-select it. Background knowledge (e.g., project coding conventions) might be `user-invocable: false`---always available to the model, never cluttering the command menu.


### Context Budget {#context-budget}

A character budget (default: 2% of the context window, fallback 16,000 chars) limits how many skill descriptions fit in the tools block. Skills exceeding the budget are silently excluded. This prevents the discovery phase from consuming disproportionate context.


## gptel-agent: Skills as Template-Expanded System Messages {#gptel-agent-skills-as-template-expanded-system-messages}

gptel-agent takes a different architectural path to the same destination. Where Claude Code embeds skills in the tool description, gptel-agent weaves them into the system prompt via template expansion.


### Discovery {#discovery}

The scan logic lives in `gptel-agent--update-skills` (`gptel-agent.el`). It iterates over directories listed in `gptel-agent-skill-dirs`:

```emacs-lisp
(defcustom gptel-agent-skill-dirs
  '("~/.claude/skills/"
    ".claude/skills/"
    "~/.agents/skills"    ;; codex
    ".agents/skills"      ;; codex
    "~/.opencode/skill/"
    ".opencode/skill/"
    "~/.gemini/skills/"
    ".gemini/skills/")
  "Agent skill definition directories.")
```

This is deliberately cross-compatible. gptel-agent reads skills from _every_ major agentic tool's directory convention. If you have skills defined for Claude Code, Codex, or Gemini CLI, gptel-agent discovers them automatically.

Relative paths are resolved against both the current directory and the project root, with relative paths taking precedence over absolute ones. Each `SKILL.md` is parsed with `gptel-agent-read-file` in metadata-only mode---only the frontmatter is loaded. Skills without a `:description` are rejected with a warning.


### Advertisement via Template Expansion {#advertisement-via-template-expansion}

gptel-agent's system prompts use a template variable `={{SKILLS}}=` that gets replaced at agent-update time. The function `gptel-agent--skills-system-message` generates the replacement text:

```emacs-lisp
(defun gptel-agent--skills-system-message (agent-skills)
  (concat "Load a skill to get detailed instructions for a specific task."
          "Skills provide specialized knowledge and step-by-step guidance."
          "Use this when a task matches an available skill's description."
          "\n<available_skills>\n"
          (mapconcat
           (lambda (skill-def)
             (format "  <skill>\n    <name>%s</name>\n    <description>%s</description>\n  </skill>"
                     (car skill-def)
                     (plist-get (cddr skill-def) :description)))
           agent-skills "\n")
          "\n</available_skills>"))
```

The output XML is structurally identical to Claude Code's format. The difference is _where_ it lands: in gptel-agent, `={{SKILLS}}=` appears inside the `<tool name="Skill">` section of each agent's system prompt. Every agent that has the Skill tool---the default agent, researcher, executor, and plan agents---gets its own copy of the available skills list.


### Activation {#activation}

The `gptel-agent--get-skill` function handles invocation:

```emacs-lisp
(defun gptel-agent--get-skill (skill &optional _args)
  (let ((skill-dir
         (car-safe
          (alist-get skill gptel-agent--skills nil nil #'string-equal))))
    (if (not skill-dir)
        (format "Error: skill %s not found." skill)
      (let* ((skill-files
              (mapcar
               (lambda (full-path)
                 (cons (file-relative-name full-path skill-dir-expanded)
                       full-path))
               (directory-files-recursively skill-dir-expanded ".*")))
             (body (plist-get
                    (cdr (gptel-agent-read-file
                          (expand-file-name "SKILL.md" skill-dir)))
                    :system)))
        ;; ... formats body with file path resolution
        ))))
```

When the LLM calls the Skill tool, this function:

1. Looks up the skill name in `gptel-agent--skills`
2. Re-reads the full `SKILL.md` (not just metadata this time)
3. Resolves relative file references in the body to absolute paths
4. Returns the formatted content as the tool result

The skill content enters the conversation as a normal tool response---the LLM receives it in the assistant/tool-result flow. There is no hidden message injection; the content is visible in the conversation transcript.


### The Skill Tool Declaration {#the-skill-tool-declaration}

```emacs-lisp
(gptel-make-tool
 :name "Skill"
 :description "Load a skill into the current conversation.
Each skill provides guidance on how to execute a specific task.
You can invoke a skill with optional args, the args are for your future reference only.
..."
 :function #'gptel-agent--get-skill
 :args '((:name "skill"  :type string
           :description "Name of the skill, chosen from the list of available skills")
         (:name "args"   :type string :optional t
           :description "Args relevant to the skill, for your future reference"))
 :category "gptel-agent"
 :include t)
```

Note: no `:confirm t`---skill loading does not require user approval, unlike Bash or Edit. Skills are read-only knowledge injection; they do not directly modify state.


## Structural Comparison {#structural-comparison}

| Dimension                  | Claude Code                                   | gptel-agent                                    |
|----------------------------|-----------------------------------------------|------------------------------------------------|
| Discovery dirs             | `~/.claude/skills/`, `.claude/skills/`, etc.  | All major tool dirs (Claude, Codex, OpenCode, Gemini) |
| Advertisement location     | Skill tool description (tools array)           | System prompt via `={{SKILLS}}=` template       |
| Activation mechanism       | Hidden meta-message injection                  | Tool result in conversation flow               |
| User invocation            | `/skill-name` slash command                    | No direct equivalent (Emacs could bind keys)   |
| Model invocation           | Skill tool call                                | Skill tool call                                |
| Invocation control         | `disable-model-invocation`, `user-invocable`  | Not yet implemented                            |
| Context budget             | 2% of context window cap                       | No explicit cap                                |
| String substitution        | `$ARGUMENTS`, `$0`, `` !`cmd` ``               | Not yet implemented                            |
| Scoped permissions         | `allowed-tools` grants per skill               | Not yet implemented                            |
| File format                | YAML frontmatter + Markdown                    | YAML or Org properties + Markdown/Org          |
| Sub-agent forking          | `context: fork` runs skill in isolated agent   | Not yet implemented                            |


## Design Insights {#design-insights}


### Why Progressive Disclosure Matters {#why-progressive-disclosure-matters}

Without skills, there are two bad options for domain knowledge: put everything in the system prompt (context bloat) or leave it out (the agent doesn't know how). Skills create a third option: advertise cheaply, load on demand. The metadata-only discovery phase costs ~100 tokens per skill. A project with 20 skills adds ~2,000 tokens to the system message---manageable. The full bodies load only when needed.


### Tool Description vs. System Prompt {#tool-description-vs-system-prompt}

Claude Code's choice to embed skills in the tool description rather than the system prompt is worth reflecting on. The system prompt is a fixed cost: it is sent with every request. The tool description is also sent with every request, but it belongs to a specific tool---the `Skill` tool. This creates a conceptual alignment: skills are accessed _through_ a tool, so their metadata lives _with_ that tool.

gptel-agent's template approach is more flexible: the `={{SKILLS}}=` variable can appear anywhere in any agent's system prompt, allowing different agents to present skills differently. But it means the skills list is duplicated across agents rather than living in one canonical location.


### Cross-Tool Compatibility {#cross-tool-compatibility}

gptel-agent's decision to scan directories from _all_ major agentic tools is pragmatic and forward-looking. A skill written for Claude Code works in gptel-agent without modification. The agentskills.io specification made this possible by standardizing the minimal contract: a directory with `SKILL.md` containing YAML frontmatter with `name` and `description`.


### What gptel-agent Does Not Yet Implement {#what-gptel-agent-does-not-yet-implement}

The comparison reveals features that gptel-agent could adopt:

- **Invocation control flags** (`disable-model-invocation`, `user-invocable`) for fine-grained activation policy
- **String substitution** (`$ARGUMENTS`) for parameterized skills
- **Context budgeting** to prevent skills discovery from consuming too much context
- **Scoped permissions** to grant specific tool access when a skill is active
- **Sub-agent forking** to run skills in isolated contexts

These represent the difference between "skills as knowledge injection" (gptel-agent today) and "skills as scoped execution environments" (Claude Code's fuller model).


## Writing Your First Skill {#writing-your-first-skill}

To create a skill that works across both systems:

```
mkdir -p .claude/skills/review-code
```

Create `.claude/skills/review-code/SKILL.md`:

```markdown
---
name: review-code
description: Review code changes for correctness, style, and potential issues
---

Review the code changes in the current context. Follow these steps:

1. Read the diff or changed files
2. Check for correctness: logic errors, edge cases, off-by-one errors
3. Check for style: naming, formatting, consistency with surrounding code
4. Check for issues: security vulnerabilities, performance problems, missing error handling
5. Provide feedback organized by severity (critical, suggestion, nitpick)

Focus on substantive issues. Do not comment on formatting that a linter would catch.
```

This skill will be discovered by Claude Code, gptel-agent, Codex, and any other tool that follows the agentskills.io convention. The LLM will see the description in its available skills list and can load the full instructions when performing a code review.

The power of skills is their simplicity: a directory, a markdown file, a name, a description, and instructions. No compilation, no registration, no API. Just text that teaches an agent how to do something well.

> _Previous: [Scaling Up: Complex System-Prompts](/tutorial/07-scaling/)_
>
> _Return to: [Why System-Prompts Matter](/tutorial/01-why/)_
