return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            keymaps = {
                visual = "S",
                visual_line = "gS"
            }
        })
    end,
}
