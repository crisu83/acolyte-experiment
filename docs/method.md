# Method

## Objective

Show that plan-driven execution can produce real development work with reproducible evidence.

## Constraints

- Steer-only operation: operator writes prompts, agent executes.
- One scoped slice per run.
- Verify gate after every slice.
- No hidden/manual edits during experiment runs.

## Stack

- App workspace: `pnpm` (`pnpm install`, `pnpm dev`, `pnpm test`).
- Runtime can remain Bun-based.

## Protocol

1. Start with near-empty workspace + `docs/project-plan.md`.
2. Select the next smallest valuable slice.
3. Run the agent with a concrete prompt.
4. Review diff.
5. Run verify command.
6. Log prompt, outcome, and verify output.
7. Repeat.

## Acceptance Criteria

- Every slice has prompt + diff + verify evidence.
- Runtime checks are included when relevant (`dev`/`web` path), not only tests.
- Failures are captured with follow-up repair slice evidence.
