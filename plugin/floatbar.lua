-- Prevent multiple loads
if vim.g.loaded_floatbar then
  return
end
vim.g.loaded_floatbar = true

-- Normal mode toggle
vim.keymap.set('n', '<C-t>', function()
  require('floatbar').toggle()
end, { desc = 'Toggle Floating Terminal' })

-- Terminal mode toggle
vim.keymap.set('t', '<C-t>', function()
  -- First switch to terminal-normal mode, then toggle
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', true)
  require('floatbar').toggle()
end, { desc = 'Toggle Floating Terminal from terminal mode' })
