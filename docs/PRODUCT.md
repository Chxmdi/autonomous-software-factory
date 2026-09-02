# Product Definition — Career Twin

## Problem and evidence

Traditional resumes and portfolios are static, shallow, and difficult to verify. Recruiters see claims such as "Python", "RAG", "MCP", or "system design" but have little time to inspect repositories, architecture documents, commits, certifications, and project history to determine whether the claims are real or deep.

Career Twin turns the candidate's authorized career evidence into an interactive, inspectable technical representation. The system should reduce verification friction while increasing trust by grounding important claims in exact evidence.

The product itself is also a proof artifact: a technically sophisticated recruiter should be able to inspect its architecture and visibly see advanced Applied AI practices in operation.

## Users and jobs to be done

### Technical recruiter

When screening the candidate, I want a fast, trustworthy overview of role fit and supporting evidence so I can decide whether to advance him without manually reverse-engineering his GitHub and resume.

### Engineering / Applied AI hiring manager

When evaluating depth, I want to ask detailed questions about projects, architecture, RAG, agents, MCP, cloud, databases, and tradeoffs and inspect the evidence behind the answers.

### Staff / Principal Engineer or interviewer

When testing senior-level technical ability, I want to challenge the Twin with architecture and system-design questions, distinguish demonstrated historical work from hypothetical reasoning, and locate exact code/commit evidence.

### Candidate / admin

I want to curate verified career truth, control what evidence is public, ingest new work, resolve discrepancies, and observe how the Twin represents my capabilities.

## Value proposition and alternatives

### Value proposition

Career Twin is an evidence-grounded AI technical representative that can answer questions about the candidate, prove important claims, analyze job fit, explain projects at multiple technical depths, and expose the AI/retrieval/tooling system used to reach its answer.

### Alternatives

- Static resume: fast but shallow and weakly verifiable.
- Portfolio website: richer presentation but still manually navigated and mostly self-authored claims.
- Generic chatbot over resume: conversational but insufficiently grounded and technically unimpressive.
- GitHub alone: primary evidence but expensive for recruiters to inspect and difficult for non-engineers to interpret.

Career Twin combines these while preserving provenance and uncertainty.

## Core loop

1. Recruiter lands on a high-signal candidate overview.
2. Recruiter asks a question or pastes a job description.
3. System classifies intent and builds a retrieval/tool plan.
4. System retrieves relevant structured career facts, semantic evidence, lexical evidence, graph paths, and code/commit evidence.
5. Candidate evidence is reranked, diversified, and assembled within a context budget.
6. The model synthesizes an answer.
7. A verification layer extracts factual claims and checks support/provenance.
8. Unsupported claims are removed, downgraded, or explicitly labeled.
9. The answer is returned with citations, evidence confidence, and relevant next actions.
10. Recruiter may open evidence, inspect the AI execution trace, explore a project, challenge the Twin, or generate a job-fit report.

## Product principles

### PR-001 — Evidence before claims

Every important factual claim about experience, skills, projects, code, certifications, employment, or outcomes must be backed by one or more evidence records or clearly labeled as unverified/inferred/self-reported.

### PR-002 — Truth is immutable by conversation

Recruiter conversations cannot promote model output into verified career truth. Only authenticated ingestion/curation workflows may update the Career Truth Layer.

### PR-003 — Uncertainty is visible

The Twin must say when evidence is weak, conflicting, stale, or absent. Confidence is an evidence-quality indicator, not fabricated mathematical certainty.

### PR-004 — Historical vs hypothetical separation

The Twin may answer technical challenges and system-design questions, but must never imply a hypothetical answer represents work previously performed by the candidate.

### PR-005 — Visible Applied AI mastery

Advanced AI engineering must be product-visible through AI Inspector, Applied AI Lab, retrieval comparisons, graph paths, citations, tool traces, evaluation dashboards, and architecture explanations.

### PR-006 — Secure by default

External content is untrusted. Public recruiter sessions have no write privileges to candidate sources. Private evidence requires explicit access policy.

## Prioritized scope

### P0 — Required for V1

#### F-001 Recruiter landing

Provide a premium public landing page with concise candidate positioning, verified/high-confidence skill evidence, featured projects, certifications, career timeline, and guided recruiter prompts.

#### F-002 Recruiter conversation

Allow natural-language questions about the candidate with streaming answers, evidence citations, confidence labels, and follow-up actions.

#### F-003 Career Truth Layer

Represent claims with:

- claim ID
- normalized claim
- claim type
- subject/entity
- source/evidence IDs
- verification status: VERIFIED / DEMONSTRATED / SELF_REPORTED / INFERRED / UNVERIFIED / CONFLICTED
- confidence/evidence score
- visibility
- observed timestamp
- valid-time metadata where useful
- provenance and freshness

#### F-004 Evidence model

Support evidence from resume/profile data, repositories, files, symbols, commits, PRs/issues, tests, deployments/configuration, project docs, architecture decisions, certifications, and curated explanations.

#### F-005 GitHub ingestion

Ingest authorized repositories and normalize repository metadata, README/docs, source code, symbols, tests, infrastructure/configuration, commits, and PR/issue evidence where available.

#### F-006 Content-aware chunking

Use source-aware chunking. Code must be indexed by AST/symbol/module boundaries where supported rather than arbitrary fixed token windows. Documents, resumes, commits, PRs, and conversations require source-specific strategies.

#### F-007 Hybrid retrieval

Implement and evaluate:

- dense semantic retrieval
- sparse/BM25 retrieval
- metadata filters
- structured/SQL retrieval
- graph retrieval
- code-aware retrieval

Merge candidates with Reciprocal Rank Fusion or an empirically justified alternative.

#### F-008 Query understanding and decomposition

Classify recruiter intent and choose retrieval/tool strategies accordingly. Complex questions may decompose into independently retrievable subquestions.

#### F-009 Reranking and context assembly

Rerank retrieval candidates, enforce evidence/source diversity, remove duplicates, perform parent/child expansion where justified, and construct a bounded context based on authority, relevance, recency, and token budget.

#### F-010 Career Knowledge Graph

Represent candidate, skills, technologies, projects, repositories, files, symbols, commits, experiences, employers, certifications, achievements, architecture decisions, concepts, job requirements, and evidence with typed relations.

#### F-011 GraphRAG

Use graph traversal when relational evidence improves an answer. Display relevant graph paths in the recruiter evidence UI / AI Inspector.

#### F-012 Entity resolution

Resolve aliases for candidate, skills, technologies, repositories, projects, organizations, and common acronyms. Low-confidence resolutions remain reviewable.

#### F-013 Citation engine

Important claims should cite the most precise available evidence. For code claims, prefer repository → file → symbol → commit/PR provenance where available.

#### F-014 Claim verification

Before final response, extract factual candidate claims from the draft, map them to evidence, validate support/entailment, and remove or downgrade unsupported statements.

#### F-015 Skill Evidence Engine

A skill page/report must show evidence categories and transparent dimensions such as breadth, depth, recency, project diversity, code evidence, architecture evidence, test evidence, and production/deployment evidence. Scores must be derived from documented formulas/signals and never invented.

#### F-016 Job Description Intelligence

Recruiter can paste a job description. Extract responsibilities, required/preferred skills, seniority, domain, leadership, architecture, AI, cloud, security, and other expectations. Build a requirement-to-evidence matrix with strong/moderate/weak/gap states.

#### F-017 Evidence-weighted role match

Produce a transparent role-fit score whose weighting is driven primarily by requirement importance and evidence quality rather than keyword overlap. Surface gaps and recommended interview questions.

#### F-018 Audience-aware explanations

Support recruiter, engineering-manager, and principal-engineer explanation depths while keeping factual content consistent.

#### F-019 Project explorer

Each featured project includes problem, outcome, architecture, stack, AI concepts, engineering challenges, decisions/tradeoffs, evidence, code, real metrics where verified, lessons, and improvements.

#### F-020 Code intelligence

Support symbol extraction, language detection, dependency relationships, semantic code search, and code explanation tied to project context.

#### F-021 GitHub forensics

Expose repository evolution, important commits/PRs, tests, deployment artifacts, and architecture changes without overstating authorship.

#### F-022 MCP gateway

Implement MCP as a first-class capability boundary. At minimum, expose a real GitHub/career evidence tool surface through MCP or a standards-compatible MCP server/client path. Tools must publish schemas, side-effect classification, permission requirements, and errors.

#### F-023 MCP capability discovery

For workflows where multiple capabilities exist, allow the orchestrator to discover/select applicable MCP tools rather than hardcoding every integration in one prompt.

#### F-024 Specialized agent architecture

Use multiple agents only where missions, tools, permissions, failure modes, or evals materially differ. Required conceptual responsibilities include orchestration, career evidence retrieval, GitHub/code analysis, graph reasoning, job-match analysis, technical interview behavior, criticism/verification, and citation validation; these may be combined if empirical simplicity is better.

#### F-025 AI Inspector

Expose safe execution metadata:

- normalized query
- classified intent
- retrieval strategies
- candidate/result counts
- reranking stages
- evidence selected
- graph paths
- MCP/tools invoked
- model/prompt/schema versions
- citation coverage
- evidence confidence
- latency
- token/cost metrics where available
- errors/fallbacks

Never expose private chain-of-thought.

#### F-026 Applied AI Lab

Provide interactive demonstrations of dense vs sparse vs hybrid retrieval, reranking, chunking, graph retrieval, context selection, tool traces, and evaluation outcomes using real/public candidate evidence or safe fixtures.

#### F-027 Evaluation platform

Evaluate retrieval and generation independently. Required metrics/tests include Recall@K, Precision@K, MRR, nDCG or justified equivalents; faithfulness/groundedness; citation correctness; answer relevance/completeness; skill verification; job-match benchmarks; adversarial hallucination cases; missing evidence; prompt injection; tool misuse; malformed outputs; provider failures; latency; cost; and regressions.

#### F-028 Observability

Trace recruiter request → routing → retrieval → tools → model → verification → response with correlation IDs. Capture operational metrics without leaking sensitive content.

#### F-029 Security

Implement input validation, public rate limits, authenticated admin paths, access controls, secret management, audit logs, prompt-injection defenses, tool permissions, content trust boundaries, and safe rendering of retrieved content.

#### F-030 Admin evidence curation

Authenticated candidate/admin can inspect ingested sources, evidence, conflicts, visibility, verification status, ingestion freshness, and reindex state.

#### F-031 Production delivery

Provide reproducible local/test/staging/production configuration, CI/CD, migrations, monitoring, rollback/forward-fix guidance, smoke tests, and documented limitations.

### P1 — Important if feasible within V1

- Shareable candidate intelligence / role-fit reports
- Event-driven GitHub reindex on webhook
- Retrieval/model caching with correct invalidation
- Recruiter session continuation without mandatory signup
- Architecture diagrams generated from verified project metadata
- Historical skill/evidence timeline

### P2 — Post-V1

- Additional private connectors such as Drive/Notion
- Learned reranker trained on interaction labels
- Multi-candidate / SaaS platform mode
- Voice/avatar representation
- Autonomous application workflows

## Non-goals

- Generic unrestricted assistant behavior
- Fake metrics or career achievements
- Private chain-of-thought exposure
- Autonomous writes to GitHub, email, calendars, or recruiting systems from public recruiter mode
- Infrastructure complexity added solely to signal seniority
- Replacing deterministic authorization/verification with LLM judgment

## Product acceptance criteria

The product is acceptable only when all of the following are true:

1. A first-time recruiter can understand the candidate and ask a meaningful question without training.
2. Important candidate claims in recruiter answers have inspectable evidence or explicit uncertainty labels.
3. The system correctly refuses at least a representative adversarial set of fabricated-history questions.
4. A job description produces a requirement-by-requirement evidence matrix with visible gaps.
5. A code/skill question can resolve to specific repository/file/symbol/commit evidence when that evidence exists.
6. Hybrid retrieval and reranking are implemented and evaluated against a baseline rather than asserted.
7. Graph retrieval is used for at least one class of questions where it measurably improves evidence discovery.
8. MCP tooling is real, schema-bound, permissioned, observable, and demonstrated in the product.
9. AI Inspector exposes safe execution/evidence metadata without chain-of-thought.
10. Applied AI Lab exposes at least four real comparative demos backed by measured outputs.
11. Retrieval and generation have repeatable eval suites and regression gates.
12. Prompt injection and malicious retrieved-content tests pass the agreed security threshold.
13. Public recruiter mode has no unauthorized side-effect capability.
14. Candidate/admin can control evidence visibility and inspect conflicts/freshness.
15. Critical user flows meet agreed accessibility and responsive-design requirements.
16. Production deployment, smoke verification, observability, and rollback readiness pass the factory release gate.
17. Independent QA has no unresolved P0 findings and independent audit meets the factory pass policy.

## North-star experience

A sophisticated recruiter should be able to ask:

> Why should we consider Chimdindu for a Senior Applied AI Engineer role?

and receive an answer that is concise enough to scan but rich enough to inspect, with direct evidence for projects, code, architecture, advanced RAG, agents/MCP, production engineering, and genuine gaps. They can then open **View AI Execution** and see the evidence/retrieval/tooling pipeline that produced the answer.

The desired reaction is not "nice portfolio." It is:

> This candidate built a production-style AI system that proves he understands the exact engineering concepts he is claiming.
