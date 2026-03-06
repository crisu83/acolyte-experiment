# Project Plan

## Goal

Demonstrate reproducible plan-driven execution in a `pnpm` web workspace.

## Project Scope

Build a minimal full-stack demo with:

- `apps/api`: TypeScript HTTP API.
- `apps/web`: React + Vite frontend with Tailwind CSS v4.
- Root `pnpm` workspace scripts for `dev`, `test`, and `verify`.

Feature target: task list with create + list flow.

## Slice 1

Scaffold workspace and baseline checks.

- Create `pnpm` workspace structure with `apps/api` and `apps/web`.
- Add minimal server/client bootstraps.
- Add baseline tests that pass.
- Add root verify command that runs formatting/lint/typecheck/test as available in workspace.

Acceptance Criteria:
- Root `pnpm` workspace config exists and includes `apps/api` + `apps/web`.
- Root scripts include `dev`, `test`, and `verify`.
- Workspace install succeeds.
- Verification is green.

## Slice 2

Implement first user-visible feature.

- Add API endpoint(s) for task list create + fetch.
- Add web UI to create a task and render the list.
- Style the web UI using Tailwind CSS v4 utility classes.
- Keep implementation intentionally small and local-memory based.

Acceptance Criteria:
- Feature works in runtime.
- Tailwind CSS v4 is configured and used in web UI.
- Verification stays green.

## Slice 3

Strengthen feature coverage.

- Add API tests for create/list behavior.
- Add web tests for create flow and rendered list.
- Fix only issues required for test reliability.

Acceptance Criteria:
- Feature-path tests pass.
- Verification stays green.

## Slice 4

Exercise failure and repair workflow.

- Introduce one controlled failure in the feature path.
- Capture failing verification evidence.
- Add repair change that restores green state.
- Commit failure and repair as separate slices.

Acceptance Criteria:
- Failure is reproducible and documented.
- Repair returns verification to green.

## Slice 5

Finalize evidence and summary.

- Update `evidence/prompts.md` with actual used prompts after first successful slice.
- Update `evidence/verify.md` with verify outputs per slice.
- Update `docs/results.md` with outcomes, defects, and learnings.

Acceptance Criteria:
- Evidence files align with git history.
- Result summary reflects actual run artifacts.
