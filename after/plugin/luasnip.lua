local ls = require 'luasnip'
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

ls.config.set_config {
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  enable_autosnippets = true,
}

ls.add_snippets('all', {
  ls.parser.parse_snippet('expand', 'als;dfjasldkflasdfj'),
})

ls.add_snippets('lua', {
  ls.parser.parse_snippet('lf', 'local $1 = function($2)\n  $0\nend'),
  s('req', fmt("local {} = require('{}')", { i(1), rep(1) })),
})

vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set('i', '<C-l>', function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

vim.keymap.set('n', '<leader><leader>s', '<CMD>source ~/.config/nvim/after/plugin/luasnip.lua<CR>')
