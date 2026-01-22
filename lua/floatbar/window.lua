local M = {}

-- Persistent state
local term_buf = nil
local term_win = nil

-- Default config
M.config = {
  width = 0.8, -- 80% of screen
  height = 0.8, -- 80% of screen
  border = 'rounded',
  winblend = 0, -- semi-transparent
  keymaps = {
    toggle = '<C-t>', -- default keymaps ctrl+t
  },
}

-- Allow init.lua to update config
function M.set_config(user_config)
  if not user_config then
    return
  end

  if user_config.width then
    M.config.width = user_config.width
  end
  if user_config.height then
    M.config.height = user_config.height
  end
  if user_config.border then
    M.config.border = user_config.border
  end
  if user_config.winblend ~= nil then
    M.config.winblend = user_config.winblend
  end
  if user_config.keymaps then
    for k, v in pairs(user_config.keymaps) do
      M.config.keymaps[k] = v
    end
  end
end

-- Calculate floating window geometry
local function float_config()
  local width = math.floor(vim.o.columns * M.config.width)
  local height = math.floor(vim.o.lines * M.config.height)
  return {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = M.config.border,
  }
end

-- Open floating terminal
function M.open()
  vim.o.termguicolors = true

  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
    return
  end

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'hide')
  end

  term_win = vim.api.nvim_open_win(term_buf, true, float_config())

  if vim.bo[term_buf].buftype ~= 'terminal' then
    vim.fn.termopen(vim.o.shell)
  end

  -- Highlights
  local fg = '#CBE0F0'
  local border_fg = '#547998'

  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', fg = fg })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', fg = border_fg })
  vim.api.nvim_win_set_option(term_win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')
  vim.api.nvim_win_set_option(term_win, 'winblend', M.config.winblend)

  vim.cmd('startinsert')
end

function M.close()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end
end

function M.toggle()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    M.close()
  else
    M.open()
  end
end

function M.send(cmd)
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    M.open()
  end
  vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. '\n')
end

return M
