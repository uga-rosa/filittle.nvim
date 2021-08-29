local M = {}
local fn, api = vim.fn, vim.api
local Path = require("plenary.path")
local scan = require("plenary.scandir")
local hl = require("filittle.highlight")
local action = require("filittle.action")
local devicons = require("filittle.devicons")

local settings = {
  devicons = false,
  mappings = {
    ["<cr>"] = action.open(),
    ["R"] = action.reload(),
    ["h"] = action.up(),
    ["~"] = action.home(),
    ["+"] = action.toggle_hidden(),
    ["nd"] = action.mkdir(),
    ["nf"] = action.touch(),
    ["d"] = action.delete(),
    ["r"] = action.rename(),
  },
}

local sort = function(lhs, rhs)
  return lhs:is_dir() and not rhs:is_dir()
end

local lua2rhs = function(func, cwd, paths, dev)
  local idx = #_G._filittle_ + 1
  _G._filittle_[idx] = function()
    func(cwd, paths, dev)
  end
  return string.format("<cmd>lua _G._filittle_[%d]()<cr>", idx)
end

local map_local = function(cwd, paths)
  local dev, map = settings.devicons, settings.mappings
  local map_local = api.nvim_buf_set_keymap
  local map_opt = { noremap = true }
  for lhs, func in pairs(map) do
    map_local(0, "n", lhs, lua2rhs(func, cwd, paths, dev), map_opt)
  end
end

M.init = function()
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
  vim.opt_local.iskeyword:append({ ".", "/" })

  local scan_opt = {
    hidden = vim.g.filittle_show_hidden or vim.b.filittle_show_hidden,
    add_dirs = true,
    depth = 1,
    silent = true,
  }
  local paths = vim.tbl_map(function(path)
    return Path:new(path)
  end, scan.scan_dir(
    cwd:absolute(),
    scan_opt
  ))

  table.sort(paths, sort)
  print(vim.inspect(paths))

  local names = vim.tbl_map(function(path)
    local obj = path:make_relative(cwd)
    return path:is_dir() and obj .. "/" or obj
  end, paths)

  local hlnames
  if settings.devicons then
    names, hlnames = devicons.init(paths, names)
  end

  hl.init(names, hlnames, settings.devicons)

  api.nvim_buf_set_lines(0, 0, -1, true, names)
  vim.bo.modifiable = false

  paths = vim.tbl_map(function(path)
    return path:absolute()
  end, paths)

  map_local(cwd, paths)
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

  if not pcall(require, "plenary") then
    print("[plenary.nvim] is required")
    return
  end

  if settings.devicons then
    if not pcall(require, "nvim-web-devicons") then
      print("[nvim-web-devicons] is not installed.")
      return
    end
    devicons.setup()
  end

  vim.cmd([[
augroup filittle
  au!
  au VimEnter * lua require("filittle").shutup_netrw()
  au BufEnter * lua require("filittle").init()
augroup END
]])
end

return M
