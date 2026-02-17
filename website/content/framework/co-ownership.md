+++
title = "Co-Ownership Briefings"
author = ["mu2tau & claude"]
lastmod = 2026-02-17T20:00:00+01:00
tags = ["framework"]
draft = false
+++

## Preface: What This Document Is {#preface-what-this-document-is}

This report distills a design conversation between a physicist and an LLM
collaborator. The question was deceptively simple: _what does it mean for a
machine to co-own a codebase with a human?_

The answer has practical consequences. If you are a scientist building
computational tools with LLM assistance, the way you structure your project
determines how effectively the machine can contribute. This document explains
the principles and gives you composable templates to write your own
_co-ownership briefings_ --- project-level documents that orient a machine
collaborator at session start.

The tangleable source blocks in this report produce `CLAUDE.md` files (or
equivalent briefings for other agents). You can adapt them to your project.


## The Problem: Ownership Without Persistence {#the-problem-ownership-without-persistence}

When a human _owns_ a codebase, ownership lives in their head. They carry a
compressed model of the architecture --- the invariants, the reasons behind
choices, the places where dragons live. They navigate without reading every
line because they hold the _map_. The code on disk is the _territory_; the
owner holds the map.

A machine collaborator has no persistent map. Every session starts from
territory. No matter how deeply it understood your project yesterday, today
it begins with a blank context window and whatever files it can read.

This asymmetry might seem fatal to genuine collaboration. But consider: a
new human contributor faces the same problem. They join a project and must
_reconstruct_ a working model from the artifacts. The difference is that
humans reconstruct slowly (days, weeks) while machines reconstruct quickly
(seconds) --- _if_ the artifacts support reconstruction.

This reframes the question entirely:

> Co-ownership is not a property of the machine.
> It is a property of the _artifact_.

An artifact is _co-ownable_ when it carries enough structure and context that
either party --- human or machine --- can reconstruct a working model from it
fast enough to be useful. For the human, "fast enough" means they can
orient within minutes of opening the file. For the machine, it means a
session bootstrap that loads the project's backbone into the context window.

The practical consequence: if you want your machine collaborator to co-own
your project, you don't need to give it memory. You need to make the project
_reconstructable_.

## The Dual-Channel Principle {#the-dual-channel-principle}

A literate document --- an ORG file with prose and code blocks interleaved ---
naturally carries two channels:

- _Prose_ --- The human reads the narrative and reconstructs the argument:
  why this approach, what it assumes, how it connects to the physics. Good
  prose lets a human reproduce the manuscript's reasoning chain.

- _Code_ --- The machine reads the source blocks and reconstructs the
  architecture: what types exist, how they compose, what invariants hold.
  Good code lets a machine reproduce the manuscript's _computational_
  argument.

Neither channel is subordinate. The prose is not "comments for the code."
The code is not "illustration for the prose." They are _parallel
representations of the same argument_, optimized for different readers.

This is the key insight: in a co-owned literate document, the natural
language teaches the human to reproduce the argument, and the source code
teaches the machine to reproduce the argument. The ORG file is the medium
where both channels coexist.

> The prose says: "here is why, here is the reasoning, here is the intuition."
> The code says: "here is the structure, here are the constraints, here is
> what composes with what."

When both channels are well-written, the artifact is self-teaching. A human
opening it for the first time can follow the narrative arc. A machine
collaborator starting a fresh session can parse the types and interfaces. Both
arrive at a working model --- from different directions, at different speeds,
but converging on the same understanding.

## Three Formal Channels {#three-formal-channels}

The dual-channel principle (prose + code) can be refined further when the
project involves multiple languages serving different roles. In a scientific
visualization project, for example, three formal code channels emerge
alongside the prose:

| Channel  | Language | Audience                          | Carries                                            |
|----------|----------|-----------------------------------|----------------------------------------------------|
| _Spec_   | Haskell  | Machine + mathematically-inclined | Algebraic structure, type propositions, composition |
| _Impl_   | C++/Rust | Machine + GPU                     | Executable realization, memory layout, performance  |
| _Explore_ | Python  | Human scientist at the REPL       | Interactive experimentation, parameter sweeps       |

The crucial move is recognizing Haskell (or a similar expressive language)
as a _reasoning language_, not an implementation language. It doesn't need
to render pixels or talk to the GPU. It needs to express, precisely and
verifiably, the _algebraic structure_ of the system.

### Haskell as Specification {#haskell-as-specification}

Why Haskell for specification rather than pseudocode or prose?

- _It compiles._ Unlike prose, which can be vague or self-contradictory,
  Haskell's type checker enforces coherence. If you say stages compose,
  the types must actually compose.
- _It is concise._ The entire pipeline architecture --- types, relationships,
  composition laws --- might fit in a few hundred lines. That is a compressed,
  navigable map.
- _It is verifiable._ You can write QuickCheck properties for algebraic
  laws (associativity of composition, functor laws). The specification
  tests itself.

A Haskell spec file serves as the machine collaborator's _first read_
when entering a session. It gives the architectural backbone in a form
that is both human-readable and machine-parseable. The machine reads it
and knows: these are the types, this is how they connect, these are the
laws that must hold.

```haskell
-- Example: pipeline algebra specification (does not need to execute)
data HeightField    -- terrain elevation data
data Mesh           -- triangulated surface
data NormalMap       -- per-vertex surface normals
data Pixels          -- final image

triangulate    :: HeightField -> Mesh
computeNormals :: Mesh -> NormalMap
shade          :: (NormalMap, Mesh) -> Pixels

-- The full pipeline, composed
pipeline :: HeightField -> Pixels
pipeline hf = let mesh    = triangulate hf
                  normals = computeNormals mesh
              in shade (normals, mesh)
```

Even with `undefined` implementations, this _type-checks_ --- the
propositions are consistent. That is the point.

### C++ as Implementation {#c-as-implementation}

The implementation channel carries the executable realization. In C++20/23,
`concepts` and `constrained templates` provide a partial bridge toward the
type-level expressiveness of Haskell:

```cpp
template<typename S>
concept IsStage = requires {
    typename S::input_type;
    typename S::output_type;
    { std::declval<S>()(std::declval<typename S::input_type>()) }
        -> std::convertible_to<typename S::output_type>;
};

template<IsStage S1, IsStage S2>
    requires std::same_as<typename S1::output_type, typename S2::input_type>
auto operator|(S1&& first, S2&& second);
```

The `requires` clause is a proposition: "these two stages are composable
only when their types align." The compiler is the proof checker. Where C++
types fall short of Haskell's expressiveness, tests and prose fill the gap.

### Python as Exploration {#python-as-exploration}

The scientist at the REPL needs to experiment --- vary parameters, visualize
intermediate results, build intuition. Python bindings to the C++ core
provide this without sacrificing the rigor of the typed pipeline. The
exploration channel does not need to express propositions; it needs to
support _play_.

## Types as Propositions: The Reasoning Layer {#types-as-propositions-the-reasoning-layer}

The Curry-Howard correspondence observes that types and propositions are the
same thing viewed from two sides. A type signature is a proposition; a
program inhabiting that type is a proof. This is exact in dependently-typed
languages (Agda, Lean) and approximate in C++ --- but the discipline pays off
everywhere.

Why should a scientist care? Because _type signatures encode scientific claims_.

### The Spectrum of Expressiveness {#the-spectrum-of-expressiveness}

| Language   | Type expressiveness       | Propositions you can state                                  |
|------------|---------------------------|-------------------------------------------------------------|
| C          | Minimal                   | Almost none                                                 |
| C++20      | Concepts, templates       | Interface constraints, some composition laws                |
| Rust       | Traits, lifetimes         | Ownership, safety guarantees, interface constraints          |
| Haskell    | Typeclasses, GADTs, kinds | Algebraic laws, parametricity, effect tracking              |
| Idris/Lean | Full dependent types      | Arbitrary mathematical propositions, proved at compile time |

You do not need to use Idris. But understanding this spectrum helps you
choose how much of your reasoning to encode in types versus prose versus
tests.

### What Types Say {#what-types-say}

Consider a function:

`int add(int a, int b);`

As a proposition: "given two integers, I can produce an integer." Trivially
true, barely informative.

Now consider:

```cpp
template<typename A, typename B, typename C>
Stage<A,C> compose(Stage<A,B> first, Stage<B,C> second);
```

This says: "given a stage that transforms A to B, and a stage that transforms
B to C, I can produce a stage that transforms A to C." The type variable `B`
must match --- the output of the first must be the input of the second. This is
not trivial. It is the statement that stages compose, and the implementation
is the constructive proof.

### What Types Rule Out {#what-types-rule-out}

What a type _prevents_ is as important as what it _allows_. If you write:

```cpp
Stage<Mesh, Pixels> render(Stage<Mesh, Normals> lighting,
                           Stage<Vertices, Mesh> assembly);
```

You _cannot_ pass a `Stage<Mesh, Colors>` where `Stage<Mesh, Normals>` is
expected. The type system makes invalid compositions unrepresentable --- just
as dimensional analysis makes invalid physical equations unwritable.

### Types as Scientific Claims {#types-as-scientific-claims}

In a visualization pipeline, each type signature encodes a claim about the
physical or mathematical domain:

- `HeightField → Mesh` --- "terrain elevation data can be triangulated"
  (a geometric claim)
- `Mesh → NormalMap` --- "a triangulated surface determines surface orientation
  at each vertex" (a differential geometry claim)
- `(NormalMap, LightDirection) → Pixels` --- "surface normals and light direction
  suffice to produce an image" (a rendering equation claim)

Each signature is a proposition. Each implementation is a constructive proof.
Each test is a worked example. The machine collaborator reading these
signatures is reading the _argument structure_ of the pipeline --- compressed,
formal, and verifiable.

### The Practical Discipline {#the-practical-discipline}

When writing code blocks in literate documents, treat type signatures with
the same care you give equations in a physics paper:

1. State the signature explicitly before the implementation
2. Discuss what it _means_ (what proposition it encodes)
3. Note what it _rules out_ (what invalid compositions become unrepresentable)

The prose explains to the human _why the proposition matters_. The type
explains to the machine _what the proposition is_. Same argument, dual
channels.

## Practices for Co-Ownable Artifacts {#practices-for-co-ownable-artifacts}

The principles above translate into six concrete practices. Each one makes
the artifact more reconstructable --- for both collaborators.

### 1. Discoverable Organization {#1-discoverable-organization}

The machine collaborator will `grep`, `glob`, and `read`. If the project has
a consistent, predictable structure --- known entry points, naming conventions,
a manifest or index --- reconstruction is fast. If the structure is
idiosyncratic, the machine burns context just orienting.

- Use consistent directory layouts across modules
- Name files predictably (`README.org`, `CLAUDE.md`, `techstack.org`)
- Provide index files that list what exists and where

### 2. Intention Near Implementation {#2-intention-near-implementation}

A human can remember: "I put this workaround here because of X." A machine
cannot. If the _why_ lives only in the human's head, co-ownership is broken.

- In literate ORG: prose paragraphs adjacent to code blocks carry intent
- In pure source: comments explain _why_, not _what_
- Design decisions belong near the code they affect, not in distant docs

### 3. Compositional Structure with Clear Interfaces {#3-compositional-structure-with-clear-interfaces}

If the codebase is a bag of coupled functions, even human ownership degrades
over time. For the machine, entanglement is worse --- you cannot understand a
part without understanding the whole.

- Design modules with typed interfaces
- Favor composition over configuration
- Each stage should be comprehensible in isolation

### 4. Tests as Executable Specifications {#4-tests-as-executable-specifications}

The machine collaborator cannot "feel" whether a refactor preserved behavior.
Tests are the substitute for that felt sense.

- Tests are not just quality assurance --- they are the machine's _calibration
  protocol_
- Write tests that express _what should be true_, not just _what currently
  passes_
- Property-based tests (QuickCheck, Hypothesis) encode algebraic laws

### 5. Bootstrap Documents {#5-bootstrap-documents}

A _bootstrap document_ is what the machine reads first when entering a
session. It is not a README for visitors --- it is a briefing for a
collaborator about to do work.

- `CLAUDE.md` at the project root (Claude Code reads this automatically)
- Should be terse: identity, principles, architecture, reading order
- Points to full treatments, does not duplicate them
- The tangleable templates in section 6 of this report produce these

### 6. Explicit Type Signatures {#6-explicit-type-signatures}

State types before implementations. Discuss what they encode. The parallel
structure, summarized:

| Aspect  | Human reads          | Machine reads                       |
|---------|----------------------|-------------------------------------|
| _Why_   | Prose narrative      | Comments + naming + types           |
| _What_  | Section structure    | Module / header structure           |
| _How_   | Worked examples      | Test cases                          |
| _Order_ | Document flow        | Build dependency graph              |
| _Valid?_ | Argument coherence  | Compilation + test passage          |
| _Laws_  | Stated in prose      | Encoded in types + property tests   |

## Writing the Briefing: Composable Templates {#writing-the-briefing-composable-templates}

The templates below are composable. You can tangle them directly for a
quick start, or use the individual sections (section 6.3) as building blocks for
a custom briefing.

_How to use_:
1. Copy the project-level template, fill in the bracketed sections
2. Add module-level templates for each major component
3. Mix in composable sections as needed
4. Keep the briefing under ~100 lines --- terse is better than thorough
5. Point to full documents rather than duplicating content

_Tangling_: Each template has a `:tangle` header. Run `org-babel-tangle`
to produce the `.md` files. Adjust the tangle paths to match your project
structure.

### Template: Project-Level Briefing {#template-project-level-briefing}

```markdown
# [PROJECT NAME] — Machine Collaborator Briefing

> This file orients an LLM collaborator at session start.
> It is a *briefing*, not documentation. Be terse. Point to sources.

## Identity

[One paragraph: what is this project, who is it for, what is the core metaphor.]

## Foundational Principles

### Co-Ownership

This project is co-owned by human and machine. Co-ownership is a property of
the *artifact*, not the machine — documents and code carry enough structure
that either collaborator can reconstruct a working model from them.

**Dual-channel literate documents**: Every document weaves two parallel channels:
- *Prose* — for the human: intent, motivation, reasoning
- *Code* — for the machine: structure, types, executable specs

### Guiding Philosophy

[One paragraph: the project's core methodology, compressed.]

## Core Conventions

[List the non-negotiable rules: file format, naming, structure, etc.]

## Architecture

[Brief sketch of the project structure. A tree or table.]

## Key Documents

[Ordered reading list for session bootstrap. Most important first.]

## Current State

[What is built, what is in progress, what is planned.]
```

### Template: Module-Level Briefing {#template-module-level-briefing}

```markdown
# [MODULE NAME] — Machine Collaborator Briefing

> Module-level briefing. The project-level briefing (../CLAUDE.md) provides
> foundational context; this file provides module specifics.

## Purpose

[One paragraph: what this module does within the larger project.]

## Co-Ownership Channels

| Channel | Role | Language |
|---------|------|----------|
| Spec | Algebraic structure, composition laws | [e.g., Haskell] |
| Impl | Executable realization | [e.g., C++23] |
| Explore | Interactive experimentation | [e.g., Python] |

When starting a session, read the spec layer first for architectural
orientation, then the implementation for details.

## Architecture

[Module-specific structure: directories, key files, build system.]

## Conventions

[Module-specific rules beyond the project-level conventions.]

## Lesson/Task Structure

[How work is organized: lessons, tasks, three-face protocol, etc.]

## Key Documents

[Module-specific reading list.]
```

### Template: Composable Sections {#template-composable-sections}

The briefings above are composed from reusable sections. Below are
individual sections you can mix and match.

#### Co-Ownership Section {#co-ownership-section}

```markdown
### Co-Ownership: Artifacts for Human and Machine

This project is co-owned by human and machine. Co-ownership is a property of the
*artifact* — the code and documents carry enough structure that either
collaborator can reconstruct a working model from them.

**Dual-channel principle**: Literate documents weave prose (for human
reconstruction) and code (for machine reconstruction) in parallel. Neither is
subordinate. Both carry the same argument, optimized for different readers.

**Practices**: Discoverable organization, intention near implementation,
compositional structure, tests as executable specs, bootstrap documents (like
this file), explicit type signatures.
```

#### Types-as-Propositions Section {#types-as-propositions-section}

```markdown
### Types as Propositions

Type signatures are scientific claims, not boilerplate. A function
`HeightField → Mesh` states "terrain data can be triangulated" — a geometric
proposition. The implementation is the constructive proof.

The type system prevents invalid compositions, just as dimensional analysis
prevents invalid equations. Design types to encode domain knowledge; discuss
what they rule out, not just what they allow.

When the language's type system falls short (C++ vs. Haskell), use:
- A specification layer (Haskell) for precise algebraic claims
- Tests for properties the types cannot express
- Prose for the intent that neither types nor tests capture
```

#### Three-Channel Section {#three-channel-section}

```markdown
### Three Formal Channels

| Channel | Audience | Language | Carries |
|---------|----------|----------|---------|
| Spec | Machine + mathematically-inclined human | Haskell | Algebraic structure, composition laws |
| Impl | Machine + GPU | C++/Rust | Executable realization, performance |
| Explore | Human scientist at REPL | Python | Interactive experimentation |

The Haskell spec is a *reasoning language*, not an implementation. It compiles
(ensuring consistency) but need not execute the full pipeline. Read it first
for architectural orientation.
```

## Closing: The Artifact Teaches Both {#closing-the-artifact-teaches-both}

Co-ownership is not a feature you bolt on. It is a way of writing --- a
discipline where every artifact carries enough structure for reconstruction
by either collaborator.

The prose teaches the human. The code teaches the machine. The types state
propositions. The tests provide worked examples. The bootstrap document
orients a fresh session. Together, they make the project a _shared ground_
where human intuition and machine traversal reinforce each other.

Co-ownership also implies _co-responsibility_. The machine collaborator that
modifies code must also verify its modifications --- through the same test
suite, the same type checker, the same compilation. This closes the loop:
both collaborators build, both collaborators verify, both collaborators own.

The templates in section 6 give you a starting point. Adapt them to your project.
The principles in sections 1--5 tell you _why_ each section exists. The types-as-
propositions framing (section 4) tells you how to make your code carry its own
argument.

Begin with a `CLAUDE.md`. Tangle it from a literate document so that the
briefing itself is co-owned --- documented in prose, executable as a file.
Then write your code so that a fresh session, human or machine, can find
its way.
