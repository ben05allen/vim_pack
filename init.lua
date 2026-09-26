vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

-- Keymaps
vim.g.mapleader = ' '
vim.keymap.set({ 'i', 'v' }, 'jj', '<Esc>', { noremap = true })

-- packages
vim.pack.add({
  'https://github.com/cameron-wags/rainbow_csv.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/stevearc/conform.nvim',
})

require('mini.basics').setup()
require('mini.completion').setup()
require('mini.comment').setup()
require('mini.diff').setup()
require('mini.files').setup()
require('mini.icons').setup()
require('mini.indentscope').setup()
require('mini.move').setup()
require('mini.notify').setup()
require('mini.pairs').setup()
require('mini.pick').setup()
require('mini.splitjoin').setup()
require('mini.statusline').setup()
require('mini.surround').setup()
require('mini.tabline').setup()
require('mini.trailspace').setup()

local MiniFiles = require('mini.files')
local MiniPick = require('mini.pick')

-- Theme
vim.cmd.colorscheme('miniwinter')

-- Grab paths
local minifiles_group = vim.api.nvim_create_augroup('MiniFilesPathGrab', {})
vim.api.nvim_create_autocmd('User', {
  group = minifiles_group,
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id

    local grab_path = function(relative)
      local entry = MiniFiles.get_fs_entry()
      if not entry then
        return
      end

      local path = relative and vim.fn.fnamemodify(entry.path, ':.') or entry.path
      vim.fn.setreg('+', path) -- system clipboard
      vim.fn.setreg('"', path) -- unnamed register
      vim.notify('Grabbed path: ' .. path)
      MiniFiles.close()
    end

    -- grab the absolute path with gY
    vim.keymap.set('n', 'gY', function()
      grab_path(false)
    end, { buffer = buf_id, desc = 'Grab absolute path' })
    -- grab the relative path with gy
    vim.keymap.set('n', 'gy', function()
      grab_path(true)
    end, { buffer = buf_id, desc = 'Grab path relative to cwd' })
  end,
})

-- Relative Line numbering
vim.opt.relativenumber = true

-- More Keymaps
vim.keymap.set('n', '<leader>e', function()
  require('mini.files').open()
end, { desc = 'Open mini.files' })

vim.keymap.set('n', '<leader>ff', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', MiniPick.builtin.grep_live, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', MiniPick.builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', MiniPick.builtin.help, { desc = 'Find help' })

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format buffer' })

-- Clipboard
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'wsl_clipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = [[powershell.exe -NoProfile -Command "[Console]::Out.Write((Get-Clipboard -Raw) -replace \"\r\n\", \"\n\")"]],
      ['*'] = [[powershell.exe -NoProfile -Command "[Console]::Out.Write((Get-Clipboard -Raw) -replace \"\r\n\", \"\n\")"]],
    },
    cache_enabled = 0,
  }
end

-- Sync Neovim's default registers with the system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Diagnostics
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚',
      [vim.diagnostic.severity.WARN] = '󰀪',
      [vim.diagnostic.severity.HINT] = '󰌶',
      [vim.diagnostic.severity.INFO] = '󰋽',
    },
  },
  virtual_text = {
    prefix = '●',
    spacing = 4,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

-- Go
vim.lsp.config['gopls'] = {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
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
vim.lsp.enable('gopls')

-- allow gopls inlay hints
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- Lua
vim.lsp.config['lua_ls'] = {
  -- manually override cache folder to user-owned
  cmd = {
    'lua-language-server',
    '--logpath=' .. vim.fn.stdpath('cache') .. '/lua-language-server/log',
    '--metapath=' .. vim.fn.stdpath('cache') .. '/lua-language-server/meta',
  },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
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
          vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim/lua', -- Mini* globals
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
      format = { enable = false },
    },
  },
}
vim.lsp.enable('lua_ls')

-- Python
vim.lsp.config['ruff'] = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', '.git' },
}
vim.lsp.enable('ruff')

vim.lsp.config['ty'] = {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', '.git' },
}
vim.lsp.enable('ty')

--Rust
vim.lsp.config['rust_analyzer'] = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
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
vim.lsp.enable('rust_analyzer')

-- Rainbow_csv
require('rainbow_csv').setup()

-- Formatting
require('conform').setup({
  formatters_by_ft = {
    go = { 'goimports', 'gofumpt' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    rust = { 'rustfmt' },
    lua = { 'stylua' },
  },
  -- Format on save configuration
  format_on_save = {
    timeout_ms = 500,
    lsp_format = 'fallback', -- Use LSP format if ruff isn't installed
  },
})

-- Python venv Selector
local function select_venv()
  -- Find common venv python executables using `fd`
  local command = { 'fd', 'python$', '.venv', 'venv', vim.fn.expand('~/.virtualenvs'), '--full-path' }

  MiniPick.builtin.cli({ command = command }, {
    source = {
      name = 'Python VirtualEnvs',
      choose = function(item)
        if not item then
          return
        end

        -- Set VIRTUAL_ENV environment variable
        local venv_path = item:match('(.*)/bin/python') or item:match('(.*)/Scripts/python.exe')
        if venv_path then
          vim.env.VIRTUAL_ENV = venv_path
        end

        -- Restart Python LSP clients so they pick up the new environment:
        -- ty reads VIRTUAL_ENV (and .venv) at spawn, ruff discovers its env fresh
        -- too; live settings notifications with `pythonPath` are ignored by both.
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if vim.list_contains({ 'ty', 'ruff' }, client.name) then
            client:stop()
          end
        end
        vim.cmd('edit') -- reload to re-attach the stopped clients

        vim.notify('Switched Python venv to: ' .. item, vim.log.levels.INFO)
      end,
    },
  })
end

vim.keymap.set('n', '<leader>cv', select_venv, { desc = 'Select Python venv' })
