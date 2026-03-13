local ls = require 'luasnip'
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

local same = function(index)
  return f(function(arg)
    -- TODO
    return arg[1]
  end, { index })
end

return {
  s('sametest', fmt([[example: {}, function: {}]], { i(1), same(1) })),
  s(
    'curtime',
    f(function()
      return os.date '%D - %H:%M'
    end)
  ),
}
