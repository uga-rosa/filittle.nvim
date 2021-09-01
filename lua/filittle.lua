local M = {}

local fn = vim.fn
local api = vim.api
local uv = vim.loop

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
  local Path = require("plenary.path")
  local scan = require("plenary.scandir")

  function Path:_name()
    return self.filename:match(("([^%s]+)%s?$"):format(self._sep, self._sep))
  end

  function Path:is_link()
    local res = uv.fs_lstat(self.filename)
    if res then
      return res.type == "link"
    end
  end

  function Path:_rm(opts)
    if self:is_link() then
      uv.fs_unlink(self.filename)
    else
      self:rm(opts)
    end
  end

  function Path:_rename(opts)
    opts = opts or {}
    if not opts.new_name or opts.new_name == "" then
      error("Please provide the new name!")
    end
    if opts.new_name:match("^%.%.?/?\\?") then
      error("Invalid file name: " .. opts.new_name)
    end
    local new_path = Path:new(opts.new_name)
    if not new_path:is_absolute() then
      new_path.filename = new_path._cwd .. new_path._sep .. new_path.filename
    end
    if new_path:exists() then
      error("File or directory already exists!")
    end
    uv.fs_rename(self.filename, new_path.filename)
  end

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

  local scan_opt = {
    hidden = vim.g.filittle_show_hidden or vim.b.filittle_show_hidden,
    add_dirs = true,
    depth = 1,
    silent = true,
  }

  local paths = vim.tbl_map(function(path)
    path = Path:new(path)
    local name = path:_name()
    path.display = path:is_dir() and name .. "/" or name
    return path
  end, scan.scan_dir(
    cwd._absolute,
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
