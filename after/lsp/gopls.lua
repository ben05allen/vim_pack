--- Deltas only, in after/lsp/ so they outrank nvim-lspconfig's lsp/gopls.lua
--- (:h lsp-config-merge places after/lsp above lsp). `cmd`, `filetypes` and
--- `root_dir` are inherited from lspconfig.
---@type vim.lsp.Config
return {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
