# Development Commands

**Lint/Format**: `stylua .` (auto-format with 2 spaces, single quotes, 100 char width)

**Test**: `busted` (uses nlua interpreter, lua path: 'lua/?.lua;lua/?/init.lua')

**Single test**: `busted -t "test name pattern"` or `busted -p "test_name"`

# Code Style

**Module pattern**: `local M = {}` at top, return M at bottom

**Functions**: Public via `function M.name()`, internal via `local function name()`

**State**: Module-level locals for persistent state (e.g., `term_buf`, `term_win`)

**Config**: Default table with selective user override in `set_config()`

**Plugin loading**: Prevent reloads with `vim.g.loaded_*` guard pattern

**Keymaps**: `vim.keymap.set(mode, lhs, rhs, { desc = '...' })` always include desc

**Naming**: snake_case for all functions/variables

**Comments**: Single line `--` for comments, avoid block comments

**API design**: Public API exposed via init.lua wrapper, core logic in module files