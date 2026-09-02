# UX Specification — Career Twin

## Experience objective

Career Twin should feel like a high-end technical intelligence product, not a portfolio with a chatbot bolted on. A recruiter should understand the candidate, inspect evidence, test technical depth, and evaluate role fit in under five minutes without learning the product first.

The default experience prioritizes confidence, speed, evidence, and progressive disclosure. Advanced AI internals are available when the visitor wants to inspect them, but they never block the core recruiter journey.

## Primary users

1. Technical recruiter — fast screening, evidence, job fit.
2. Engineering / Applied AI hiring manager — architecture, projects, code, tradeoffs, depth.
3. Staff / Principal Engineer — challenge mode, code/system design, provenance.
4. Candidate / admin — curate evidence, resolve conflicts, control visibility, monitor ingestion.

## Information architecture

### Public navigation

- Overview
- Ask the Twin
- Projects
- Skills
- Experience
- Job Fit
- Applied AI Lab
- Architecture

### Contextual destinations

- Evidence viewer
- Project detail
- Skill detail
- Code/source detail
- AI Inspector
- Job-fit report
- Challenge / Interview mode

### Admin navigation

- Sources
- Claims & evidence
- Conflicts
- Visibility
- Ingestion status
- Eval status

## Screen inventory

### S-001 Recruiter Overview

Purpose: communicate who the candidate is and why the experience is worth exploring within 20 seconds.

Content:
- concise positioning statement
- high-confidence skills with evidence counts/categories, not star ratings
- featured projects
- career timeline preview
- certifications
- proof-oriented prompts
- prominent `Ask the Twin` and `Analyze a Job` actions

Primary actions:
- ask a suggested question
- open a project
- inspect a skill
- paste a job description

States:
- loading: skeletons for candidate profile and featured evidence
- degraded: show static verified profile if AI is unavailable
- empty: not expected for public release; release blocker if no verified evidence exists

### S-002 Ask the Twin

Purpose: natural-language exploration of candidate evidence.

Layout:
- conversation area
- composer with suggested prompt chips
- answer cards with concise summary first
- inline citation markers
- evidence/confidence footer
- `View evidence` and `View AI execution` actions

Answer structure:
1. direct answer
2. strongest evidence
3. relevant nuance/gaps
4. citations
5. optional follow-up actions

Failure behavior:
- no evidence: explicitly say insufficient verified evidence
- provider failure: preserve the question and show retry; never invent fallback content
- partial retrieval failure: answer only from successfully verified sources and disclose reduced coverage
- unsafe/forbidden request: explain boundary and keep recruiter-safe alternatives available

### S-003 Evidence Drawer / Evidence Page

Purpose: prove the claim.

Display:
- claim supported
- verification state
- source type
- source title/repository
- file/symbol/commit/PR provenance when available
- relevant excerpt/diff metadata where permitted
- freshness timestamp
- confidence/evidence quality
- link to canonical source

Interaction:
- open source
- traverse parent project/repository/skill
- compare multiple supporting evidence items

### S-004 Project Explorer

Purpose: convert repository complexity into a recruiter-friendly but technically deep project narrative.

Sections:
- overview / problem / outcome
- architecture map
- stack
- AI concepts
- engineering challenges
- decisions and tradeoffs
- evidence
- code highlights
- verified metrics only
- lessons / improvements

Depth toggle:
- Recruiter
- Engineering Manager
- Principal Engineer

### S-005 Skill Detail

Purpose: show why a skill is believed rather than rating it decoratively.

Sections:
- evidence summary
- transparent dimensions: breadth, depth, recency, project diversity, code evidence, architecture evidence, tests, deployment/production evidence
- projects demonstrating the skill
- exact code/docs evidence
- confidence and caveats
- related skills/concepts

### S-006 Job Fit

Purpose: evaluate the candidate against a pasted job description.

Flow:
1. paste job description
2. analyze requirements
3. show parsed requirements for transparency
4. generate evidence matrix
5. show match summary, strengths, gaps, unknowns
6. show recommended interview questions
7. allow drill-down into evidence

Output:
- requirement
- importance
- match state: strong / moderate / weak / gap / unknown
- evidence quality
- supporting sources
- explanation

No naive keyword percentage.

### S-007 AI Inspector

Purpose: make Applied AI implementation visibly inspectable without exposing private chain-of-thought.

Display:
- normalized query
- detected intent
- retrieval strategies chosen
- result counts by retriever
- fusion/reranking stages
- selected evidence IDs/sources
- graph paths used
- MCP/tool calls with names/status/duration
- model/prompt/schema versions
- citation coverage
- evidence confidence
- latency breakdown
- token/cost metrics where available
- fallbacks/errors

Never display hidden reasoning tokens or private prompts containing secrets.

### S-008 Applied AI Lab

Purpose: prove implementation depth interactively.

Required demos:
1. Dense vs BM25 vs Hybrid retrieval
2. Before/after reranking
3. Chunking comparison / parent-child retrieval
4. GraphRAG path discovery

Additional desirable demos:
- context budget inspector
- query decomposition
- MCP capability/tool selection
- eval dashboard

Each demo must use real safe evidence or committed fixtures and show measurable output, not animation-only simulations.

### S-009 Architecture

Purpose: explain how Career Twin works and why architectural choices exist.

Display:
- interactive architecture map
- component responsibilities
- data flow
- AI vs deterministic boundaries
- reliability/security boundaries
- tradeoffs / rejected alternatives
- links to relevant docs/evidence

### S-010 Challenge / Technical Interview

Purpose: let technical visitors test reasoning depth.

Controls:
- topic
- seniority/difficulty
- prompt/question

Response must visibly label:
- `Hypothetical reasoning` when answering new design questions
- `Backed by prior project evidence` only when evidence exists

### S-011 Admin Sources

Purpose: manage authorized evidence ingestion.

Display:
- source
- visibility
- last indexed
- index status
- errors
- evidence/claim counts
- reindex action

### S-012 Admin Claims & Conflicts

Purpose: protect the Career Truth Layer.

Display:
- claims
- verification status
- supporting/conflicting evidence
- visibility
- freshness
- resolution history

Actions require authentication and deterministic validation.

## Core journeys

### Journey A — 60-second recruiter screen

`Overview -> suggested question -> grounded answer -> strongest evidence -> decision to continue`

Success: recruiter sees a high-signal answer and can inspect proof in at most two interactions.

### Journey B — Prove a skill

`Ask "Does he know RAG?" -> skill-verification intent -> evidence-grounded answer -> skill detail -> exact project/code evidence -> AI Inspector optional`

Success: skill conclusion is supported by multiple evidence categories and caveats are visible.

### Journey C — Evaluate against a role

`Job Fit -> paste JD -> parsed requirements -> evidence matrix -> strengths/gaps -> open evidence -> recommended interview questions`

Success: no requirement is silently ignored; unknowns are distinguished from gaps.

### Journey D — Deep project review

`Projects -> project -> architecture -> decision/tradeoff -> code/evidence -> explanation depth switch`

Success: non-technical and senior-technical visitors can understand the same project at appropriate depth.

### Journey E — Challenge the Twin

`Challenge -> select Senior/Staff topic -> ask system-design question -> hypothetical answer -> optionally relate to verified project evidence`

Success: product never conflates hypothetical competence with historical accomplishment.

### Journey F — Inspect the AI

`Any answer -> View AI execution -> inspect retrievers/tools/graph/citations/latency -> open Applied AI Lab comparison`

Success: advanced AI techniques are visible and understandable without exposing chain-of-thought.

### Journey G — Admin resolves conflicting evidence

`Admin -> conflicts -> inspect sources -> choose status/visibility resolution -> deterministic validation -> audit record`

Success: recruiter-facing truth changes only after authenticated explicit action.

## Screen/state contract rules

Every data-dependent screen must define and implement:
- initial loading
- partial loading
- success
- empty
- stale data
- permission denied
- rate limited
- source unavailable
- AI provider unavailable
- malformed AI output
- retrieval produced no evidence
- network retry/recovery

AI failures may never cause unsupported candidate claims to appear.

## Interaction patterns

### Progressive disclosure

Default answers should be recruiter-readable. Deep evidence, architecture, graph paths, code, and AI execution expand on demand.

### Evidence-first affordances

Every claim-oriented surface should make `View evidence` more prominent than decorative confidence graphics.

### Confidence language

Use human-readable states such as:
- Strong verified evidence
- Good demonstrated evidence
- Limited evidence
- Conflicting evidence
- No verified evidence

Numeric scores may appear in advanced views only when their formula and inputs are inspectable.

### AI transparency

Use labels such as:
- Retrieved evidence
- Inferred relationship
- Self-reported
- Hypothetical reasoning
- Verified source

Do not imply deterministic certainty from model output.

## Recovery and destructive flows

Public recruiter mode has no destructive source actions.

Admin destructive or consequential actions such as source deletion, visibility reduction, or claim-status changes require:
- authenticated session
- explicit target scope
- confirmation for destructive changes
- server-side authorization
- audit record
- success/failure feedback
- safe retry behavior

Reindex is non-destructive but should be idempotent and show progress/error states.

## Responsive behavior

### Desktop >= 1280

Use dense multi-pane experiences where helpful: conversation + evidence, project + architecture, job matrix + evidence panel.

### Tablet 768–1279

Collapse secondary inspector/evidence panes into drawers or tabs.

### Mobile < 768

Single-column flow. Preserve primary actions, citations, evidence access, and job-fit readability. Complex tables become stacked requirement cards. Graph/architecture views support pan/zoom and textual alternative summaries.

## Accessibility target

WCAG 2.2 AA where applicable.

Requirements:
- semantic headings/landmarks
- full keyboard navigation
- visible focus
- no color-only status communication
- minimum touch targets
- sufficient contrast
- reduced-motion support
- accessible dialog/drawer focus management
- live-region or equivalent handling for streaming/status where appropriate
- meaningful labels for graphs/diagrams plus textual alternatives
- code blocks and tables navigable by assistive technology

## UX acceptance criteria

1. A first-time visitor can identify who the candidate is and start a high-value action within 20 seconds.
2. A recruiter can move from question to inspectable evidence in two interactions or fewer.
3. Job Fit preserves requirement-level transparency and visible unknowns/gaps.
4. Every AI answer state has explicit no-evidence and provider-failure behavior.
5. AI Inspector exposes process metadata without exposing private chain-of-thought.
6. Public experience works without signup.
7. Primary recruiter flows are fully keyboard accessible and responsive.
8. The visual hierarchy emphasizes evidence and decision support over decorative AI motifs.
