local M = {}

local api = vim.api

M.init = function(paths)
  local ns = api.nvim_create_namespace("filittle")
  api.nvim_buf_clear_namespace(0, ns, 0, -1)

  if paths.devicons then
    local ICON_WIDTH = #require("nvim-web-devicons").get_icon("", "", { default = true })
    for i, path in ipairs(paths) do
      local col_end = path:is_dir() and -1 or ICON_WIDTH
      api.nvim_buf_add_highlight(0, ns, path.hlname, i - 1, 0, col_end)
    end
  else
    local hlname = "FilittleDir"
    vim.cmd(string.format("highlight %s guifg=#82aaff", hlname))
    for i, path in ipairs(paths) do
      if path:is_dir() then
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 0, -1)
      end
    end
  end
end

return M
