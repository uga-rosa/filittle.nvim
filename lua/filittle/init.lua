local M = {}

local fn = vim.fn
local api = vim.api

local Path = require("filittle.path")
local hl = require("filittle.highlight")
local devicons = require("filittle.devicons")
local mapping = require("filittle.mapping")

local default_settings = {
  devicons = true,
  mappings = {
    ["<cr>"] = "open",
    ["l"] = "open",
    ["<C-x>"] = "split",
    ["<C-v>"] = "vsplit",
    ["<C-t>"] = "tabedit",
    ["h"] = "up",
    ["~"] = "home",
    ["R"] = "reload",
    ["+"] = "toggle_hidden",
    ["t"] = "touch",
    ["m"] = "mkdir",
    ["d"] = "delete",
    ["r"] = "rename",
  },
  show_hidden = false,
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
  if fn.bufname() == "" then
    return
  end

  local cwd = Path:new(fn.expand("%:p"))

  if not cwd:is_dir() then
    return
  end

  vim.opt_local.modifiable = true
  vim.opt_local.filetype = "filittle"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.bufhidden = "unload"
  vim.opt_local.buflisted = false
  vim.opt_local.wrap = false
  vim.opt_local.swapfile = false

  local hidden = default_settings.show_hidden or vim.w.filittle_show_hidden
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
  opts.devicons = default_settings.devicons

  opts = devicons.init(opts)

  local display = vim.tbl_map(function(path)
    return path.display
  end, opts.paths)
  api.nvim_buf_set_lines(0, 0, -1, true, display)

  vim.bo.modifiable = false

  hl.init(opts)

  mapping.init(opts, default_settings.mappings)
end

M.setup = function(opts)
  opts = opts or {}

  if opts.disable_mapping then
    default_settings.mappings = {}
  end

  for k, v in pairs(opts) do
    default_settings[k] = v
  end
end

return M
