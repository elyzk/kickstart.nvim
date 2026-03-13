local ls = require 'luasnip'
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local d = ls.dynamic_node
local sn = ls.snippet_node

local get_test_result = function(position)
  return d(position, function()
    local nodes = {}
    table.insert(nodes, t ' ')

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if line:match 'anyhow::Result' then
        table.insert(nodes, t '--> Result<()>')
      end
    end
    return sn(nil, c(1, nodes))
  end, {})
end

return {
  s(
    'modtest',
    fmt(
      [[
        #[cfg(test)]
        mod test {{
        {}
            {}
        }}
      ]],
      {
        c(1, { t '    use super::*;', t '' }),
        i(0),
      }
    )
  ),

  -- Adding a test case
  s(
    'test',
    fmt(
      [[
      #[test]
      fn {}(){}{{
          {}
      }}
      ]],
      {
        i(1),
        get_test_result(2),
        i(0),
      }
    )
  ),
}
