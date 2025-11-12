return {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                go = { "gofmt" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },

                jsx = { "prettier" },
                tsx = { "prettier" },
                vue = { "prettier" },

                json = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                html= { "prettier" },

                yaml = { "prettier" },
            }
        })
    end
}

