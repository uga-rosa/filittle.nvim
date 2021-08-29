local M = {}

local fn, api = vim.fn, vim.api

local hl = require("filittle.highlight")
local devicons = require("filittle.devicons")
local mapping = require("filittle.mapping")

local settings = {
  devicons = false,
  mappings = {},
}

local sort = function(lhs, rhs)
  return lhs:is_dir() and not rhs:is_dir()
end

M.init = function()
  local Path = require("plenary.path")
  local scan = require("plenary.scandir")

  local cwd = Path:new(fn.expand("%"))
  if not cwd:is_dir() then
    return
  end
  cwd.filename = cwd:absolute()

  if vim.bo.buftype ~= "" and vim.b.prev_filetype ~= "filittle" then
    return
  end

  vim.opt_local.modifiable = true
  vim.opt_local.filetype = "filittle"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.bufhidden = "unload"
  vim.opt_local.buflisted = false
  vim.opt_local.wrap = false
  vim.opt_local.swapfile = false

  local scan_opt = {
    hidden = vim.g.filittle_show_hidden or vim.b.filittle_show_hidden,
    add_dirs = true,
    depth = 1,
    silent = true,
  }

  local paths = vim.tbl_map(function(path)
    path = Path:new(path)
    path.filename = path:make_relative(cwd:absolute())
    path.display = path:is_dir() and path.filename .. "/" or path.filename
    return path
  end, scan.scan_dir(
    cwd:absolute(),
    scan_opt
  ))

  table.sort(paths, sort)

  paths.icon = ""
  if settings.devicons then
    paths = devicons.init(paths)
  end

  local display = vim.tbl_map(function(path)
    return path.display
  end, paths)
  api.nvim_buf_set_lines(0, 0, -1, true, display)

  hl.init(paths, settings.devicons)

  vim.bo.modifiable = false

  paths.cwd = cwd
  paths.devicons = settings.devicons
  mapping.init(paths, settings)
end

M.shutup_netrw = function()
  if fn.exists("#FileExplorer") then
    vim.cmd([[au! FileExplorer *]])
  end
end

M.setup = function(opts)
  _G._filittle_ = setmetatable({}, { __index = table })
  opts = opts or {}
  for k, v in pairs(opts) do
    settings[k] = v
  end

  if settings.devicons then
    devicons.setup()
  end

  if vim.fn.has("vim_starting") == 0 then
    M.shutup_netrw()
  end

  vim.cmd([[
augroup filittle
  au!
  au VimEnter * lua require("filittle").shutup_netrw()
  au BufEnter * lua require("filittle").init()
  au BufLeave * let b:prev_filetype = &filetype
augroup END
]])
end

return M
