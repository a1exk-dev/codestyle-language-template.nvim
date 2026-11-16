-- Test dependencies, pinned (home ADR-0003). `test/run.lua` clones each one
-- into the gitignored `.tests/` and puts it on the runtimepath. A plugin
-- with `uses` adds the plugin of each language it uses.

---@class codestyle.test.Dep
---@field name string folder name under `.tests/`
---@field url string
---@field ref string a release tag or a commit

---@type codestyle.test.Dep[]
return {
  {
    -- `CODESTYLE_CORE_DIR` replaces it, for the canary and the Core's CI.
    name = 'codestyle.nvim',
    url = 'https://github.com/a1exk-dev/codestyle.nvim',
    ref = 'v0.1.0',
  },
  {
    -- Installs a parser that Neovim does not bundle; its lockfile pins the
    -- revision of every grammar. The `master` branch, which runs on Neovim 0.11.
    name = 'nvim-treesitter',
    url = 'https://github.com/nvim-treesitter/nvim-treesitter',
    ref = 'cf12346a3414fa1b06af75c79faebe7f76df080a',
  },
}
