-- Prevent multiple loads
if vim.g.loaded_floatbar then
  return
end
vim.g.loaded_floatbar = true

-- Keymap to toggle terminal
vim.keymap.set('n', '<space>tt', function()
  require('floatbar').toggle()
end, { desc = 'Toggle Floating Terminal' })
