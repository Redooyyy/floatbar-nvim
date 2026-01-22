local M = {}

-- Persistent state
local term_buf = nil
local term_win = nil
local term_job = nil

-- Default config
local config = {
  width = 0.8,
  height = 0.8,
  border = 'rounded',
  winblend = 0,
  highlights = true, -- allow disabling plugin highlights
}

function M.set_config(user_config)
  config = vim.tbl_extend('force', config, user_config or {})
end

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

function M.open()
  vim.o.termguicolors = true

  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
    return
  end

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[term_buf].bufhidden = 'hide'
  end

  term_win = vim.api.nvim_open_win(term_buf, true, float_config())

  if vim.bo[term_buf].buftype ~= 'terminal' then
    term_job = vim.fn.termopen(vim.o.shell)
  end

  if config.highlights then
    vim.api.nvim_set_hl(0, 'FloatBarNormal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'FloatBarBorder', { bg = 'NONE' })

    vim.api.nvim_win_set_option(
      term_win,
      'winhl',
      'Normal:FloatBarNormal,FloatBorder:FloatBarBorder'
    )
  end

  vim.api.nvim_win_set_option(term_win, 'winblend', config.winblend)
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
  if not term_job then
    M.open()
  end
  vim.api.nvim_chan_send(term_job, cmd .. '\n')
end

return M
