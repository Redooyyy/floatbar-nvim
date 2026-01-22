-- Prevent multiple loads
if vim.g.loaded_floatbar then
  return
end
vim.g.loaded_floatbar = true

-- Load the floatbar config (assuming it has been set earlier)
local status, floatbar = pcall(require, 'floatbar')
if not status then
  return
end

-- Default keymaps if user hasn't defined them
local toggle_key = (floatbar.config and floatbar.config.keymaps and floatbar.config.keymaps.toggle)
  or '<C-t>'

-- Normal mode toggle
vim.keymap.set('n', toggle_key, function()
  floatbar.toggle()
end, { desc = 'Toggle Floating Terminal' })

-- Terminal mode toggle
vim.keymap.set('t', toggle_key, function()
  -- Switch to terminal-normal mode first, then toggle
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', true)
  floatbar.toggle()
end, { desc = 'Toggle Floating Terminal from terminal mode' })
