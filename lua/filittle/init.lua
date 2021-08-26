local M = {}
local fn, api = vim.fn, vim.api

local sort = function(base, objs)
  local dirs, files = {}, {}
  for _, v in ipairs(objs) do
    local path = base .. v
    local type = fn.getftype(path)
    if type == "dir" then
      dirs[#dirs + 1] = v .. "/"
    elseif type == "file" then
      files[#files + 1] = v
    elseif type == "link" then
      if fn.isdirectory(fn.resolve(path)) then
        dirs[#dirs + 1] = v .. "/"
      elseif fn.filereadable(fn.resolve(path)) then
        files[#files + 1] = v
      end
    end
  end
  for _, v in ipairs(files) do
    dirs[#dirs + 1] = v
  end
  return dirs
end

M.init = function()
  local path = fn.resolve(fn.expand("%:p"))
  if fn.isdirectory(path) == 0 then
    return
  elseif not string.match(path, "/$") then
    path = path .. "/"
  end
  vim.b.filittle_dir = path
  vim.bo.modifiable = true
  vim.bo.filetype = "filittle"
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "unload"
  vim.bo.buflisted = false
  vim.wo.wrap = false
  vim.wo.cursorline = true
  local objs = sort(path, fn.readdir(path, 1))
  if not (vim.b.filittle_show_hidden or vim.g.filittle_show_hidden) then
    objs = vim.tbl_filter(function(obj)
      return string.match(obj, "^[^%.]") and true or false
    end, objs)
  end
  api.nvim_buf_set_lines(0, 0, -1, true, objs)
  vim.bo.modifiable = false
end

return M
