local M = {}

local fn = vim.fn
local cmd = vim.cmd

M.open = function(_, paths, _)
  local path = paths[fn.line(".")]
  cmd("e " .. path.filename)
end

M.reload = function(_, _, _)
  vim.cmd("e")
end

M.up = function(cwd, _, devicons)
  local parent = cwd:parent()
  local old = cwd:make_relative(parent)
  vim.cmd("e " .. parent.filename)
  if parent.filename == cwd.path.root() then
    vim.cmd("do BufEnter")
  end
  local icon = ""
  if devicons then
    local Devicons = require("nvim-web-devicons")
    icon = Devicons.get_icon("filittle_dir") .. " "
  end
  fn.search([[\v^\V]] .. icon .. old .. [[\v$]], "c")
end

M.home = function(cwd, _, _)
  vim.cmd("e " .. cwd.path.home)
end

M.toggle_hidden = function(_, _, _)
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

M.touch = function(cwd, _, _)
  local name = fn.input("Create file: ")
  cwd:joinpath(name):touch()
  M.reload()
end

M.mkdir = function(cwd, _, _)
  local name = fn.input("Create directory: ")
  cwd:joinpath(name):mkdir()
  M.reload()
end

M.delete = function(cwd, paths, _)
  local path = paths[fn.line(".")]
  local name = path:make_relative(cwd)
  local conf = fn.confirm("Delete?: " .. name, "&Yes\n&No\n&Force", 2)
  if conf == 2 then
    return
  end
  if conf == 1 and path:is_dir() then
    path:rmdir()
  else
    path:rm()
  end
  M.reload()
end

M.rename = function(cwd, paths, _)
  local old = paths[fn.line(".")]
  local new = fn.input("Rename: ", old:make_relative(cwd))
  old:rename({ new_name = cwd:joinpath(new).filename })
  M.reload()
end

return M
