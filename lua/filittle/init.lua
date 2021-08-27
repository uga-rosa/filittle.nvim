local M = {}
local fn, api = vim.fn, vim.api

local sort = function(base, objs, devicon)
  local dirs, files = {}, {}
  for _, v in ipairs(objs) do
    local path = base .. v
    local type = fn.getftype(path)
    if type == "dir" then
      v = v .. "/"
      dirs[#dirs + 1] = v
      vim.cmd("syntax keyword filittleDir " .. v)
    elseif type == "file" then
      files[#files + 1] = v
    elseif type == "link" then
      if fn.isdirectory(fn.resolve(path)) == 1 then
        v = v .. "/"
        dirs[#dirs + 1] = v
      elseif fn.filereadable(fn.resolve(path)) then
        files[#files + 1] = v
      end
      vim.cmd("syntax keyword filittleLink " .. v)
    end
  end
  vim.cmd("highlight link filittleDir NightflyBlue")
  vim.cmd("highlight link filittleLink NightflyTurquoise")

  if not (vim.b.filittle_show_hidden or vim.g.filittle_show_hidden) then
    dirs = vim.tbl_filter(function(dir)
      return string.match(dir, "^[^%.]") and true or false
    end, dirs)
    files = vim.tbl_filter(function(file)
      return string.match(file, "^[^%.]") and true or false
    end, files)
  end

  if devicon then
    vim.cmd("syntax keyword filittleDirIcon ")
    vim.cmd("highlight link filittleDirIcon NightflyBlue")
    dirs = vim.tbl_map(function(dir)
      return " " .. dir
    end, dirs)
    local dev = require("nvim-web-devicons")
    for i, v in ipairs(files) do
      local icon, hlname = dev.get_icon(v, fn.fnamemodify(v, ":e"), { default = true })
      files[i] = icon .. " " .. v
      vim.cmd("syntax keyword " .. hlname .. " " .. icon)
    end
  end
  vim.b.current_syntax = "filittle"

  for _, v in ipairs(files) do
    dirs[#dirs + 1] = v
  end
  return dirs
end

local defaults = {
  open = { "<cr>", "l", "o" },
  reload = "R",
  up = "h",
  home = "~",
  toggle_hidden = "+",
  newdir = "nd",
  newfile = "nf",
  delete = "d",
  rename = "r",
}

M.init = function()
  local path = fn.resolve(fn.expand("%:p"))
  if fn.isdirectory(path) == 0 then
    return
  elseif not string.match(path, "/$") then
    path = path .. "/"
  end

  vim.b.filittle_dir = path
  vim.opt_local.modifiable = true
  vim.opt_local.filetype = "filittle"
  vim.opt_local.buftype = "nofile"
  vim.opt_local.bufhidden = "unload"
  vim.opt_local.buflisted = false
  vim.opt_local.wrap = false
  vim.opt_local.iskeyword:append({ ".", "/" })

  if vim.g.nvim_web_devicons then
    vim.b.filittle_devicon = true
  end

  local objs = sort(path, fn.readdir(path, 1), vim.b.filittle_devicon)
  api.nvim_buf_set_lines(0, 0, -1, true, objs)
  vim.bo.modifiable = false

  local map = vim.api.nvim_buf_set_keymap
  local opt = { noremap = true, nowait = true }
  for rhs, v in pairs(defaults) do
    v = type(v) == "string" and { v } or v
    for _, lhs in ipairs(v) do
      map(0, "n", lhs, '<cmd>lua require("filittle.operator").' .. rhs .. "()<cr>", opt)
    end
  end
end

M.shutup_netrw = function()
  if fn.exists("#FileExplorer") then
    vim.cmd([[au! FileExplorer *]])
  end
end

M.setup = function(mappings)
  defaults = mappings or defaults
  vim.cmd([[
augroup filittle
  au!
  au VimEnter * lua require("filittle").shutup_netrw()
  au BufEnter * lua require("filittle").init()
augroup END
]])
end

return M
