local M = {}

local Devicons = require("nvim-web-devicons")

M.init = function(opts)
    if not opts.devicons then
        opts.diricon = ""
        return opts
    end
    for _, path in ipairs(opts.paths) do
        local icon, hlname
        if path:is_dir() then
            icon = ""
        else
            local filename = path.display
            local ext = filename:match("%.(%w-)$")
            icon, hlname = Devicons.get_icon(filename, ext, { default = true })
        end
        path.display = string.format("%s %s", icon, path.display)
        path.hlname = hlname
    end
    opts.diricon = " "
    return opts
end

return M
