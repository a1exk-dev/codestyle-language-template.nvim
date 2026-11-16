-- The one headless command that runs the tests of this Language Plugin
-- (home ADR-0003), locally and in CI:
--
--   nvim --headless -l test/run.lua
--
-- It clones the pinned dependencies of `test/deps.lua` into `.tests/`,
-- installs each parser of the specs that Neovim lacks, and runs the Core's
-- `codestyle.testing` over `test/corpus/` and `test/cases/`. The exit status
-- is non-zero when a result is unexpected.
--
--   nvim --headless -l test/run.lua --deps
--
-- only clones the dependencies, for example for `lua-language-server --check`.
-- When `CODESTYLE_CORE_DIR` names a Core folder, the run takes the Core from
-- there instead of its pinned tag (the canary, the Core's CI).

local root = vim.fs.normalize(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h'))
local core_dir = os.getenv('CODESTYLE_CORE_DIR')

---@param message string
local function fail(message)
  io.stderr:write(message .. '\n')
  os.exit(1)
end

---@param cmd string[]
---@return vim.SystemCompleted
local function git(cmd)
  return vim.system(vim.list_extend({ 'git' }, cmd), { text = true }):wait()
end

---@param cmd string[]
---@return string
local function must_git(cmd)
  local result = git(cmd)
  if result.code ~= 0 then
    fail(('git %s failed:\n%s'):format(table.concat(cmd, ' '), result.stderr))
  end
  return vim.trim(result.stdout)
end

--- The commit of a tag or commit in a clone, or nil when the clone lacks it.
---@param path string
---@param ref string
---@return string?
local function commit_of(path, ref)
  local result = git({ '-C', path, 'rev-parse', '--verify', '--quiet', ref .. '^{commit}' })
  return result.code == 0 and vim.trim(result.stdout) or nil
end

local dirs = {} ---@type string[]
for _, dep in ipairs(dofile(root .. '/test/deps.lua')) do
  local path = root .. '/.tests/' .. dep.name
  if dep.name == 'codestyle.nvim' and core_dir and core_dir ~= '' then
    path = vim.fs.normalize(core_dir)
  else
    if not vim.uv.fs_stat(path) then
      must_git({ 'clone', '--quiet', '--filter=blob:none', dep.url, path })
    end
    local wanted = commit_of(path, dep.ref)
    if wanted ~= must_git({ '-C', path, 'rev-parse', 'HEAD' }) then
      if not wanted then
        must_git({ '-C', path, 'fetch', '--quiet', 'origin', dep.ref })
      end
      must_git({ '-C', path, 'checkout', '--quiet', '--detach', wanted or 'FETCH_HEAD' })
    end
  end
  table.insert(dirs, path)
end

if _G.arg[1] == '--deps' then
  return
end

-- Not the developer's own setup: their config, plugins and parsers leave the runtimepath.
local own = { vim.fn.stdpath('config'), vim.fn.stdpath('data') } ---@type string[]
local kept = vim.tbl_filter(function(dir)
  dir = vim.fs.normalize(dir)
  return not vim.iter(own):any(function(prefix)
    return dir == prefix or vim.startswith(dir, prefix .. '/')
  end)
end, vim.split(vim.o.runtimepath, ',', { plain = true }))
vim.o.runtimepath = table.concat(kept, ',')

local parsers_dir = root .. '/.tests/parsers'
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(parsers_dir)
for _, dir in ipairs(dirs) do
  vim.opt.runtimepath:append(dir)
end
vim.o.swapfile = false
vim.o.shadafile = 'NONE'

-- This plugin's spec is the one file of `lua/codestyle/languages/`.
local specs = vim.fn.globpath(root, 'lua/codestyle/languages/*.lua', false, true)
if #specs ~= 1 then
  fail(('lua/codestyle/languages/ must hold one spec file, not %d'):format(#specs))
end
local language = vim.fn.fnamemodify(specs[1], ':t:r')

-- Each list of parsers names alternatives: when Neovim has none of them,
-- nvim-treesitter installs the first. The specs of the `uses` plugins count too.
local missing = {} ---@type string[]
for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/codestyle/languages/*.lua', true)) do
  local ok, spec = pcall(dofile, path)
  if ok and type(spec) == 'table' and type(spec.parsers) == 'table' then
    for _, names in pairs(spec.parsers) do
      local found = vim.iter(names):any(function(name)
        return vim.treesitter.language.add(name) ~= nil
      end)
      if not found and names[1] and not vim.list_contains(missing, names[1]) then
        table.insert(missing, names[1])
      end
    end
  end
end
if #missing > 0 then
  require('nvim-treesitter.configs').setup({ parser_install_dir = parsers_dir })
  require('nvim-treesitter.install').ensure_installed_sync(missing)
  io.stdout:write('\n')
end

require('codestyle.testing').main({
  language = language,
  corpus_dir = root .. '/test/corpus',
  cases_dir = root .. '/test/cases',
  expected_failures = dofile(root .. '/test/expected_failures.lua'),
})
