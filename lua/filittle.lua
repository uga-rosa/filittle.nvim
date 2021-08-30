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
  if lhs:is_dir() and not rhs:is_dir() then
    return true
  elseif not lhs:is_dir() and rhs:is_dir() then
    return false
  end
  if lhs.filename < rhs.filename then
    return true
  else
    return false
  end
end

M.init = function()
  local Path = require("plenary.path")
  local scan = require("plenary.scandir")

  local cwd = Path:new(fn.expand("%"))
  if not cwd:is_dir() or fn.bufname() == "" then
    return
  end
  cwd.filename = cwd:absolute()

  if vim.bo.buftype ~= "" and vim.b.filittle_prev_filetype ~= "filittle" then
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
    path.filename = path:make_relative(cwd.filename)
    path.display = path:is_dir() and path.filename .. "/" or path.filename
    return path
  end, scan.scan_dir(
    cwd.filename,
    scan_opt
  ))

  table.sort(paths, sort)

  paths.cwd = cwd
  paths.devicons = settings.devicons

  paths = devicons.init(paths)

  local display = vim.tbl_map(function(path)
    return type(path) == "table" and path.display or nil
  end, paths)
  api.nvim_buf_set_lines(0, 0, -1, true, display)

  vim.bo.modifiable = false

  hl.init(paths)

  mapping.init(paths, settings.mappings)
end

M.shutup_netrw = function()
  if fn.exists("#FileExplorer") then
    vim.cmd([[au! FileExplorer *]])
  end
end

M.setup = function(opts)
  _G._filittle_ = setmetatable({}, {
    __call = function(self, num)
      return self[num]()
    end,
  })
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
  au BufLeave * let b:filittle_prev_filetype = &filetype
augroup END
]])
end

return M
