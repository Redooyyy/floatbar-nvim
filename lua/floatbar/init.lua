local window = require('floatbar.window')

local M = {}

-- Setup function for user config
function M.setup(user_config)
  if user_config then
    window.set_config(user_config)
  end

  -- Setup keymaps after config is set
  if not vim.g.loaded_floatbar then
    vim.g.loaded_floatbar = true

    local toggle_key = window.config.keymaps.toggle or '<C-t>'

    -- Normal mode toggle
    vim.keymap.set('n', toggle_key, function()
      window.toggle()
    end, {
      desc = 'Toggle Floating Terminal',
    })

    -- Terminal mode toggle
    vim.keymap.set('t', toggle_key, function()
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
        'n',
        true
      )
      window.toggle()
    end, { desc = 'Toggle Floating Terminal from terminal mode' })
  end
end

-- Public API
M.open = window.open
M.close = window.close
M.toggle = window.toggle
M.send = window.send

return M
