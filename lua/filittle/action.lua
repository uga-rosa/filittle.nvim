local M = {}

local fn = vim.fn
local cmd = vim.cmd

M.open = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  cmd("e " .. path._absolute)
end

M.split = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  cmd("sp " .. path._absolute)
end

M.vsplit = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  cmd("vs " .. path._absolute)
end

M.tabedit = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  cmd("tabe " .. path._absolute)
end

M.up = function(opts)
  local cwd = opts.cwd
  if cwd._absolute == cwd.path.root then
    return
  end
  local parent = cwd._parent
  local old = cwd._name
  vim.cmd("e " .. parent)
  M.reload()
  if parent == cwd.path.root then
    vim.cmd("do BufEnter")
  end
  fn.search([[\v^\V]] .. opts.diricon .. old .. [[/\v$]], "c")
end

M.home = function(opts)
  vim.cmd("e " .. opts.cwd.path.home)
end

M.reload = function(_)
  if fn.bufname() == "" then
    print("No file name")
  else
    vim.b.filittle_prev_filetype = "filittle"
    vim.cmd("e")
  end
end

M.toggle_hidden = function(_)
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

M.mkdir = function(opts)
  local name = fn.input("Create directory: ")
  opts.cwd:joinpath(name):mkdir()
  M.reload()
end

M.touch = function(opts)
  local name = fn.input("Create file: ")
  opts.cwd:joinpath(name):touch()
  M.reload()
end

M.delete = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  local conf = fn.confirm("Delete?: " .. path.filename, "&Yes\n&No", 2)
  if conf == 2 then
    return
  end
  path:delete()
  M.reload()
end

M.rename = function(opts)
  local old = opts.paths[tonumber(fn.line("."))]
  local new = fn.input("Rename: ", old._name)
  old:rename(new)
  M.reload()
end

return M
