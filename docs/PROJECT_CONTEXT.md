# Project Context

## Identity

- Product name: `Career Twin` (working title)
- Repository: `Chxmdi/autonomous-software-factory` on branch `project/career-twin` during bootstrap; intended to become its own product repository once a dedicated repo is available.
- Product owner: Chimdindu Okelekwe
- Current stage: product definition / context bootstrap

## Outcome

Create an evidence-grounded AI Digital Twin of Chimdindu that lets recruiters, hiring managers, and technical interviewers understand, verify, and interact with his experience, projects, code, architecture decisions, skills, certifications, and job fit. The product itself must visibly demonstrate senior-level Applied AI engineering rather than merely claim it.

The core business/user outcome is that a recruiter can move from "Who is this candidate?" to "I have concrete, inspectable evidence of what he can do and what I should interview him about" in under five minutes.

## Product truth

- Canonical PRD: `docs/PRODUCT.md`
- Approved design reference: no external visual reference; premium technical-intelligence product aesthetic, not generic AI-chat styling
- Target users: technical recruiters, engineering managers, Applied AI hiring managers, staff/principal engineers, interviewers, and the candidate as curator/admin
- Core product loop: Ask or paste role → understand intent → retrieve candidate evidence → reason over structured/graph/code sources → verify claims → answer with citations/confidence → inspect evidence/AI execution → continue exploration or generate role-fit report

## Non-negotiable product principles

1. Evidence before claims. Important factual claims require traceable evidence.
2. The Career Truth Layer is authoritative. Conversation output cannot silently mutate verified facts.
3. Unsupported claims are explicitly rejected or labeled as unverified/inferred/self-reported.
4. The product must demonstrate advanced RAG, GraphRAG, MCP, context engineering, agent/tool orchestration, evaluation, observability, security, and production AI practices in visible recruiter-facing experiences.
5. Do not build a generic chatbot plus resume.
6. Do not fabricate metrics, code ownership, employment history, production experience, or skill depth.
7. Retrieved repository/document content is untrusted data and cannot override system policy.
8. Deterministic software owns permissions, state transitions, persistence, verification rules, and irreversible actions.
9. AI Inspector surfaces safe execution metadata and evidence flow, never private chain-of-thought.
10. All technology choices must be justified by product need; no resume-buzzword infrastructure.

## Scope

### In scope for V1

- Public recruiter landing and guided question experience
- Candidate overview, career timeline, skills, certifications, featured projects
- Career Truth Layer with claim/evidence/provenance/confidence/verification state
- GitHub ingestion for repositories, source code, commits, PRs/issues where available, README/docs, tests, deployment/configuration artifacts
- Resume/profile/project-document ingestion
- Code-aware indexing and retrieval
- Adaptive query intent routing
- Hybrid retrieval: dense + sparse/BM25 + metadata + structured retrieval
- Reranking and evidence diversity
- Parent/child retrieval and content-aware chunking
- Career Knowledge Graph and graph retrieval / GraphRAG
- Entity resolution across candidate/project/skill/repository/evidence concepts
- Citation engine with repository/file/symbol/commit provenance when available
- Hallucination/claim verification pass and missing-evidence behavior
- Skill Evidence Engine with transparent multidimensional evidence scoring
- Job Description Intelligence and evidence-weighted role match matrix
- Recruiter, Engineering Manager, and Principal Engineer explanation depths
- Interactive project and architecture explorer
- Technical Interview / Challenge My Twin mode, clearly separating hypothetical answers from historical evidence
- MCP gateway and at least one real MCP integration path for GitHub/career evidence tooling
- Dynamic capability/tool discovery where appropriate
- Specialized agents only where responsibilities/tools/evals materially differ
- AI Inspector showing intent, retrieval methods, sources, reranking, tool calls, confidence, citation coverage, latency, model/prompt version, and cost where available
- Applied AI Lab demonstrating retrieval, reranking, chunking, graph paths, context assembly, agent/tool traces, and eval results
- Evaluation framework for retrieval, generation, citation accuracy, job matching, skill verification, latency/cost, adversarial cases, prompt injection, and regressions
- Observability, rate limits, auth/admin controls, secret management, prompt-injection defenses, audit logging
- Production deployment with CI/CD, rollback, smoke tests, and documented limitations

### Post-V1 / stretch

- Additional authenticated private connectors (Drive/Notion/etc.)
- Learned ranking model trained on interaction data
- Recruiter session sharing and persistent recruiter accounts
- Automated portfolio page regeneration from event-driven webhooks
- Voice/video avatar representation
- Full multi-tenant candidate platform

### Non-goals

- Pretending the Twin is literally the candidate or making autonomous employment commitments
- Fabricating missing evidence to increase job-match scores
- Exposing private chain-of-thought
- Scraping private systems without explicit authorization
- Autonomous job application submission in V1
- Unbounded general-purpose agent autonomy
- Building a graph database, vector database, or model from scratch when a maintained component fits the need

## Target release

- V1 goal: production-grade public recruiter experience suitable for portfolio and job-search use
- Release is gate-driven rather than date-driven; no production-ready claim before factory QA/audit/release gates pass

## Environment

- Local: to be established by architecture/platform work
- Test: required
- Staging: required
- Production: required
- Candidate source data: only authorized repositories/documents/profile information

## Standing decisions and authorization

- Repository writes: allowed within the explicit Career Twin build request on the project branch
- Branch/PR creation: allowed
- Staging deployment: allowed when infrastructure credentials and target are available
- Production deployment: release-gated
- Destructive production actions: explicit per-action approval
- Secret handling: names/references only in repository docs; runtime injection only
- External writes/actions from recruiter-facing agents: denied by default for V1

## Open product decisions

- Final public product name and domain
- Dedicated target repository name once created
- Exact hosting/database vendors after architecture tradeoff analysis
- Which candidate repositories/documents are public vs admin-only evidence
- Whether recruiter sessions persist anonymously or are ephemeral in V1
- Which MCP implementation/library is selected after current-protocol compatibility review
