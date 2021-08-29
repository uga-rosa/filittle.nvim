local M = {}

local fn = vim.fn
local cmd = vim.cmd

M.open = function(paths, _)
  local path = paths[tonumber(fn.line("."))]
  cmd("e " .. path:absolute())
end

M.reload = function(_, _)
  vim.cmd("e")
end

M.up = function(paths, devicons)
  local cwd = paths.cwd
  local parent = cwd:parent()
  if parent == cwd.path.root() then
    return
  end
  local old = cwd:make_relative(parent:absolute())
  vim.cmd("e " .. parent.filename)
  if parent.filename == cwd.path.root() then
    vim.cmd("do BufEnter")
  end
  local icon = ""
  if devicons then
    local Devicons = require("nvim-web-devicons")
    icon = Devicons.get_icon("filittle_dir") .. " "
  end
  fn.search([[\v^\V]] .. icon .. old .. [[/\v$]], "c")
end

M.home = function(paths, _)
  vim.cmd("e " .. paths.cwd.path.home)
end

M.toggle_hidden = function(_, _)
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

M.touch = function(paths, _)
  local name = fn.input("Create file: ")
  local cwd = paths.cwd
  cwd:joinpath(name):touch()
  M.reload()
end

M.mkdir = function(paths, _)
  local name = fn.input("Create directory: ")
  local cwd = paths.cwd
  cwd:joinpath(name):mkdir()
  M.reload()
end

M.delete = function(paths, _)
  local path = paths[tonumber(fn.line("."))]
  local conf = fn.confirm("Delete?: " .. path.filename, "&Yes\n&No\n&Force", 2)
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

M.rename = function(paths, _)
  local old = paths[fn.line(".")]
  local new = fn.input("Rename: ", old.filename)
  old:rename({ new_name = paths.cwd:joinpath(new):absolute() })
  M.reload()
end

return M
