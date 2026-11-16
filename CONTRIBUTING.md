# Contributing

This repo is a Language Plugin of [codestyle.nvim](https://github.com/a1exk-dev/codestyle.nvim), the Core. It started from the template [codestyle-language-template.nvim](https://github.com/a1exk-dev/codestyle-language-template.nvim) ([home ADR-0003](https://github.com/a1exk-dev/codestyle-home/blob/main/docs/adr/0003-plugins-start-from-a-template-repo-with-vendored-corpus-tests.md)). The Core's [GLOSSARY.md](https://github.com/a1exk-dev/codestyle.nvim/blob/main/GLOSSARY.md) defines the terms, and its [`lua/codestyle/types.lua`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua) holds the contract.

## Layout

- `lua/codestyle/languages/<id>.lua`: the spec. `lua/codestyle/languages/<id>/formatter.lua` and `scheme.lua`: the modules that the Core loads on first use ([Core ADR-0007](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0007-language-plugins-are-runtimepath-specs-with-lazy-lua-modules.md)).
- `test/cases/<name>/`: hand-written cases, each with `input.<ext>`, `output.<ext>`, a `codestyle.json` with the stored values of the language, and an optional `range` file with the first and last line to format.
- `test/corpus/`: the Behaviour Records of the language, an unchanged copy that the Core dev script writes. Never edit it by hand. Without records, it holds only `SOURCE`.
- `test/expected_failures.lua`: the cases that may fail, each with its reason.

## Checks

Run each check before you open a pull request:

```sh
nvim --headless -l test/run.lua
stylua --check .
typos
lua-language-server --check . --checklevel=Warning
```

`test/run.lua` clones the Core, nvim-treesitter and the plugins that the spec `uses` into `.tests/` at the refs of `test/deps.lua`, and installs each parser that Neovim lacks. An unexpected failure fails the run, and so does an unexpected pass, so the list of expected failures only shrinks. Run `nvim --headless -l test/run.lua --deps` before `lua-language-server`, which reads the contract from `.tests/codestyle.nvim`.

## Optional parts of the contract

The spec fills in the required fields of `codestyle.Spec`, the `scheme` module and its Options. Add an optional part when the language needs it:

- `match` ([`codestyle.Spec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0015](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0015-the-core-chooses-the-plugin-by-override-filetype-then-phpstorm-globs.md)): claims a buffer by PhpStorm's file name globs when no spec lists its filetype.
- More `parsers` keys ([`codestyle.Spec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0015](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0015-the-core-chooses-the-plugin-by-override-filetype-then-phpstorm-globs.md)): a parser per filetype, or for an Embed Point's `parser_key`.
- `uses` and `exports` ([`codestyle.Spec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0007](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0007-language-plugins-are-runtimepath-specs-with-lazy-lua-modules.md)): build on the handlers of another Language Plugin, or offer this plugin's handlers to others. Add each used plugin to `test/deps.lua`.
- `migrations` ([`codestyle.Migration`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0007](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0007-language-plugins-are-runtimepath-specs-with-lazy-lua-modules.md)): renames of Option keys and choice ids, once a release has shipped the old ones.
- `presets` ([`codestyle.Preset`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0006](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0006-presets-overwrite-draft-values-and-are-never-stored.md)): the "Set from…" list of the language, such as PSR-12.
- `tabs` and `syntax` ([`codestyle.Tab`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0007](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0007-language-plugins-are-runtimepath-specs-with-lazy-lua-modules.md)): the Menu's Tabs and Groups with their Preview samples, and the Vim syntax of the Preview when no parser is installed. Without `tabs`, the Menu shows one Tab with every Option.
- `keep_indents_on_empty_lines` and `on_marker_in_region` ([`codestyle.Spec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0018](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0018-general-holds-six-options-and-the-core-applies-markers-and-file-wide-rules.md)): the language's "Keep indents on empty lines" Option, and formatter markers whose on-marker line belongs to the region.
- `arrangement` and its module ([`codestyle.ArrangementSpec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0011](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0011-arrangement-is-core-engine-over-plugin-entries.md), [Core ADR-0012](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0012-menu-edits-arrangement-as-rows-with-a-rule-float.md)): the entries that PhpStorm's Arrangement rearranges, and the Menu's Arrangement Tab.
- Embed Points ([`codestyle.Block`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/block.lua), [Core ADR-0008](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0008-embedded-code-is-grafted-at-embed-points-the-host-declares.md)): Blocks where code of another language is grafted, such as JavaScript in HTML.
- Option fields `min`, `max`, `choices`, `item`, `requires` and `inherit` ([`codestyle.OptionSpec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0003](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0003-own-option-shape-and-keys.md), [Core ADR-0018](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0018-general-holds-six-options-and-the-core-applies-markers-and-file-wide-rules.md)): the bounds and choices of an Option, the Option it needs, and the `general` value it takes when none is stored.
- `flagged` ([`codestyle.OptionSpec`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [home ADR-0003](https://github.com/a1exk-dev/codestyle-home/blob/main/docs/adr/0003-plugins-start-from-a-template-repo-with-vendored-corpus-tests.md)): an Option that does not match all of its Behaviour Records. The Menu marks it, and the tests expect its records to fail.
- Formatter fields `before`, `after`, `indent_options`, `right_margin` and `override_indent_options` ([`codestyle.Formatter`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0002](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0002-pure-lua-engine-on-users-tree-sitter.md), [Core ADR-0008](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0008-embedded-code-is-grafted-at-embed-points-the-host-declares.md)): text steps around the engine, Indent sizes, the right margin, and the indent Options of embedded code.
- Formatter `format` ([`codestyle.Formatter`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0007](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0007-language-plugins-are-runtimepath-specs-with-lazy-lua-modules.md)): replaces the Core engine for a language that has no Blocks.
- `scheme` fields `element` and `left_out`, and joined `fields` ([`codestyle.Scheme`](https://github.com/a1exk-dev/codestyle.nvim/blob/main/lua/codestyle/types.lua), [Core ADR-0010](https://github.com/a1exk-dev/codestyle.nvim/blob/main/docs/adr/0010-scheme-xml-import-replaces-the-draft-through-core-resolved-field-addresses.md)): the language's own Scheme XML element, the fields that v1 leaves out, and one Option read from several fields.

## Process

Branches, commits, versions and the changelog follow the copies of the `git-commit`, `semver` and `common-changelog` skills in `.agents/skills/` and their policies in `docs/agents/`. Open each pull request into `develop`.
