local floatbar = require('floatbar')

local M = {}

local defaults = {
  keymaps = {
    toggle = '<C-t>',
  },
}

local config = defaults

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', defaults, user_config or {})

  -- user explicitly disables keymaps
  if not config.keymaps or not config.keymaps.toggle then
    return
  end

  -- Normal mode
  vim.keymap.set('n', config.keymaps.toggle, floatbar.toggle, {
    desc = 'Toggle Floating Terminal',
    noremap = true,
    silent = true,
  })

  -- Terminal mode
  vim.keymap.set('t', config.keymaps.toggle, function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
      'n',
      true
    )
    floatbar.toggle()
  end, {
    desc = 'Toggle Floating Terminal (terminal mode)',
    noremap = true,
    silent = true,
  })
end

return M
