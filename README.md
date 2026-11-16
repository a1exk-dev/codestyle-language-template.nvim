# codestyle-language-template.nvim

The template of a Language Plugin for [codestyle.nvim](https://github.com/a1exk-dev/codestyle.nvim). A Language Plugin gives the Core one language: its Options, its Tabs in the Menu, the PhpStorm fields that a Scheme XML import reads, and its formatting rules.

The template is itself a working plugin, for Tree-sitter query files on Neovim's bundled `query` parser, with one sample Option, `spaces.after_colon`. Its CI tests that plugin, so the template keeps working between plugin launches.

## Start a Language Plugin

1. Click **Use this template** and name the new repo `codestyle-<id>.nvim`, where `<id>` is the language id: lowercase letters, digits and `_`, starting with a letter.
2. Clone the new repo and run, in its folder:

   ```sh
   nvim -l scripts/init.lua <id> <Name>
   ```

   For example `nvim -l scripts/init.lua php PHP`. It replaces the id and the name of the sample plugin with yours, renames its files, writes the `LICENSE` line from `git config user.name` and the year, puts the plugin's own `README.md` and `CHANGELOG.md` in place, and deletes the template-only files and itself. It commits nothing: review the changes, then commit them.
3. Set the filetypes and parsers in `lua/codestyle/languages/<id>.lua`, then replace the sample Option, its rule in `<id>/formatter.lua`, its entry in `<id>/scheme.lua` and its case in `test/cases/` with your language's.
4. Run the tests with `nvim --headless -l test/run.lua`. `CONTRIBUTING.md` lists the other checks and the optional parts of the contract.

## What the template holds

- The spec, formatter and scheme modules of the sample plugin, with the required fields of the contract.
- The test runner `test/run.lua`, which runs the Core's `codestyle.testing` over `test/corpus/` and `test/cases/`, with the dependencies that `test/deps.lua` pins.
- The CI of the Core: the tests on Neovim 0.11, stable and nightly, StyLua, lua-language-server and typos, a weekly canary against the Core's `develop`, and the Auto-merge workflow.
- The process skills `git-commit`, `semver` and `common-changelog` with their policies, as each codestyle repo keeps them.

The decisions behind the template are in [home ADR-0003](https://github.com/a1exk-dev/codestyle-home/blob/main/docs/adr/0003-plugins-start-from-a-template-repo-with-vendored-corpus-tests.md).

## License

[MIT](LICENSE)
