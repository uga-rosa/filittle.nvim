local M = {}

local Devicons = require("nvim-web-devicons")

M.setup = function()
  Devicons.setup({
    override = {
      ["filittle_dir"] = {
        icon = "",
        color = "#82aaff",
        name = "Filittle_dir",
      },
    },
  })
end

M.init = function(paths, names)
  local hlnames = {}
  for i, path in ipairs(paths) do
    if path:is_dir() then
      local icon, hlname = Devicons.get_icon("filittle_dir", "")
      names[i] = icon .. " " .. names[i]
      hlnames[i] = hlname
    elseif path:is_file() then
      local obj = names[i]
      local ext = obj:match("%.(%w-)$")
      local icon, hlname = Devicons.get_icon(obj, ext)
      names[i] = icon .. " " .. names[i]
      hlnames[i] = hlname
    end
  end
  return names, hlnames
end

return M
