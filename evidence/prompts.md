# Prompt Ledger

## Format

- `id`: stable run id
- `goal`: intended outcome
- `prompt`: exact steering prompt
- `result`: pass/fail/partial
- `notes`: key issue or insight

Canonical slice prompts used by the runner are stored in `evidence/prompts.json`.

## Seeded From Playground (2026-03-06)

### exp_seed_001
- goal: Extend task model with priority/labels/dueDate end-to-end.
- prompt: broad full-slice implementation prompt.
- result: partial.
- notes: broad scope increased stalls and partial propagation.

### exp_seed_002
- goal: Repair fixture/type drift after schema change.
- prompt: file-constrained repair for failing test files.
- result: pass.
- notes: tight file scope + unchanged behavior requirement worked well.

### exp_seed_003
- goal: Web runtime parity after tests passed.
- prompt: normalize API payload at web boundary; keep renderer strict.
- result: pass.
- notes: fixed runtime crash not caught by initial tests.

## Reusable Prompt Pattern

"Fix exactly this failing behavior. Edit only these files: <list>. Keep behavior unchanged outside scope. End by running <verify> and <runtime command>."

## Experiment Prompts

See `evidence/prompts.json`.
