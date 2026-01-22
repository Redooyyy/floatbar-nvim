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
  vim.keymap.set('n', config.keymaps.toggle, function()
    require('floatbar').toggle()
  end, { desc = 'Toggle Floating Terminal' })

  -- Terminal mode
  vim.keymap.set('t', config.keymaps.toggle, function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
      'n',
      true
    )
    require('floatbar').toggle()
  end, { desc = 'Toggle Floating Terminal (terminal mode)' })
end

return M
