--- Deltas only, in after/lsp/ so they outrank nvim-lspconfig's
--- lsp/rust_analyzer.lua (:h lsp-config-merge places after/lsp above lsp).
--- `cmd`, `filetypes` and the cargo-metadata `root_dir` resolver are inherited;
--- lspconfig's `before_init` is what forwards `settings['rust-analyzer']` to the
--- server as `initializationOptions`, so that plugin must stay installed.
---@type vim.lsp.Config
return {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureCaptureHints = { enable = true },
        typeHints = { enable = true },
      },
      cargo = {
        allFeatures = true,
      },
    },
  },
}
