
return {
    "folke/todo-comments.nvim",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('todo-comments').setup()
        vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>", { desc = "Todo list" })
        vim.keymap.set("n", "<leader>tdq", "<cmd>TodoQuickFix<cr>", { desc = "Todo list Quick Fix" })
    end
}


