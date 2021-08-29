local M = {}

local fn = vim.fn
local cmd = vim.cmd

M.open = function(paths)
  local path = paths[tonumber(fn.line("."))]
  cmd("e " .. path:absolute())
end

M.split = function(paths)
  local path = paths[tonumber(fn.line("."))]
  cmd("sp " .. path:absolute())
end

M.vsplit = function(paths)
  local path = paths[tonumber(fn.line("."))]
  cmd("vs " .. path:absolute())
end

M.tabedit = function(paths)
  local path = paths[tonumber(fn.line("."))]
  cmd("tabe " .. path:absolute())
end

M.up = function(paths)
  local cwd = paths.cwd
  if cwd:absolute() == cwd.path.root() then
    return
  end
  local parent = cwd:parent()
  if parent == cwd.path.root() then
    return
  end
  local old = cwd:make_relative(parent:absolute())
  vim.cmd("e " .. parent.filename)
  if parent.filename == cwd.path.root() then
    vim.cmd("do BufEnter")
  end
  fn.search([[\v^\V]] .. paths.icon .. old .. [[/\v$]], "c")
end

M.home = function(paths)
  vim.cmd("e " .. paths.cwd.path.home)
end

M.reload = function(_)
  if fn.bufname() == "" then
    print("No file name")
  else
    vim.b.prev_filetype = "filittle"
    vim.cmd("e")
  end
end

M.toggle_hidden = function(_)
  vim.b.filittle_show_hidden = not vim.b.filittle_show_hidden
  M.reload()
end

M.touch = function(paths)
  local name = fn.input("Create file: ")
  local cwd = paths.cwd
  cwd:joinpath(name):touch()
  M.reload()
end

M.mkdir = function(paths)
  local name = fn.input("Create directory: ")
  local cwd = paths.cwd
  cwd:joinpath(name):mkdir()
  M.reload()
end

M.delete = function(paths)
  local path = paths[tonumber(fn.line("."))]
  local conf = fn.confirm("Delete?: " .. path.filename, "&Yes\n&No", 2)
  if conf == 2 then
    return
  end
  path:rm(path:is_dir() and { recursive = true } or {})
  M.reload()
end

M.rename = function(paths)
  local old = paths[fn.line(".")]
  local new = fn.input("Rename: ", old.filename)
  old:rename({ new_name = paths.cwd:joinpath(new):absolute() })
  M.reload()
end

return M
