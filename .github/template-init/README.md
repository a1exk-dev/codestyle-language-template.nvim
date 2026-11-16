# codestyle-tsquery.nvim

The Tree-sitter query Language Plugin of [codestyle.nvim](https://github.com/a1exk-dev/codestyle.nvim), the Core. It gives the Core Tree-sitter query: its Options, its Tabs in the Menu, the PhpStorm fields that a Scheme XML import reads, and its formatting rules.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'a1exk-dev/codestyle-tsquery.nvim',
  dependencies = { 'a1exk-dev/codestyle.nvim' },
}
```

With no `version`, you get the latest release. Set it up and use it as `:help codestyle` says.

## Pin a version

To stay on a range of releases, add a `version` to the spec. With lazy.nvim, `version = '^0.5'` keeps you on 0.5.x, and `version = '1.*'` on 1.x. With `vim.pack`, use `version = vim.version.range('1.*')`.

