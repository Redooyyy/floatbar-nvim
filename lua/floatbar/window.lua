local M = {}

-- Persistent state
local term_buf = nil
local term_win = nil

-- Default config
local config = {
  width = 0.8, -- 80% of editor width
  height = 0.8, -- 80% of editor height
  border = 'rounded',
  winblend = 0, -- fully opaque, crisp text
}

-- Allow user to override defaults
function M.set_config(user_config)
  for k, v in pairs(user_config or {}) do
    config[k] = v
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
  vim.o.termguicolors = true

  -- Focus existing window if valid
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

  -- Start terminal buffer
  ---@diagnostic disable-next-line: deprecated
  vim.fn.termopen(vim.o.shell, {
    env = {
      TERM = vim.env.TERM,
      COLORTERM = vim.env.COLORTERM,
      OPENCODE_CONFIG_CONTENT = '{"theme":"nightowl"}',
    },
  })

  -- Style floating border only
  vim.api.nvim_set_hl(0, 'FloatingTermBorder', {
    fg = vim.api.nvim_get_hl(0, { name = 'FloatBorder' }).fg,
    bg = 'NONE',
  })
  vim.api.nvim_win_set_option(term_win, 'winhl', 'FloatBorder:FloatingTermBorder')
  vim.api.nvim_win_set_option(term_win, 'winblend', config.winblend)

  -- Reapply settings on buffer enter
  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = term_buf,
    callback = function()
      if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_set_option(term_win, 'winhl', 'FloatBorder:FloatingTermBorder')
        vim.api.nvim_win_set_option(term_win, 'winblend', config.winblend)
      end
    end,
  })

  -- Start insert mode automatically
  vim.cmd('startinsert')
end

-- Close terminal
function M.close()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end
end

-- Toggle terminal
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
  if vim.b.terminal_job_id then
    vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. '\n')
  end
end

return M
