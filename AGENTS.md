# Language Plugin

A Language Plugin of [codestyle.nvim](https://github.com/a1exk-dev/codestyle.nvim), the Core. The skills, the process policies (commits, branches and versions, changelog, issues), and the decisions that cover more than one repo live in [codestyle-home](https://github.com/a1exk-dev/codestyle-home). Follow its `AGENTS.md` for process.

This repo keeps a copy of the `git-commit`, `semver` and `common-changelog` skills in `.agents/skills/` and of their policies in `docs/agents/`, so that a session in this repo alone follows the same process ([home ADR-0006](https://github.com/a1exk-dev/codestyle-home/blob/main/docs/adr/0006-each-repo-keeps-a-copy-of-the-process-skills-and-policies.md)). The home is their source: change them there, not here.

## Knowledge

- Before you examine or change this repo, read `CONTRIBUTING.md`, the Core's `GLOSSARY.md` for the project terms, and the Core's contract in `lua/codestyle/types.lua`. Obey the Core ADRs and home ADR-0003 that `CONTRIBUTING.md` links, because each ADR records a decision that the code does not show.
- Never edit `test/corpus/` by hand: the Core dev script writes it.

## Release

This rule is for a Language Plugin. In the template repo, `codestyle-language-template.nvim`, skip it: the template is no Language Plugin.

After this plugin's first release on `main`, get it listed in awesome-neovim:

1. Open a home issue "List `<owner>/<repo>` in awesome-neovim" with `gh issue create -R a1exk-dev/codestyle-home --label ready-for-agent --label enhancement`.
2. In its body, tell the agent to:
   - follow the listing steps of [List the Core in awesome-neovim](https://github.com/a1exk-dev/codestyle-home/issues/68): the list's rules, one line, and the operator's approval of the text before the pull request. Skip its Core-only steps, the Core release with the demo GIF and the Core repo's age.
   - put the line in this language's subsection under "Programming Languages Support" when one exists, else in "Formatting".
   - open the pull request one week or more after the release.

## Checks

- Branch protection on `main` and `develop` requires five checks: the tests on Neovim 0.11.7 and stable, StyLua, and lua-language-server in `.github/workflows/ci.yml`, and `typos` in `.github/workflows/spelling.yml`. Before you add or remove a required check, ask the operator.
