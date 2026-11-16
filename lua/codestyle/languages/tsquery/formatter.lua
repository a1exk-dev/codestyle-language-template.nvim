-- The formatter of the Tree-sitter query Language Plugin (Core ADR-0007):
-- one Block per parser node, and one Spacing rule written with
-- `SpacingBuilder`, a port of IntelliJ's.

local block = require('codestyle.block')
local spacing_builder = require('codestyle.spacing_builder')

local spacing = spacing_builder
  .new()
  -- `name: (identifier)`: one space after the `:` of a field, or none.
  .after_inside(':', 'field_definition')
  .space_if(function(values)
    return values.spaces.after_colon
  end)

---@param node TSNode
---@return codestyle.Block
local function build(node)
  local children = {}
  for child in node:iter_children() do
    table.insert(children, build(child))
  end
  return block.new({ node = node, children = children })
end

---@type codestyle.Formatter
return {
  build = function(ctx)
    return build(ctx.root)
  end,
  rules = spacing.rules(),
}
