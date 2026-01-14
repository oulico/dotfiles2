return {
    "nvim-telescope/telescope.nvim",

    branch = "0.1.x",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({})

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

        -- Diagnostics (타입 에러 확인)
        vim.keymap.set('n', '<leader>e', function()
            builtin.diagnostics({ bufnr = 0 })
        end, { desc = "Show diagnostics for current buffer" })
        vim.keymap.set('n', '<leader>E', builtin.diagnostics, { desc = "Show diagnostics for all buffers" })

        -- 버퍼 새로고침: 파일 시스템 변경사항을 Neovim에 반영
        vim.keymap.set('n', '<leader>rf', function()
            vim.cmd('checktime')  -- 모든 버퍼의 파일 변경사항 확인
            print("Buffers refreshed")
        end, { desc = "Refresh all buffers to detect file system changes" })
    end
}

