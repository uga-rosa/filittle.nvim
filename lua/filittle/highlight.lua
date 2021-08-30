local M = {}

local api = vim.api

M.init = function(paths)
  local dir_hl = "FilittleDir"
  local link_hl = "FilittleLink"
  vim.cmd(("highlight %s guifg=#82aaff"):format(dir_hl))
  vim.cmd(("highlight %s guifg=#7fdbca"):format(link_hl))

  local ns = api.nvim_create_namespace("filittle")
  api.nvim_buf_clear_namespace(0, ns, 0, -1)

  if paths.devicons then
    local ICON_WIDTH = #paths.diricon
    for i, path in ipairs(paths) do
      if vim.endswith(path.display, "/") then
        local hlname = path:is_link() and link_hl or dir_hl
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 0, -1)
      else
        api.nvim_buf_add_highlight(0, ns, path.hlname, i - 1, 0, ICON_WIDTH - 1)
        if path:is_link() then
          api.nvim_buf_add_highlight(0, ns, link_hl, i - 1, ICON_WIDTH, -1)
        end
      end
    end
  else
    for i, path in ipairs(paths) do
      if path:is_dir() then
        local hlname = path:is_link() and link_hl or dir_hl
        api.nvim_buf_add_highlight(0, ns, hlname, i - 1, 0, -1)
      end
    end
  end
end

return M
