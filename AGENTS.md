# Language Plugin

A Language Plugin of [codestyle.nvim](https://github.com/a1exk-dev/codestyle.nvim), the Core. The skills, the process policies (commits, branches and versions, changelog, issues), and the decisions that cover more than one repo live in [codestyle-home](https://github.com/a1exk-dev/codestyle-home). Follow its `AGENTS.md` for process.

This repo keeps a copy of the `git-commit`, `semver` and `common-changelog` skills in `.agents/skills/` and of their policies in `docs/agents/`, so that a session in this repo alone follows the same process ([home ADR-0006](https://github.com/a1exk-dev/codestyle-home/blob/main/docs/adr/0006-each-repo-keeps-a-copy-of-the-process-skills-and-policies.md)). The home is their source: change them there, not here.

## Knowledge

- Before you examine or change this repo, read `CONTRIBUTING.md`, the Core's `GLOSSARY.md` for the project terms, and the Core's contract in `lua/codestyle/types.lua`. Obey the Core ADRs and home ADR-0003 that `CONTRIBUTING.md` links, because each ADR records a decision that the code does not show.
- Never edit `test/corpus/` by hand: the Core dev script writes it.

## Checks

- Branch protection on `main` and `develop` requires five checks: the tests on Neovim 0.11.7 and stable, StyLua, and lua-language-server in `.github/workflows/ci.yml`, and `typos` in `.github/workflows/spelling.yml`. Before you add or remove a required check, ask the operator.
