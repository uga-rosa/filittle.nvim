local M = {}
local fn = vim.fn

M.open = function()
  local name = string.match(fn.getline("."), "^(.*)/$") or fn.getline(".")
  vim.cmd("e " .. vim.b.filittle_dir .. name)
end

M.reload = function()
  vim.cmd("e")
end

M.up = function()
  local dir = fn.fnamemodify(vim.b.filittle_dir, ":h:h")
  local name = fn.fnamemodify(vim.b.filittle_dir, ":h:t")
  if name == "" then
    return
  end
  vim.cmd("e " .. dir)
  fn.search([[\v^\V]] .. name .. [[/\v$]], "c")
end

M.home = function()
  vim.cmd("e " .. fn.expand("~"))
end

M.toggle_hidden = function()
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

M.errmsg = function(msg)
  vim.cmd("redraw")
  vim.cmd("echohl Error")
  print(msg)
  vim.cmd("echohl None")
end

local inarr = function(str, arr)
  for _, v in ipairs(arr) do
    if str == v then
      return true
    end
  end
  return false
end

M.newdir = function()
  local name = fn.input("Create directory: ")
  if not name or name == "" then
    return
  end
  if inarr(name, { ".", "..", "/", "\\" }) then
    M.errmsg("Invalid directory name: " .. name)
    return
  end
  if vim.fn.mkdir(vim.b.filittle_dir .. name) == 0 then
    M.errmsg("Create directory failed")
    return
  end
  M.reload()
end

return M
