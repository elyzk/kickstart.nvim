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
  s(
    'class',
    fmt(
      [[{} class {} {{
    {}() {{

    }}
}}]],
      { c(1, { t 'public', t 'private' }), i(2), rep(2) }
    )
  ),
}
