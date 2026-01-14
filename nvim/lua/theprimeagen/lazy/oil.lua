return {
  'stevearc/oil.nvim',
  -- oil.nvim can use nvim-web-devicons for file icons, which is already a dependency.
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "antosha417/nvim-lsp-file-operations",
  },
  config = function()
    require('oil').setup({
      -- Configuration options can be found with :help oil-options
      -- LSP 파일 작업 지원: 파일 이동 시 임포트 자동 업데이트
      lsp_file_operations = {
        enabled = true,
        autosave_changes = true,  -- true로 설정해야 LSP 이벤트가 제대로 트리거됨
      },
    })

    -- Keymap to open oil in the current file's directory
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory with oil.nvim" })
  end,
}