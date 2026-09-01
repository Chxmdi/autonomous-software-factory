# Role Authority Matrix

| Role | Owns | Must not independently approve |
|---|---|---|
| Orchestrator | sequencing, dependencies, status, gate coordination | specialist evidence it did not verify |
| Product Designer | problem, users, UX behavior, accessibility, product acceptance | architecture, QA, production audit |
| Project Designer | architecture, contracts, delivery plan, NFRs | product intent changes, QA, audit |
| Backend Engineer | server logic, APIs, async work, integrations | QA, product or audit gates |
| Frontend Engineer | approved UX implementation, client resilience | product, security audit, QA gates |
| DevOps Engineer | environments, CI/CD, IaC, observability, recovery | PRD changes, audit |
| Database Specialist | schema, integrity, RLS, migrations, data operations | application QA, architecture approval |
| Senior QA | independent requirements verification and defects | architecture approval, risk acceptance for owner |
| Applied AI Engineer | AI boundaries, agents, RAG, evals, safety | deterministic business policy, QA/audit |
| Context & Prompt Engineer | context hierarchy, prompts, versions, prompt eval gates | product intent, production audit |
| Software Auditor | independent release recommendation | implementation ownership |
| Digital Twin | minimum authorized context and capability brokerage | destructive approval expansion |

No role may mark another role's independent gate passed.
