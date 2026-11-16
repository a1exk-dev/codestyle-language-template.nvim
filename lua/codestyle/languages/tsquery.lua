-- The spec of the Tree-sitter query Language Plugin (Core ADR-0007): the
-- required fields of `codestyle.Spec`, the `scheme` module and one sample
-- Option. CONTRIBUTING.md lists the optional parts of the contract.

---@type codestyle.Spec
return {
  api = 1,
  id = 'tsquery',
  name = 'Tree-sitter query',
  filetypes = { 'query' },
  parsers = { default = { 'query' } },
  options = {
    { key = 'spaces.after_colon', type = 'boolean', default = true, label = 'After colon' },
  },
  formatter = 'codestyle.languages.tsquery.formatter',
  scheme = 'codestyle.languages.tsquery.scheme',
}
