# Active Execution Plan — Career Twin V1

## Outcome

Build and release a production-grade recruiter-facing AI Digital Twin of Chimdindu that proves candidate skills through verifiable evidence and visibly demonstrates advanced Applied AI engineering: adaptive RAG, hybrid retrieval, GraphRAG, MCP, context engineering, tool/agent orchestration, evaluations, observability, and security.

## Scope and non-goals

- Scope: the complete V1 defined in `docs/PRODUCT.md`, including recruiter UX, Career Truth Layer, GitHub/code ingestion, adaptive RAG, graph retrieval, citations/verification, skill evidence, job-fit intelligence, MCP, AI Inspector, Applied AI Lab, evals, admin curation, security, observability, deployment, QA, and audit.
- Non-goals: fabricated evidence, public write tools, unrestricted autonomous agents, multi-candidate SaaS, voice/avatar features, autonomous job applications.

## Delivery strategy

Build vertical slices that are demonstrable and evaluable. Do not build all infrastructure first. Every AI capability must have a deterministic contract, an observable execution path, and an evaluation before it is considered complete.

The first end-to-end slice is:

`recruiter question -> verified structured career facts -> retrieval -> answer -> citation -> AI Inspector trace`

Then progressively add GitHub/code evidence, hybrid/reranked retrieval, graph retrieval, job matching, MCP, and advanced lab/eval experiences.

## Milestones

| Milestone | Owner | Exit evidence | Status |
|---|---|---|---|
| Context bootstrap | Digital Twin | `docs/PROJECT_CONTEXT.md`, authorization/environment metadata | complete |
| Product Ready | Product Designer | `docs/PRODUCT.md`, `docs/UX_SPEC.md`, `docs/DESIGN_SYSTEM.md` | active |
| Architecture Ready | Project Designer | `docs/ARCHITECTURE.md`, `docs/API_CONTRACTS.md`, `docs/DATA_MODEL.md`, `docs/SECURITY.md`, `docs/TEST_STRATEGY.md` | pending |
| AI Architecture Ready | Applied AI + Context Engineer | `docs/AI_SYSTEM.md`, `docs/CONTEXT_ARCHITECTURE.md`, `docs/PROMPT_REGISTRY.md`, eval plan | pending |
| Implementation Ready | Project Designer | Stable contracts + work-package verification commands | pending |
| Core Recruiter Slice | Full-stack + AI + Data | End-to-end grounded recruiter question with citations and trace | pending |
| Evidence Intelligence | Data + Backend + AI | GitHub/code ingestion, truth layer, code evidence, retrieval | pending |
| Advanced Retrieval | Applied AI | hybrid search, reranking, parent/child, query routing/decomposition | pending |
| Graph Intelligence | Data + AI | knowledge graph, entity resolution, graph retrieval/GraphRAG | pending |
| MCP + Agent Intelligence | Applied AI + Backend | real MCP capability surface, safe tool discovery/orchestration | pending |
| Job Intelligence | AI + Backend + Frontend | JD parsing, requirement/evidence matrix, transparent match | pending |
| AI Inspector + Lab | Frontend + AI | visible execution trace + comparative AI demos | pending |
| Production Hardening | DevOps + all specialists | security, observability, resilience, CI/CD, migrations | pending |
| Verification Ready | Engineering specialists | tests/evals/security checks meet thresholds | pending |
| QA Passed | Senior QA | QA report + requirements traceability | pending |
| Audit Passed | Software Auditor | production audit PASS/conditional approval | pending |
| Production Release | DevOps + Auditor | deployed smoke, rollback check, release readiness | pending |

## Dependency graph

```text
WP-001 Context bootstrap
   -> WP-010 Product/UX/design
      -> WP-020 Architecture/contracts
         -> WP-021 AI/context architecture
            -> WP-030 Core data + truth layer
            -> WP-031 Recruiter frontend shell
            -> WP-032 Backend/API foundation
               -> WP-040 Baseline grounded RAG slice
                  -> WP-050 GitHub/code ingestion
                  -> WP-060 Advanced hybrid retrieval + reranking
                  -> WP-070 Knowledge graph + GraphRAG
                  -> WP-080 Skill evidence engine
                  -> WP-090 Job intelligence
                  -> WP-100 MCP gateway + tool discovery
                  -> WP-110 Specialized agent orchestration
                     -> WP-120 AI Inspector
                     -> WP-130 Applied AI Lab
                        -> WP-140 Security/observability/resilience
                           -> WP-150 Full eval/regression gate
                              -> WP-160 Independent QA
                                 -> WP-170 Independent audit
                                    -> WP-180 Production release
```

Parallel work is allowed only after shared data/API/AI contracts stabilize. Frontend mock implementation may proceed against typed fixtures, but production-path placeholders must be removed before feature-complete.

## Work packages

| ID | Outcome | Owner | Dependencies | Acceptance criteria | Verification | Status |
|---|---|---|---|---|---|---|
| WP-001 | Complete authoritative project context | Digital Twin | none | product identity, scope, authorization, non-goals, open decisions recorded | repository review | complete |
| WP-010 | Define recruiter journeys and premium interaction/design system | Product Designer | WP-001 | UX covers 5-minute recruiter journey, evidence inspection, JD analysis, project/code exploration, mobile/accessibility | design artifact review + requirement mapping | active |
| WP-020 | Define production architecture and system boundaries | Project Designer | WP-010 | component responsibilities, failure boundaries, deployment topology, contracts, data ownership, security model, tech tradeoffs documented | architecture review against requirements | pending |
| WP-021 | Define AI/context architecture | Applied AI + Context Engineer | WP-020 | AI/deterministic boundaries, corpus/chunking/retrieval/rerank/graph/tool/agent/eval/prompt architecture versioned | design review + eval plan | pending |
| WP-030 | Implement Career Truth Layer and provenance schema | Database Specialist + Backend | WP-020 | claims/evidence/sources/entities/visibility/status/conflicts/freshness modeled with migrations/tests | migration + unit/integration tests | pending |
| WP-031 | Build recruiter-facing application shell and navigation | Frontend Engineer | WP-010, WP-020 | landing, ask, evidence drawer, project explorer, job-fit entry, inspector/lab routes responsive and accessible | component/e2e accessibility checks | pending |
| WP-032 | Build API/auth/job/runtime foundations | Backend Engineer | WP-020 | validated API contracts, admin auth boundary, public read/session boundary, background job substrate, rate-limit hooks | API/integration tests | pending |
| WP-040 | Deliver baseline grounded recruiter QA slice | Applied AI + Backend + Frontend | WP-021, WP-030, WP-031, WP-032 | real evidence retrieval, answer generation, claim verification, citations, confidence, safe missing-evidence behavior | golden QA/eval set + e2e flow | pending |
| WP-050 | Ingest GitHub and build code intelligence | Backend + Data + AI | WP-030, WP-032 | authorized repos, docs/code/symbols/commits/PR metadata normalized; source-aware chunking and provenance work | fixture + live-repo ingestion tests | pending |
| WP-060 | Implement adaptive hybrid retrieval and reranking | Applied AI | WP-040, WP-050 | dense+sparse+metadata+structured/code retrieval, fusion, reranking, diversity/context budget; beats baseline on agreed retrieval metrics | Recall@K/MRR/nDCG evaluation | pending |
| WP-070 | Implement career knowledge graph and GraphRAG | Database Specialist + Applied AI | WP-030, WP-050 | typed graph, entity resolution, graph retrieval, graph path evidence, measurable use case benefit | graph tests + comparative eval | pending |
| WP-080 | Build Skill Evidence Engine | AI + Backend + Frontend | WP-060, WP-070 | transparent evidence dimensions, drill-down, no fabricated metrics, score formulas documented | labeled skill benchmark + UI e2e | pending |
| WP-090 | Build Job Description Intelligence | AI + Backend + Frontend | WP-060, WP-080 | requirement extraction, importance, requirement/evidence matrix, gap handling, transparent match and interview questions | labeled JD benchmark + e2e | pending |
| WP-100 | Build MCP gateway and at least one real MCP integration | Applied AI + Backend | WP-021, WP-032, WP-050 | schema-bound tools, permissions/side effects, errors, capability discovery/selection, observable calls | MCP protocol/integration tests + adversarial tool tests | pending |
| WP-110 | Add specialized agent orchestration only where justified | Applied AI | WP-060, WP-070, WP-090, WP-100 | missions/tool allowlists/schemas/failures/evals versioned; no unnecessary agent fan-out | agent eval suite + latency/cost comparison | pending |
| WP-120 | Ship AI Inspector | Frontend + Applied AI | WP-060, WP-070, WP-100 | intent/retrieval/rerank/evidence/graph/tool/model/prompt/citation/latency/cost trace shown without chain-of-thought | e2e + privacy/security tests | pending |
| WP-130 | Ship Applied AI Lab | Frontend + Applied AI | WP-120 | at least four real comparisons: dense vs sparse vs hybrid; pre/post rerank; chunking; graph/context/tool/eval demo | lab benchmark snapshot + e2e | pending |
| WP-140 | Production hardening | DevOps + Backend + Frontend + AI | core features | CI/CD, IaC/config, observability, alerts, secret references, timeouts/retries, caching, prompt-injection defenses, abuse limits, backup/restore where applicable | CI + security + resilience + staging smoke | pending |
| WP-150 | Full verification gate | Engineering specialists | WP-140 | behavior, retrieval, generation, citations, adversarial, permissions, provider-failure, latency/cost, accessibility regressions pass thresholds | automated test/eval reports | pending |
| WP-160 | Independent QA | Senior QA | WP-150 | complete requirement traceability, exploratory/e2e/negative/accessibility testing, no unresolved P0 | QA report | pending |
| WP-170 | Independent production audit | Software Auditor | WP-160 | architecture/security/reliability/data/AI/deployment claims audited, blockers remediated or accepted per policy | production audit report | pending |
| WP-180 | Production release | DevOps + Software Auditor | WP-170 | reproducible migration/deploy, externally verified smoke, monitoring, rollback/forward-fix readiness | release readiness evidence | pending |

## Verification standards

Before architecture chooses exact commands, every work package must eventually supply executable verification. Minimum categories:

- static/type/lint checks
- unit tests
- integration tests
- end-to-end tests
- migration tests
- retrieval evals
- generation/citation evals
- agent/tool/MCP evals
- adversarial prompt-injection/tool-abuse cases
- authorization/permission tests
- provider/network failure tests
- latency/cost budgets
- accessibility checks
- staging deployment smoke tests

## Release gates

See `protocols/RELEASE_GATES.md` and `factory.yaml`. No role may self-approve a gate reserved for independent QA or audit.

## Immediate next actions

1. Product Designer completes `docs/UX_SPEC.md` and `docs/DESIGN_SYSTEM.md` using `docs/PRODUCT.md` as canonical product truth.
2. Project Designer defines architecture/contracts/data/security/test strategy after Product Ready artifacts stabilize.
3. Applied AI and Context/Prompt Engineers then define the AI system, prompt/context registry, retrieval architecture, MCP boundaries, agent contracts, and eval thresholds before implementation fan-out.
4. Begin WP-030/031/032 in parallel only after interfaces are stable.
