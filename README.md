# Acolyte Experiment

Reproducible experiment for demonstrating plan-driven execution with [Acolyte](https://acolyte.sh).

This repo captures a reproducible workflow: start from a minimal plan, execute scoped slices, verify each step, and keep evidence.

## Contents

- [AGENTS.md](./AGENTS.md) repository execution conventions for experiment runs
- [docs/index.md](./docs/index.md) canonical documentation index
- [evidence/prompts.md](./evidence/prompts.md) prompt ledger and run mapping
- [evidence/verify.md](./evidence/verify.md) verification log ledger
- [evidence/runs.md](./evidence/runs.md) run branch and baseline ledger

## Usage

Canonical replay steps live in [docs/reproduce.md](./docs/reproduce.md).

Minimal quickstart:

```bash
cp .env.example .env
# set OPENAI_API_KEY in .env
set -a && source .env && set +a
scripts/run-experiment.sh 001 main gpt-5.2
```
