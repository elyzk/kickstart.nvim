return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'atm1020/neotest-jdtls',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-jdtls',
      },
    }

    local neotest = require 'neotest'

    vim.keymap.set('n', '<leader>tr', function()
      require('neotest').run.run()
    end, { desc = 'Test [R]un Nearest' })

    vim.keymap.set('n', '<leader>tf', function()
      neotest.run.run(vim.fn.expand '%')
    end, { desc = 'Test File' })

    vim.keymap.set('n', '<leader>ta', function()
      neotest.run.run(vim.loop.cwd())
    end, { desc = 'Test All' })

    vim.keymap.set('n', '<leader>ts', function()
      neotest.summary.toggle()
    end, { desc = 'Test Summary' })

    vim.keymap.set('n', '[t', function()
      neotest.jump.prev { status = 'failed' }
    end, { desc = 'Prev Failed Test' })
    vim.keymap.set('n', ']t', function()
      neotest.jump.next { status = 'failed' }
    end, { desc = 'Next Failed Test' })

    vim.keymap.set('n', '<leader>to', function()
      neotest.output.open { enter = true }
    end, { desc = 'Test Output' })
  end,
}
