local M = {}

local api = vim.api

local action = require("filittle.action")
local builtin = {
  open = action.open,
  split = action.split,
  vsplit = action.vsplit,
  tabedit = action.tabedit,
  reload = action.reload,
  up = action.up,
  home = action.home,
  toggle_hidden = action.toggle_hidden,
  touch = action.touch,
  mkdir = action.mkdir,
  delete = action.delete,
  rename = action.rename,
}

local lua2rhs = function(func, opts)
  local idx = #_G._filittle_ + 1
  if type(func) == "string" then
    if builtin[func] then
      _G._filittle_[idx] = function()
        builtin[func](opts)
      end
    else
      print("This is NOT builtin function: " .. func)
      return
    end
  else
    _G._filittle_[idx] = function()
      func(opts)
    end
  end
  return string.format("<cmd>lua _G._filittle_(%d)<cr>", idx)
end

M.init = function(opts, mappings)
  for lhs, func in pairs(mappings) do
    local rhs = lua2rhs(func, opts)
    if rhs then
      api.nvim_buf_set_keymap(0, "n", lhs, rhs, { noremap = true, nowait = true })
    end
  end
end

return M
