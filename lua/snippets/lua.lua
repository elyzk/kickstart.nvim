local ls = require 'luasnip'
local s = ls.s
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep
local f = ls.function_node
local c = ls.choice_node
local t = ls.text_node
local sn = ls.snippet_node

return {
  ls.parser.parse_snippet('lf', 'local $1 = function($2)\n  $0\nend'),
  -- s('req', fmt("local {} = require('{}')", { i(1), rep(1) })),
  s(
    'req',
    fmt([[local {} = require('{}')]], {
      f(function(import_name)
        local parts = vim.split(import_name[1][1], '.', { plain = true })
        return parts[#parts] or ''
      end, { 1 }),
      i(1),
    })
  ),
  s(
    'keymap',
    fmt([[vim.keymap.set({}, '{}', {}, {{ desc = '{}' }})]], {
      c(1, {
        fmt([['{}']], { i(1) }),
        fmt([[{{'{}', '{}'}}]], { i(1), i(2) }),
      }),
      i(2),
      i(3),
      i(0),
    })
  ),
}
