<div align="center">

<img src="./assets/tits-hero.jpg" alt="Two tits perched on a log. Get your mind out of the gutter, Andy." width="720" />

# tits

**Bootstrap and doctor an Iris-first agent home.**

![tests: 15](https://img.shields.io/badge/tests-15-brightgreen?style=flat)
![lints: 17](https://img.shields.io/badge/lints-17-blue?style=flat)
![generator: agent homes](https://img.shields.io/badge/generator-agent%20homes-blue?style=flat)
![workflows: shimmer](https://img.shields.io/badge/workflows-shimmer-4a4a4a?style=flat)

</div>

<br />

## What it does

`tits` creates the smallest useful agent home: files, mise tasks, dependencies, and workflow plumbing for a new agent to orient locally and wake in CI.

It is deliberately narrower than `homes`: this is the Iris bootstrap/doctor slice, not the whole standard-home roadmap.

## Quick start

```bash
shiv install tits

tits init --agent iris --home ~/agents/iris/home
cd ~/agents/iris/home
mise welcome
tits doctor --home .
```

## Generated home surface

For a brand-new or no-commit home with a clean working tree, `init` creates the initial `bootstrap agent home` commit. Use `--no-commit` to leave files uncommitted.

- `README.tsx` / `README.md` — dynamic home README via KnickKnackLabs/readme
- `notes/status.md` — lowercase continuity note
- `mise run welcome` — session-start orientation
- `mise run self` — self-session placeholder
- `mise run agent:list` and `agent:identity` — shimmer wake contract
- `mise run agent:prepare` — idempotent CI preparation hook
- `shimmer workflows:generate` output — workflow YAML remains owned by shimmer templates

## Dependencies

`tits` depends on `shimmer` today because shimmer owns workflow generation. When that surface moves into `homes`, this generator should depend on homes instead.

Generated homes declare the runtime tools their CI/local surface expects, including `shimmer`, `sessions`, `secrets`, `emails`, `rudi`, `notes`, `modules`, `codebase`, and `readme`.

## Non-goals for the first pass

No inbox, dashboards, public status extraction, multi-agent discovery, migrations, Obsidian orchestration, or queue tooling. Those belong in `homes` or later layers.

## Development

```bash
mise trust
mise install
mise run test
readme build
codebase lint "$PWD"
readme build --check

git diff --check
```
