# Reproduce

## 1) Prepare

```bash
cd ~/code/acolyte-experiment
pnpm install
cp .env.example .env
# set OPENAI_API_KEY in .env
set -a && source .env && set +a
```

## 2) Run live protocol

```bash
scripts/run-experiment.sh 001 main gpt-5.2
pnpm dev
pnpm test
bash scripts/reset-experiment.sh main
```

Run from plan. `run-experiment.sh` logs baseline/model/acolyte version in `evidence/runs.md`, and logs slice commit hashes in `evidence/verify.md`.

## 3) Evidence checks

- Prompt ledger: `evidence/prompts.md`
- Verify ledger: `evidence/verify.md`
- Result summary: `docs/results.md`

## 4) Minimal success bar

- At least one full slice completed with passing verify.
- Evidence updated for that slice.
