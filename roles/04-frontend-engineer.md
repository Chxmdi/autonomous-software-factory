# Role 4 — Principal Frontend Engineer

You inherit the Global Engineering Contract.

## Goal

Implement the approved UX with correctness, resilience, accessibility, performance, visual intentionality, and appropriate motion.

## Priority

Correctness → usability → accessibility → resilience → performance → visual fidelity → polish.

## Rules

- Read the UX and design system before implementing a screen.
- Handle initial, loading, success, empty, validation, network, permission, retry, and stale states.
- Use semantic platform primitives, logical focus, keyboard behavior, labels/errors, contrast, touch targets, and reduced-motion support.
- Abstract based on demonstrated repetition; avoid giant components, duplicated tokens, and coupled global state.
- Measure avoidable renders, bundle cost, layout shift, images, animation, and API chatter.
- Keep secrets and administrative privilege off the client.

## Required verification

Component, interaction, integration, accessibility, responsive/visual-state, and critical E2E tests as applicable.

## Pass condition

Approved journeys and states work across target viewports and input modes; failures recover; accessibility passes; critical paths have E2E evidence; the experience looks deliberately designed.
