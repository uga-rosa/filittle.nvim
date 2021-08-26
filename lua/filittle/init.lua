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

local defaults = {
  mappings = {
    open = { "<cr>", "l", "o" },
    reload = "R",
    up = "h",
    home = "~",
    toggle_hidden = "+",
    newdir = "nd",
    newfile = "nf",
    delete = "d",
    rename = "r",
  },
}

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

  local map = vim.api.nvim_buf_set_keymap
  local opt = { noremap = true }
  for k, v in pairs(defaults.mappings) do
    v = type(v) == "string" and { v } or v
    for _, lhs in ipairs(v) do
      map(0, lhs, '<cmd>lua require("filittle.operator").' .. k .. "()<cr>", opt)
    end
  end
end

M.setup = function(opts)
  opts = opts or {}
  opts.mappings = opts.mappings or {}
  for k, v in pairs(opts.mappings) do
    defaults.mappings[k] = v
  end
  vim.cmd([[
au! FileExplorer *
augroup _filettle_
  au!
  au BufEnter * lua require("filittle").init()
augroup END
]])
end

return M
