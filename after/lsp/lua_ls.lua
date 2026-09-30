--- Deltas only, in after/lsp/ so they outrank nvim-lspconfig's lsp/lua_ls.lua
--- (:h lsp-config-merge places after/lsp above lsp). `filetypes` and the richer
--- `root_markers` are inherited from lspconfig.
---@type vim.lsp.Config
return {
  -- manually override cache folder to user-owned
  cmd = {
    'lua-language-server',
    '--logpath=' .. vim.fn.stdpath('cache') .. '/lua-language-server/log',
    '--metapath=' .. vim.fn.stdpath('cache') .. '/lua-language-server/meta',
  },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        globals = { 'vim' }, -- Stop "Undefined global 'vim'" warnings
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME, -- Neovim runtime APIs
          vim.fn.stdpath('config'), -- This config
          vim.fs.dirname(vim.api.nvim_get_runtime_file('lua/mini', true)[1]), -- Mini* globals
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
      format = { enable = false },
    },
  },
}
