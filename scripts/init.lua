-- Turns a repo made from the template into a Language Plugin (home ADR-0003).
-- Run it once, in the new repo's folder:
--
--   nvim -l scripts/init.lua <id> <Name>
--
-- It replaces the literal text of the template's own plugin, in each file
-- that Git does not ignore, except the boilerplate files:
-- `a1exk-dev/codestyle-tsquery.nvim` with `<owner>/codestyle-<id>.nvim` (the
-- owner of origin), `tsquery` with `<id>` and `Tree-sitter query` with
-- `<Name>`. It renames each path that holds `tsquery`, writes the `LICENSE`
-- copyright line from `git config user.name` and the year, and moves the
-- plugin's `README.md` and `CHANGELOG.md` from `.github/template-init/` into
-- place. Then it deletes the template-only files: `.github/template-init/`,
-- `.github/workflows/template.yml` and itself. It checks its input first
-- and changes nothing when a check fails. It commits nothing.

local template_id = 'tsquery'
local template_name = 'Tree-sitter query'
local template_repo = 'a1exk-dev/codestyle-tsquery.nvim'

-- Every plugin keeps these files as the template has them, so they hold no
-- text of the template's plugin, and `init.lua` never changes them.
local boilerplate = {
  ['.github/workflows/ci.yml'] = true,
  ['.github/workflows/spelling.yml'] = true,
  ['.github/workflows/canary.yml'] = true,
  ['.github/workflows/release.yml'] = true,
  ['.github/workflows/auto-merge.yml'] = true,
  ['.github/scripts/release.sh'] = true,
  ['test/run.lua'] = true,
  ['test/deps.lua'] = true,
  ['CONTRIBUTING.md'] = true,
  ['AGENTS.md'] = true,
  ['CLAUDE.md'] = true,
  ['.gitignore'] = true,
  ['.luarc.json'] = true,
  ['.stylua.toml'] = true,
  ['.typos.toml'] = true,
}

local init_path = 'scripts/init.lua'
local self_check_path = '.github/workflows/template.yml'
local plugin_files_dir = '.github/template-init'

local root = vim.fs.normalize(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h'))

---@param message string
local function fail(message)
  io.stderr:write('init.lua: ' .. message .. '\nNothing was changed.\n')
  os.exit(1)
end

---@param args string[]
---@return string? stdout
local function git(args)
  local result = vim.system(vim.list_extend({ 'git', '-C', root }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.trim(result.stdout)
end

---@param path string relative to the root
---@return string
local function read(path)
  local file = assert(io.open(root .. '/' .. path, 'rb'))
  local text = file:read('*a')
  file:close()
  return text
end

---@param path string relative to the root
---@param text string
local function write(path, text)
  local file = assert(io.open(root .. '/' .. path, 'wb'))
  file:write(text)
  file:close()
end

--- Replaces each literal `from` of `pairs` in one pass from the left, so
--- replaced text is never replaced again. At one position, the first pair wins.
---@param text string
---@param replacements { [1]: string, [2]: string }[]
---@return string
local function replace(text, replacements)
  local out = {} ---@type string[]
  local pos = 1
  while true do
    local best_start, best ---@type integer?, { [1]: string, [2]: string }?
    for _, pair in ipairs(replacements) do
      local start = text:find(pair[1], pos, true)
      if start and (not best_start or start < best_start) then
        best_start, best = start, pair
      end
    end
    if not best_start or not best then
      table.insert(out, text:sub(pos))
      return table.concat(out)
    end
    table.insert(out, text:sub(pos, best_start - 1))
    table.insert(out, best[2])
    pos = best_start + #best[1]
  end
end

-- The checks. Nothing changes before they all pass.

local id, name = _G.arg[1], _G.arg[2]
if not id or not name then
  fail('usage: nvim -l scripts/init.lua <id> <Name>, for example nvim -l scripts/init.lua php PHP')
end
---@cast id string
---@cast name string
if not id:match('^[a-z][a-z0-9_]*$') then
  fail(('the id %q must be lowercase letters, digits and _, and start with a letter'):format(id))
end
if vim.trim(name) == '' then
  fail('the Name must not be empty')
end
if name:find("[%c'\\]") then
  fail(('the Name %q must not hold a quote, a backslash or a control character'):format(name))
end

local url = git({ 'remote', 'get-url', 'origin' })
if not url then
  fail('the repo has no origin remote')
end
---@cast url string
local owner, repo = url:match('^https://github%.com/([^/]+)/([^/]+)$')
if not owner then
  owner, repo = url:match('^[%w._-]+@github%.com:([^/]+)/([^/]+)$')
end
if not owner then
  owner, repo = url:match('^ssh://[%w._-]+@github%.com/([^/]+)/([^/]+)$')
end
if not owner or not repo then
  fail(('origin %s is not a GitHub repo'):format(url))
end
---@cast repo string
repo = repo:gsub('%.git$', '')
local plugin_repo = ('codestyle-%s.nvim'):format(id)
if repo ~= plugin_repo then
  fail(('origin is the repo %s, but the plugin with the id %s must be named %s'):format(repo, id, plugin_repo))
end

local author = git({ 'config', 'user.name' })
if not author or author == '' then
  fail('git config user.name is not set, and the LICENSE copyright line needs it')
end
---@cast author string

local files = git({ 'ls-files', '-z', '--cached', '--others', '--exclude-standard' })
if not files then
  fail('git ls-files failed')
end
---@cast files string
for _, path in ipairs({
  init_path,
  self_check_path,
  plugin_files_dir .. '/README.md',
  plugin_files_dir .. '/CHANGELOG.md',
}) do
  if not vim.uv.fs_stat(root .. '/' .. path) then
    fail(('%s is missing: was init.lua already run?'):format(path))
  end
end

-- The changes.

local changed = {} ---@type string[]
local replacements = {
  { template_repo, ('%s/%s'):format(owner, plugin_repo) },
  { template_id, id },
  { template_name, name },
}
-- Not filled: the template-only files, and the template's own README.md and
-- CHANGELOG.md, which the plugin's files replace.
local skipped = { [init_path] = true, [self_check_path] = true, ['README.md'] = true, ['CHANGELOG.md'] = true }

for _, path in ipairs(vim.split(files, '\0', { trimempty = true })) do
  local stat = vim.uv.fs_lstat(root .. '/' .. path)
  if stat and stat.type == 'file' and not boilerplate[path] and not skipped[path] then
    local text = read(path)
    local new_text = replace(text, replacements)
    if new_text ~= text then
      write(path, new_text)
      table.insert(changed, 'filled ' .. path)
    end
    if path:find(template_id, 1, true) then
      local new_path = replace(path, { { template_id, id } })
      vim.fn.mkdir(vim.fs.dirname(root .. '/' .. new_path), 'p')
      assert(vim.uv.fs_rename(root .. '/' .. path, root .. '/' .. new_path))
      table.insert(changed, ('renamed %s to %s'):format(path, new_path))
      -- Removes each folder that the rename left empty.
      local dir = vim.fs.dirname(path)
      while dir ~= '.' and vim.uv.fs_rmdir(root .. '/' .. dir) do
        dir = vim.fs.dirname(dir)
      end
    end
  end
end

local license = read('LICENSE')
local copyright = ('Copyright (c) %s %s'):format(tostring(os.date('%Y')), author)
local new_license, count = license:gsub('Copyright %(c%)[^\n]*', function()
  return copyright
end, 1)
if count == 1 then
  write('LICENSE', new_license)
  table.insert(changed, 'wrote the copyright line of LICENSE')
end

for _, file in ipairs({ 'README.md', 'CHANGELOG.md' }) do
  assert(vim.uv.fs_rename(root .. '/' .. plugin_files_dir .. '/' .. file, root .. '/' .. file))
  table.insert(changed, ('moved %s/%s over %s'):format(plugin_files_dir, file, file))
end

vim.fs.rm(root .. '/' .. plugin_files_dir, { recursive = true })
vim.fs.rm(root .. '/' .. self_check_path)
vim.fs.rm(root .. '/' .. init_path)
vim.uv.fs_rmdir(root .. '/scripts')
table.insert(changed, ('deleted %s/, %s and %s'):format(plugin_files_dir, self_check_path, init_path))

io.stdout:write(table.concat(changed, '\n') .. '\n')
io.stdout:write(('\nThe plugin %s (%s) is ready. Review the changes, then commit them.\n'):format(id, name))
