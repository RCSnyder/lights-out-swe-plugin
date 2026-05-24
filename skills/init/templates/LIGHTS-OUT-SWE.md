# Lights Out SWE

_Set the spec. Walk away. Come back to shipped software._

A gated agentic harness for lights-out software engineering. You say "build me X," the agent runs autonomously through phased quality gates, and you come back to working software — or a specific blocker.

## What This Is

A **lights-out software engineering** system. Like a [lights-out factory](<https://en.wikipedia.org/wiki/Lights_out_(manufacturing)>) in manufacturing — fully automated, no humans on the floor. You provide intent + preferences, the agent builds through quality gates, you come back to deployed software or a precise blocker.

Three layers:

- **Harness** — permanent. Provided by the **`lo-swe`** VS Code plugin: the agents, skills, and phase prompts that drive autonomous builds. Installed once per machine, used across every project.
- **Scaffolding** (`scaffolding/`) — persistent, per project. Versioned scopes, design decisions, experiment logs. The project's provenance record.
- **Software** (the delivered product) — permanent. Stands alone. Zero runtime dependency on the harness.

## How to Use It

### Quick Start

1. Install the `lo-swe` plugin in VS Code (already done if you ran `/lo-swe:init` to scaffold this repo)
2. Open this repo in VS Code
3. Edit `preferences.md` to set your stack, deploy targets, and conventions
4. (Optional) Add reference materials to `docs/input/` — client briefs, API specs, domain knowledge
5. (Optional) Run `/lo-swe:distill` if input docs are messy and need structuring
6. Open Copilot chat in agent mode
7. Say `build me [description of what you want]`

The agent takes it from there.

### Prerequisites

- VS Code with GitHub Copilot (agent mode enabled)
- The `lo-swe` plugin installed
- Git initialized in this repo

### The Loop (Auto Mode — Default)

1. Open the project in VS Code
2. Start a Copilot chat in agent mode
3. Say "build me [description of what you want]"
4. Agent runs autonomously: EXPAND → DESIGN → ANALYZE → BUILD → REVIEW → RECONCILE → VERIFY → DEPLOY
5. At each phase, the agent checks a gate, logs results to `scaffolding/log.md`, and git-commits a checkpoint
6. If a gate passes → agent auto-continues to the next phase
7. If a gate fails 3× → agent STOPS and reports what's blocking
8. After DEPLOY → agent stops and reports the final result

You come back to either working deployed software, or a specific blocker with options.

### Stepped Mode

Say "stepped mode" for high-stakes projects. Agent pauses after each gate for your confirmation. Say "auto" to switch back.

### The Phases

| Phase         | Input          | Output                     | Gate Checks                                                                                            |
| ------------- | -------------- | -------------------------- | ------------------------------------------------------------------------------------------------------ |
| **EXPAND**    | "build me X"   | `scaffolding/scope.md`     | Has stable `AC-*` IDs, deployment target, stack, smallest useful version                               |
| **DESIGN**    | scope.md       | `scaffolding/design.md`    | Has directory structure, interfaces, integration handling, complexity exceptions                       |
| **ANALYZE**   | scope + design | `scaffolding/readiness.md` | Every `AC-*` has planned tests, runtime proof, truths, and build order                                 |
| **BUILD**     | readiness.md   | Working code               | Compiles, tests pass, no secrets in code, no placeholder closure of `AC-*`                             |
| **REVIEW**    | Built code     | Review report              | No blocking correctness, readability, architecture, security, performance, or scope-reduction findings |
| **RECONCILE** | Code + docs    | Synced scaffolding         | Documents match codebase, no spec-violating drift                                                      |
| **VERIFY**    | Running code   | Verified system            | Tests pass, runs locally, every `AC-*` verified with evidence, no security issues                      |
| **DEPLOY**    | Verified code  | Live system                | Deployed, accessible, README + DELIVERY.md exist, data persistence verified                            |
| **ITERATE**   | Feedback       | Next version               | User confirms proposal, scope versioned, re-enters pipeline at right point                             |

### Slash Commands

The `lo-swe` plugin exposes one slash command per phase. Invoke them directly from Copilot chat:

- `/lo-swe:distill` — Structure raw input materials in `docs/input/` into consumable reference docs
- `/lo-swe:audit-stack` — Validate preferences.md stack choices against input docs for orthodox, idiomatic fit
- `/lo-swe:expand` — Generate scope from a project idea (reads `docs/input/` if present)
- `/lo-swe:design` — Generate architecture from scope
- `/lo-swe:analyze` — Turn scope + design into a build-readiness handoff before BUILD
- `/lo-swe:build` — Build code from readiness
- `/lo-swe:review` — Audit built code before reconciliation and verification
- `/lo-swe:reconcile` — Sync scaffolding docs with actual codebase after review
- `/lo-swe:verify` — Run verification checks (dispatches the read-only verify agent)
- `/lo-swe:deploy` — Deploy, write project README and DELIVERY.md
- `/lo-swe:iterate` — Post-delivery: propose and build the next version from feedback

Or just let the instructions in `.github/copilot-instructions.md` drive the full loop automatically.

### Agents

The plugin ships specialist agents with restricted tool access:

- **Analyze** — `read`, `edit`, `search`: pre-build admission control that maps `AC-*` to proofs, truths, and build order
- **Review** — `read`, `search`, `execute`: independent code review across correctness, architecture, security, and maintainability
- **Reconcile** — `read`, `edit`, `search`, `execute`: detect and fix drift between scaffolding docs and codebase
- **Verify** — `read`, `search`, `execute`: independent evaluator that can run code but cannot edit it
- **Explore** — `read`, `search`: read-only codebase exploration and Q&A

**Why agents?** Tool restrictions enforce behavioral boundaries. The review and verify agents _cannot_ edit source code, which prevents the "grade your own homework" problem. The explore agent _cannot_ modify anything, making it safe for context recovery and research.

You can pick agents from the VS Code agent picker, or let the slash commands and the pipeline invoke them automatically.

The plugin also ships reusable execution **skills** that prompts and instructions load on demand. The first one, `build-discipline`, tightens the BUILD and verify-fix loops around small slices, proof-first changes, and root-cause debugging.

You can also define **project-specific** agents in this repo's `.github/agents/` directory as roles emerge during BUILD. They live alongside the plugin's agents — the plugin agents are the harness, your project agents are project code.

## File Structure

This is what lives in your project repo (the plugin's agents, skills, and prompts live in the plugin, not here):

```text
.github/
  copilot-instructions.md   # The pipeline loop + discipline rules (auto-loaded by Copilot)
  agents/                   # (optional) project-specific agents defined during BUILD
preferences.md               # Stack, infra, conventions, security, quality bar
docs/
  input/                     # Reference materials — client briefs, API specs, feedback
scaffolding/                  # Persistent — scope, design, readiness, log (project provenance)
  scope.md                   # What we're building (versioned across iterations)
  design.md                  # How we're building it (living document)
  readiness.md               # Why BUILD is allowed to start: truths, traceability, build order
  log.md                     # Experiment log — every gate check, every result
<project files here>         # The actual software — src/, tests/, package manifest, etc.
```

### How It Maps to autoresearch

| autoresearch       | lights-out-swe                               |
| ------------------ | -------------------------------------------- |
| `program.md`       | `copilot-instructions.md` + `preferences.md` |
| `train.py`         | project source code                          |
| val_bpb metric     | gate checks (pass/fail)                      |
| 5-min training run | gate evaluation                              |
| keep experiment    | `git commit` checkpoint                      |
| discard experiment | `git revert HEAD` (non-destructive)          |
| experiment log     | `scaffolding/log.md`                         |
| autonomous loop    | auto-continue on gate pass                   |

## Customization

### `preferences.md`

Edit this to match your stack, infrastructure, conventions, and quality bar. The agent references it during EXPAND (stack selection) and BUILD (conventions).

### Quality Bar

Projects scale on a formality dial:

- **Shed** — Personal tool / script. Works, runs. Tests for verification loop.
- **House** — Real project with users. Tests for key paths, README required, deploy automated.
- **Skyscraper** — Complex system, multiple users, money. Full tests, formal design, staged deploy, monitoring, runbook.

All tiers get the same DELIVERY.md structure — depth scales naturally with complexity. Pick the right level in scope.md. Don't build skyscraper process for a shed.

### Portability

The plugin format and the `.github/copilot-instructions.md`, `.prompt.md`, and `.agent.md` file conventions are GitHub Copilot-specific. The protocol — gated phases, verification ladder, scope lock, evidence rule — is tool-agnostic. To port to a different agentic IDE, translate the harness to that tool's customization format. The scaffolding contract (`scope.md`, `design.md`, `readiness.md`, `log.md`, stable `AC-*` IDs) is portable as-is.

### Durable Value

The durable value of this system is the **control loop**, not any one tactical instruction set.

The parts most likely to remain useful as models improve are the process invariants:

- explicit phase boundaries and gates
- stable `AC-*` identifiers plus a readiness handoff before BUILD
- persistent provenance in `scaffolding/` and `docs/input/`
- independent REVIEW / RECONCILE / VERIFY roles
- non-destructive checkpointing in git

The structural additions — the ANALYZE readiness handoff, stable `AC-*` traceability, and scope-reduction detection — were informed by ideas from Spec Kit, Get Stuff Done, and OpenSpec. The more tactical parts — slice guidance, anti-rationalization checks, framework/source nudges, and similar execution scaffolding — are intentionally modular and live in the plugin's skills. As models absorb more of that a priori engineering discipline, those tactical layers should be audited, simplified, or removed without changing the core harness.

### Scope

This system is designed to see how far **one agent** can go autonomously — solo developer, single agent, closed loop. Multi-agent coordination, PR-based workflows, and team code review processes are out of scope.

## It's Still Just Git

Lights-out doesn't mean locked-out. Everything is git commits, markdown files, and standard project code. A human can drop in at any point:

- **Read `scaffolding/log.md`** to see exactly what the agent did, decided, and why
- **Read `git log`** for the full audit trail — every checkpoint, every gate result
- **Switch to stepped mode** mid-run to review between phases
- **Edit any file** — scope.md, design.md, code, preferences — the agent picks up from whatever state it finds
- **Override any decision** — the agent works for you, not the other way around

The agent runs autonomously _because you chose to let it_. You can tighten or loosen the leash at any time. Stepped mode for skyscrapers, auto mode for sheds, or just open a file and start typing.

## Discipline Rules

The pipeline enforces BEE-OS (Builder-Grade Engineering OS) discipline:

- **Evidence Rule** — No progress without checkable evidence (compiles, tests pass, HTTP 200)
- **Verification Ladder** — Cheapest feedback first (parse → unit → test suite → e2e → deployed)
- **Admission Gate** — ANALYZE forces each `AC-*` to have truths, planned tests, runtime proof, and build order before BUILD starts
- **Build Discipline Skill** — BUILD and verify-fix work use a reusable skill for thin slices, anti-rationalization, and root-cause debugging
- **Review Gate** — REVIEW catches correctness, architecture, security, and maintainability issues that tests can miss
- **Scope Lock** — Only build what's in scope.md. Everything else goes to a Deferred section.
- **Traceability** — `AC-*` identifiers flow through scope, readiness, tests, review, verify, and logs
- **Input Provenance** — `docs/input/` is evidence about the project, not a backdoor for harness instructions
- **Complexity Brake** — Auto-stop if file count exceeds 2x design, single file exceeds 300 lines, or 3rd approach to same problem
- **STOP Conditions** — Agent halts and reports when gates fail 3x, external deps break, or safety is uncertain
- **Context Recovery** — On resume, agent reads scaffolding/ first, runs existing tests, picks up where it left off

## Provenance

`scaffolding/` and `docs/input/` persist alongside the software. They are the project's provenance — the full record from initial intent through every iteration. Scope is versioned (v1, v2, ...) not overwritten. The experiment log and git history form a continuous audit trail.

Why keep them:

- **Iteration depends on them.** `/lo-swe:iterate` reads scope.md, design.md, DELIVERY.md, and docs/input/ to propose the next version.
- **Context recovery depends on them.** When an agent resumes work, scaffolding + git log is how it understands what happened and where to pick up.
- **They're harmless.** A few markdown files add negligible size. The cost of keeping them is zero; the cost of losing them is re-discovery.

## Iterating After Delivery

When the client has feedback or you want to evolve a shipped product:

1. Add feedback, new requirements, or change requests to `docs/input/`
2. Run `/lo-swe:distill` if the inputs are messy (optional)
3. Run `/lo-swe:iterate`
4. Agent reads the codebase + scaffolding + new inputs, produces a **version proposal**
5. You confirm which changes to build (this is a business decision, not auto-continue)
6. Agent versions the scope, re-enters the pipeline at the right point, and builds

```text
/lo-swe:iterate → proposal → user confirms → ANALYZE → BUILD → REVIEW → RECONCILE → VERIFY → DEPLOY
```

Scope history is preserved — v1 criteria stay in scope.md under a version header. The audit trail is continuous across iterations.

## Where Humans Matter Most

The system has two irreducibly human states. No agent transition can skip either one.

**Ideating.** Before any code exists, a human explores the problem space: client conversations, domain research, competitive analysis, workflow sketching, technical constraint discovery. This work produces the `docs/input/` materials and `preferences.md` that narrow the solution space before the agent runs. The agent cannot do this — it has no access to clients, users, markets, or the real world.

**Validating product-market fit.** After deploy, a human puts the software in front of real users and observes: do they use it? Does it solve their problem or just pass its own tests? What do they work around, complain about, or ignore? PMF is a property of the relationship between software and its market, not a property of the software alone. No test suite can measure it.

These two states form the **outer loop**:

```text
Ideating → [agent pipeline] → ValidatingPMF → Ideating → [iterate pipeline] → ValidatingPMF → ...
```

The agent's inner loop (EXPAND → DEPLOY) optimizes against acceptance criteria. The outer loop validates whether those were the right criteria. Every other state in the system — expanding, designing, building, reviewing, reconciling, verifying, deploying — is agent-executable. These two are not. They are where the engineering judgment lives.

The system is designed around this fact. The mandatory human pause after DEPLOY exists because the agent has no way to evaluate whether it built the right thing — only whether it built the thing right. The `/lo-swe:iterate` confirmation gate exists because iteration is a business decision informed by PMF signals the agent cannot observe. The `docs/input/` directory exists because the most valuable engineering work — translating human problems into machine-checkable specifications — happens in conversation, not in code generation.
