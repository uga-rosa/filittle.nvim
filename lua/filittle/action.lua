local M = {}

local fn = vim.fn
local cmd = vim.cmd

M.reload = function()
  cmd("do User filittle")
end

M.open = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  cmd("e " .. path._absolute)
  if path:is_dir() then
    M.reload()
  end
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
  cmd("e " .. parent)
  M.reload()
  fn.search([[\v^\V]] .. opts.diricon .. old .. [[/\v$]], "c")
end

M.home = function(opts)
  vim.cmd("e " .. opts.cwd.path.home)
  M.reload()
end

M.toggle_hidden = function(_)
  _G._filittle_.show_hidden = _G._filittle_.show_hidden
  M.reload()
end

M.mkdir = function(opts)
  local name = fn.input("Create directory: ")
  if not name or name == "" then
    return
  end
  opts.cwd:joinpath(name):mkdir()
  M.reload()
end

M.touch = function(opts)
  local name = fn.input("Create file: ")
  if not name or name == "" then
    return
  end
  opts.cwd:joinpath(name):touch()
  M.reload()
end

M.delete = function(opts)
  local path = opts.paths[tonumber(fn.line("."))]
  local conf = fn.confirm("Delete?: " .. path.filename, "&Yes\n&No", 2)
  if conf == 0 or conf == 2 then
    return
  end
  path:delete()
  M.reload()
end

M.rename = function(opts)
  local old = opts.paths[tonumber(fn.line("."))]
  local new = fn.input("Rename: ", old._name)
  if not new or new == "" or new == old._name then
    return
  end
  old:rename(new)
  M.reload()
end

return M
