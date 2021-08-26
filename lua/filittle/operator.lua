local M = {}
local fn = vim.fn

local cword = function()
  local line = fn.getline(".")
  local idx = vim.b.filittle_devicon and vim.str_byteindex(line, 1) + 2 or 1
  local name = string.sub(line, idx)
  return fn.fnameescape(string.match(name, "^(.-)/?$"))
end

M.open = function()
  vim.cmd("e " .. vim.b.filittle_dir .. cword())
end

M.reload = function()
  vim.cmd("e")
end

M.up = function()
  local path = string.match(vim.b.filittle_dir, "^(.*)/$")
  local name = fn.fnamemodify(path, ":t")
  if name == "" then
    return
  end
  path = fn.fnamemodify(vim.b.filittle_dir, ":p:h:h")
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

M.errmsg = function(msg)
  vim.cmd("redraw")
  vim.cmd("echohl Error")
  print(msg)
  vim.cmd("echohl None")
end

M.newdir = function()
  local name = fn.input("Create directory: ")
  if not name or name == "" then
    return
  end
  if vim.tbl_contains({ ".", "..", "/", "\\" }, name) then
    M.errmsg("Invalid directory name: " .. name)
    return
  end
  if vim.fn.mkdir(vim.b.filittle_dir .. name) == 0 then
    M.errmsg("Create directory failed")
    return
  end
  M.reload()
end

M.newfile = function()
  local name = fn.input("Create file: ")
  if not name or name == "" then
    return
  end
  if vim.tbl_contains({ ".", "..", "/", "\\" }, name) then
    M.errmsg("Invalid file name: " .. name)
    return
  end
  local res, _ = os.execute("touch " .. vim.b.filittle_dir .. name)
  if not res then
    M.errmsg("Create file failed")
    return
  end
  M.reload()
end

M.delete = function()
  local name = cword()
  local conf = fn.confirm("Delete?: " .. name, "&Yes\n&No\n&Force", 2)
  if conf == 2 then
    return
  end
  local path = vim.b.filittle_dir .. name
  if fn.isdirectory(path) == 1 then
    local flag = conf == 1 and "d" or "rf"
    if fn.delete(path, flag) == -1 then
      M.errmsg("Delete directory failed")
      return
    end
  else
    if fn.delete(path) == -1 then
      M.errmsg("Delete file failed")
      return
    end
  end
  M.reload()
end

M.rename = function()
  local old = cword()
  local new = fn.input("Rename: ", old)
  if vim.tbl_contains({ "", old }, new) then
    return
  elseif vim.tbl_contains({ ".", "..", "/", "\\" }, new) then
    M.errmsg("Invalid name: " .. new)
    return
  end
  local path = vim.b.filittle_dir
  if fn.rename(path .. old, path .. new) ~= 0 then
    M.errmsg("Rename failed")
    return
  end
  M.reload()
end

return M
