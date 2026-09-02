# Design System — Career Twin

## Product identity

Career Twin should feel like a premium technical-intelligence product: precise, calm, evidence-heavy, modern, and credible. It should borrow the confidence of developer tools, observability platforms, and financial/research terminals without becoming visually cold or intimidating.

Avoid generic AI aesthetics: no purple-gradient hero, glowing orb, excessive glassmorphism, meaningless particle animation, oversized rounded cards everywhere, or chatbot-first visual language.

The interface should communicate three ideas visually:

1. **Proof** — evidence and provenance are always close to claims.
2. **Depth** — advanced technical information can be progressively revealed.
3. **Control** — the system is inspectable, bounded, and trustworthy.

## Visual direction

- Dense where information density creates value, spacious where reading and decision-making benefit.
- Strong typographic hierarchy over ornamental decoration.
- Neutral surfaces with one restrained accent family.
- Borders, rules, tags, timelines, code, graphs, and inspector panels feel deliberate and technical.
- Motion communicates state transitions and causality, never novelty.
- Confidence/status information uses text + icon + semantic color, never color alone.

## Tokens

### Typography

Use a modern high-legibility sans-serif family available through the chosen web stack/system; use a dedicated monospace family for code, evidence IDs, traces, and technical metadata.

Suggested scale:
- Display: clamp(2.5rem, 5vw, 5rem), tight tracking, 1.0–1.08 line-height
- H1: 2.25rem–3rem
- H2: 1.75rem–2.25rem
- H3: 1.25rem–1.5rem
- Body large: 1.125rem
- Body: 1rem
- Small/meta: 0.875rem
- Micro labels only where necessary: 0.75rem minimum

Body line-height: 1.5–1.7.

### Spacing

Base unit: 4px.

Core spacing scale:
`4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96`

Prefer 16–24px internal spacing for compact intelligence panels and 48–80px section rhythm for marketing/overview surfaces.

### Sizing / radius / elevation

- Control heights: 36 / 40 / 44 / 48px depending on density
- Minimum touch target: 44x44px where applicable
- Small radius: 6px
- Standard radius: 10px
- Large radius: 14px
- Avoid pill shapes except tags, segmented controls, and compact filters
- Elevation should be subtle; hierarchy should rely primarily on contrast, border, spacing, and layering
- Drawers/dialogs may use stronger elevation with backdrop

### Semantic colors and surfaces

Implement as semantic design tokens rather than hardcoded component colors.

Required token roles:
- canvas
- surface-1
- surface-2
- surface-elevated
- text-primary
- text-secondary
- text-muted
- border-subtle
- border-strong
- accent
- accent-hover
- accent-subtle
- success / success-subtle
- warning / warning-subtle
- danger / danger-subtle
- info / info-subtle
- focus-ring
- code-surface
- graph-edge
- graph-node-default

Verification status tokens:
- verified
- demonstrated
- self-reported
- inferred
- unverified
- conflicted

These statuses must remain distinguishable in both light and dark themes if both are implemented.

### Breakpoints

- xs: 0–479
- sm: 480–767
- md: 768–1023
- lg: 1024–1279
- xl: 1280–1535
- 2xl: 1536+

Use content-driven layout behavior rather than device assumptions.

## Layout system

### Public overview

Max content width approximately 1280–1440px with strong grid alignment. Hero should be concise, not full-screen decorative theater.

### Intelligence views

Allow multi-pane desktop layouts:
- primary content 55–70%
- evidence/inspector rail 30–45%

Panels should collapse to drawers/tabs on narrower widths.

### Reading views

Long-form project/architecture explanations should limit paragraph width for readability while allowing diagrams/code to break wider.

## Core components

### AppShell

Global nav, route context, responsive drawer, admin/public boundary.

### CandidateHero

Name/positioning, concise evidence-oriented introduction, primary ask/JD actions, high-confidence proof chips.

### AskComposer

Multiline prompt, suggested prompts, clear submit/stop/retry states, keyboard accessible.

### AnswerBlock

Direct answer, structured evidence bullets, nuance/gaps, citations, confidence summary, follow-up actions.

### CitationMarker / CitationPopover

Precise evidence source, source type, freshness, verification state, open-source action.

### EvidenceCard

Reusable proof surface for repository/file/symbol/commit/project/certification/resume evidence.

### VerificationBadge

Text + icon + semantic token. Never badge-only without accessible label.

### ConfidenceSummary

Human-readable confidence state; advanced numeric detail optional and inspectable.

### SkillEvidencePanel

Dimension rows, evidence categories, related projects, formulas/explanations.

### RequirementMatrix

Desktop table with sortable/filterable requirements; stacked cards on mobile. Every row can open evidence.

### ProjectCard / ProjectHeader

Problem, outcome, stack, evidence indicators, depth entry points.

### ArchitectureCanvas

Pan/zoom graph with keyboard/text alternative, node details, edge labels, focused traversal.

### GraphPath

Compact path representation such as `Project -> USES -> Technology -> DEMONSTRATES -> Skill`.

### InspectorTimeline

Displays safe request stages and durations without reasoning content.

### RetrievalComparison

Side-by-side ranked result sets with metrics and differences highlighted structurally.

### CodeEvidenceViewer

Repository/file breadcrumbs, line/symbol context, syntax highlighting, source link, provenance metadata.

### EmptyEvidenceState

Explicitly communicates no verified evidence and suggests safer next questions rather than filling space with generic copy.

### ErrorState

Distinguish provider outage, source unavailable, permission denied, rate limit, and malformed response.

### Skeleton / ProgressiveLoading

Show stable page geometry while retrieval/generation proceeds. Avoid fake progress percentages unless backed by deterministic progress.

## Motion

Motion principles:
- 120–180ms for small state changes
- 180–280ms for drawers/panels
- 250–400ms for larger route/layout transitions if needed
- standard ease-out for entering, ease-in for leaving
- animate opacity/transform rather than layout-heavy properties when possible

Use motion for:
- evidence drawer opening from citation
- inspector stage appearance after completion
- graph focus/selection
- result rerank movement in the Applied AI Lab
- route transitions that preserve spatial context

Do not:
- animate every card on scroll
- use infinite decorative motion
- animate confidence meters as theater
- make streaming text unreadably fast

Honor `prefers-reduced-motion` and provide equivalent state clarity without animation.

## Data visualization

Charts/graphs must answer a question, not decorate.

Rules:
- visible title/question
- units and scale when quantitative
- accessible textual summary
- hover/focus parity
- legends only when needed
- do not use radar charts for skill ratings by default because they imply false precision
- evidence dimensions should primarily use labeled bars/rows with inspectable formulas
- graph edges must have relationship labels or an accessible equivalent

## Code and technical metadata

Use monospace treatment for:
- repository paths
- symbols
- commit SHAs
- evidence IDs
- trace IDs
- MCP tool names
- model/prompt/schema versions

Technical metadata should be compact but selectable/copyable.

## Content design

Voice:
- concise
- specific
- non-hype
- evidence-oriented
- comfortable saying "limited evidence" or "unknown"

Prefer:
`Strong demonstrated evidence across 4 projects`

over:
`Expert-level mastery`

Prefer:
`No verified evidence found for Spark`

over:
`He may need to improve Spark`

## Accessibility

Target WCAG 2.2 AA.

Required:
- contrast-compliant semantic tokens
- keyboard-accessible navigation, dialogs, drawers, graphs, tabs, tables, and prompt controls
- visible focus ring independent of hover state
- no color-only status meaning
- 44px touch targets where practical
- semantic HTML first; ARIA only when needed
- streaming/status announcements designed for assistive tech without flooding announcements
- graphs/architecture diagrams include textual equivalent and list/table fallback
- reduced motion honored
- focus restored predictably after drawer/dialog close
- error text associated with inputs
- code viewer supports keyboard scrolling and copy without trapping focus

## Anti-patterns

Reject during design review:
- giant generic AI chat bubble as homepage
- star ratings for skills
- invented percentage confidence with no formula
- decorative architecture diagrams disconnected from actual implementation
- hidden evidence behind multiple menus
- hard-to-read glass surfaces
- low-contrast gray-on-gray technical text
- unclear distinction between verified evidence and model inference
- mobile layouts that simply shrink desktop tables
- animation that obscures provenance or changing ranks

## Design acceptance criteria

1. The interface reads as a technical intelligence product before the user interacts with AI.
2. Evidence actions are consistently discoverable beside claims.
3. Recruiter-readable content is the default; technical depth is one action away.
4. Status/confidence/verification never rely on color alone.
5. Desktop supports efficient multi-pane inspection; mobile preserves all critical capabilities.
6. Applied AI Lab comparisons are visually understandable and tied to real measured outputs.
7. AI Inspector clearly separates retrieval/tool execution metadata from hidden model reasoning.
8. The product avoids the listed generic AI visual anti-patterns.
9. Core flows meet WCAG 2.2 AA acceptance checks before release.
