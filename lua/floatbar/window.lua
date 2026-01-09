local M = {}

-- Persistent state
local term_buf = nil
local term_win = nil

-- Default config
local config = {
  width = 0.8, -- 80% of screen
  height = 0.8, -- 80% of screen
  border = 'rounded',
  winblend = 20, -- semi-transparent
}

-- Allow init.lua to update config
function M.set_config(user_config)
  if user_config.width then
    config.width = user_config.width
  end
  if user_config.height then
    config.height = user_config.height
  end
  if user_config.border then
    config.border = user_config.border
  end
  if user_config.winblend ~= nil then
    config.winblend = user_config.winblend
  end
end

-- Calculate floating window geometry
local function float_config()
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  return {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = config.border,
  }
end

-- Open floating terminal
function M.open()
  -- Enable true colors for theme support
  vim.o.termguicolors = true

  -- Create or focus existing window
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
    return
  end

  -- Create buffer if it doesn't exist
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'hide')
  end

  -- Open floating window
  term_win = vim.api.nvim_open_win(term_buf, true, float_config())

  -- Start terminal if not already a terminal buffer
  if vim.bo[term_buf].buftype ~= 'terminal' then
    vim.fn.termopen(vim.o.shell)
  end

  -- -------------------------------
  -- Modern theme-aware highlights
  -- -------------------------------

  -- TokyoNight colors (you can adjust if using a different theme)
  local fg = '#CBE0F0' -- default foreground
  local border_fg = '#547998' -- border color

  -- Transparent floating background
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', fg = fg })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', fg = border_fg })

  -- Apply highlights to this floating window
  vim.api.nvim_win_set_option(term_win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')
  vim.api.nvim_win_set_option(term_win, 'winblend', config.winblend)

  -- Enter insert mode automatically
  vim.cmd('startinsert')
end

-- Close floating terminal but keep buffer alive
function M.close()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end
end

-- Toggle floating terminal
function M.toggle()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    M.close()
  else
    M.open()
  end
end

-- Send command to terminal
function M.send(cmd)
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    M.open()
  end
  vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. '\n')
end

return M
