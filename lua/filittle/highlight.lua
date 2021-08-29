local M = {}

local api = vim.api
local Devicons = require("nvim-web-devicons")
local ICON_WIDTH = #Devicons.get_icon("", "", { default = true })

local ns = api.nvim_create_namespace("filettle")

M.init = function(names, hlnames, devicons)
  api.nvim_buf_clear_namespace(0, ns, 1, -1)
  if devicons then
    for i, path in ipairs(names) do
      if path:is_dir() then
        local hlname = hlnames[i]
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 1, -1)
      elseif path:is_file() then
        local hlname = hlnames[i]
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 1, ICON_WIDTH)
      else
      end
    end
  else
    vim.cmd("highlight FilittleDir guifg=#82aaff")
    local hlname = "FilittleDir"
    for i, name in ipairs(names) do
      if vim.endswith(name, "/") then
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 1, -1)
      end
    end
  end
end

return M
