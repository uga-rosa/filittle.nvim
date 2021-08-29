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
  for _, path in ipairs(paths) do
    if path:is_dir() then
      local icon, hlname = Devicons.get_icon("filittle_dir", "")
      path.display = string.format("%s %s", icon, path.display)
      path.hlname = hlname
    else
      local obj = path.display
      local ext = obj:match("%.(%w-)$")
      local icon, hlname = Devicons.get_icon(obj, ext, { default = true })
      path.display = string.format("%s %s", icon, path.display)
      path.hlname = hlname
    end
  end
  paths.icon = Devicons.get_icon("filittle_dir", "") .. " "
  return paths
end

return M
