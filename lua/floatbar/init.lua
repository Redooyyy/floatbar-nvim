local window = require('floatbar.window')
local keymaps = require('lua.plugin.floatbar')
local M = {}

-- Setup function for user config
function M.setup(user_config)
  if user_config then
    window.set_config(user_config)
    keymaps.setup(user_config)
  end
end

-- Public API
M.open = window.open
M.close = window.close
M.toggle = window.toggle
M.send = window.send

return M
