---

Spec Driven Development 
and the 
Descent into Chaos

---

Traditional Development Model

- PRD and design docs inform implementation

- Code is **King** and the one source of **Truth**

- Specs often discarded after initial coding is complete

- Over time code drifts from the specs

- The gap between intent and implementation ever increases

---

**With SDD there is no gap** 
because the code is always derived from the Spec.

---
Spec Driven Development:

- **Specs are King** 

- Only source of **Truth**

- Code is just a generated artifact from the spec

- If you want to change the code, you change the specs

- We're basically making specifications **executable!**

---

What Makes a Good Spec?

- The more precise and complete the specification, the more accurate the generated implementation

- Specifications are created from the PRD and design docs

- Every detail is defined - Tech stack, the back end to UI and UX flows etc

---

Agents

- Transform vague ideas into comprehensive specifications

- Research and make technology choices with documented rationale

- Define data models, API contracts, and system boundaries

- Performance Analysis, Security Assessment, Compatibility Checks

---

Task Agents

- Break down the specs into specific, actionable development task lists

---

Test-Driven Development Everywhere

- Without comprehensive testing, generated code would be unreliable

- TDD is the validation mechanism that ensures the generated implementation matches the specification's intent

- ~100% test coverage TDD proves the code works correctly.


---

 But It's not all rainbows and lolly pops!

---

The Problem

- Specs work great initially, but refinement generally becomes hard work.

- Generated code has an intrinsic structure that resists modification - there is a hidden coupling

- Even with careful separation of concerns, there is a form of entanglement that make refinement incredibly painful.

---
 
-  **Decent** into "vibe coding" 

- Vibe Coding is BAD

- Goals become confused, iterative prompting introduces untracked, inconsistent decisions.

- Burn tokens and time

---

### For Example:

- Yoda started with a spec to use local storage

- Realised need for real-time UI updates → Database

- Spent too long trying to "vibe code" to retrofit and remove entanglement

---

- Result: Mixed-up mess with residue - even today some pathways still try to use local storage

- Would have been much faster to modify the spec and rebuild the code from scratch

- Chaotic waste


---

How could we overcome this?

---

- What if we could break the application down into isolated small micro services?

- Know nothing of each other → no hidden coupling

---

Cell Body System

_Modular framework for building microservice-like applications inspired by biological systems_

---

Cell

- Does one task and does it well
- Completely isolated from other cells in all aspects
- All communications via a message bus

---

Body

- Main application shell
- Orchestrates cell lifecycle from an application manifest
- Owns the Body Bus
---

Body Bus

- Lightweight, low latency message bus (e.g. NATS https://nats.io/about/).
- Messages are small JSON → Binary envelopes.

--- 

The Specs (it's "DNA")

- Every Cell has its own spec.

- All behaviour is testable, reproducible and replaceable. 

- If you want to change the code, you change the spec and regenerate the code.

---

This is really powerful:

- Cells can be in any language Ployglot
- Cells can be anywhere.
- Adding new features or fixing bugs OTA means just replacing cells via the body system
- Message Bus Brain


---
## THE POWER INVERSION

---

![](Inteligence%20is%20the%20ability%20to%20change_1080.jpeg)