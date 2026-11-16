-- The `scheme` module of the Tree-sitter query Language Plugin (Core
-- ADR-0007, ADR-0010): the PhpStorm fields that its Options read.

---@type codestyle.Scheme
return {
  -- PhpStorm has no Tree-sitter query language, so `TSQuery` is made up. A
  -- plugin puts here the `language=` of its PhpStorm `<codeStyleSettings>`.
  language = 'TSQuery',
  entries = {
    { key = 'spaces.after_colon', field = 'common:SPACE_AFTER_COLON' },
  },
}
