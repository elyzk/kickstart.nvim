vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function()
        require('config.jdtls_setup').setup()
    end,
})
