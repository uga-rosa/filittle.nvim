local M = {}
local fn, api = vim.fn, vim.api

local name = function(base, v)
  local type, name = v.type, v.name
  if type == "link" or type == "junction" then
    if fn.isdirectory(fn.resolve(base .. name)) then
      type = "dir"
    end
  elseif type == "linkd" then
    type = "dir"
  end
  return name .. (type == "dir" and "/" or "")
end

local sort = function(obj)
  local dirs, files = {}, {}
  for _, v in ipairs(obj) do
    if v:find("/$") then
      dirs[#dirs + 1] = v
    else
      files[#files + 1] = v
    end
  end
  for _, v in ipairs(files) do
    dirs[#dirs + 1] = v
  end
  return dirs
end

M.init = function()
  local path = fn.expand("%:p")
  if vim.bo.buftype ~= "" then
    return
  end
  if fn.isdirectory(path) == 0 then
    return
  elseif not path:find("/$") then
    path = path .. "/"
  end
  vim.bo.modifiable = true
  vim.bo.filetype = "filittle"
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.wo.wrap = false
  vim.wo.cursorline = true
  local files = {}
  for _, v in ipairs(fn.readdir(path, 1)) do
    files[#files + 1] = name(path, { type = fn.getftype(path .. "/" .. v), name = v })
  end
  if not (vim.b.filittle_show_hidden or vim.g.filittle_show_hidden) then
    vim.tbl_filter(function(file)
      return file:find("^[^%.]") and true or false
    end, files)
  end
  files = sort(files)
  api.nvim_buf_set_lines(0, 0, -1, true, files)
  vim.bo.modifiable = false
end

return M
