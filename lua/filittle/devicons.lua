local M = {}

local Devicons = require("nvim-web-devicons")

M.setup = function()
  Devicons.setup({
    override = {
      ["filittle_dir"] = {
        icon = "",
        color = "#82aaff",
        name = "FilittleDir",
      },
    },
  })
end

M.init = function(paths)
  if not paths.devicons then
    paths.icon = ""
    return paths
  end
  for _, path in ipairs(paths) do
    local icon, hlname
    if path:is_dir() then
      icon, hlname = Devicons.get_icon("filittle_dir", "")
    else
      local filename = path.display
      local ext = filename:match("%.(%w-)$")
      icon, hlname = Devicons.get_icon(filename, ext, { default = true })
    end
    path.display = string.format("%s %s", icon, path.display)
    path.hlname = hlname
  end
  paths.icon = Devicons.get_icon("filittle_dir", "") .. " "
  return paths
end

return M
