local M = {}
local fn = vim.fn
local uv = vim.loop
local dir = vim.b.filittle_dir

local cword = function()
  local line = fn.getline(".")
  local idx = vim.b.filittle_devicon and vim.str_byteindex(line, 1) + 2 or 1
  local name = string.sub(line, idx)
  return fn.fnameescape(string.match(name, "^(.-)/?$"))
end

M.open = function()
  vim.cmd("e " .. dir .. cword())
end

M.reload = function()
  vim.cmd("e")
end

M.up = function()
  if dir == "/" then
    return
  end
  local path, name = dir:match("^(.*)/(.-)/$")
  path = path == "" and "/" or path
  print(path)
  vim.cmd("e " .. fn.fnameescape(path))
  local icon = vim.b.filittle_devicon and " " or ""
  fn.search([[\v^\V]] .. icon .. name .. [[/\v$]], "c")
end

M.home = function()
  vim.cmd("e " .. fn.expand("~"))
end

M.toggle_hidden = function()
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

local errmsg = vim.schedule_wrap(function(err, _)
  if err then
    vim.api.nvim_command("echohl ErrorMsg")
    vim.api.nvim_command("echomsg '" .. err .. "'")
    vim.api.nvim_command("echohl None")
  end
end)

M.newdir = function()
  local name = fn.input("Create directory: ")
  if not name or name == "" then
    return
  end
  uv.fs_mkdir(dir .. name, 2434, errmsg)
  M.reload()
end

M.newfile = function()
  local name = fn.input("Create file: ")
  if not name or name == "" then
    return
  end
  local file = uv.fs_open(dir .. name, "w", 2434, errmsg)
  uv.fs_close(file, errmsg)
  M.reload()
end

M.delete = function()
  local name = cword()
  local conf = fn.confirm("Delete?: " .. name, "&Yes\n&No\n&Force", 2)
  if conf == 2 then
    return
  end
  local path = dir .. name
  if fn.isdirectory(path) == 1 then
    if conf == 1 then
      uv.fs_rmdir(path, errmsg)
    end
  else
    uv.fs_unlink(path, errmsg)
  end
  M.reload()
end

M.rename = function()
  local old = cword()
  local new = fn.input("Rename: ", old)
  if vim.tbl_contains({ "", old }, new) then
    return
  end
  uv.fs_rename(dir .. old, dir .. new, errmsg)
  M.reload()
end

return M
