local M = {}

local fn = vim.fn
local api = vim.api

local Path = require("filittle.path")
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
  return lhs.filename < rhs.filename
end

M.init = function()
  local cwd = Path:new(fn.expand("%:p"))

  if not cwd:is_dir() or fn.bufname() == "" then
    return
  end

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

  local hidden = vim.g.filittle_show_hidden or vim.b.filittle_show_hidden
  local paths = vim.tbl_map(function(path)
    path.display = path._name
    if path:is_dir() then
      path.display = path.display .. "/"
    end
    return path
  end, cwd:scandir(
    hidden
  ))

  table.sort(paths, sort)

  local opts = {}
  opts.paths = paths
  opts.cwd = cwd
  opts.devicons = settings.devicons

  opts = devicons.init(opts)

  local display = vim.tbl_map(function(path)
    return path.display
  end, opts.paths)
  api.nvim_buf_set_lines(0, 0, -1, true, display)

  vim.bo.modifiable = false

  hl.init(opts)

  mapping.init(opts, settings.mappings)
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
end

return M
