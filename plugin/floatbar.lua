-- Prevent multiple loads
if vim.g.loaded_floatterm then
  return
end
vim.g.loaded_floatterm = true

-- Keymap to toggle terminal
vim.keymap.set('n', '<space>tt', function()
  require('floatterm').toggle()
end, { desc = 'Toggle Floating Terminal' })
