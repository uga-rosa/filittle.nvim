local utils = {}
local api, cmd = vim.api, vim.cmd

utils.lua2vim = function(func)
  if not _G.myluafunc then
    _G.myluafunc = setmetatable({}, {
      __call = function(self, idx)
        return self[idx]()
      end,
    })
  end
  local idx = #_G.myluafunc + 1
  _G.myluafunc[idx] = func
  return "v:lua.myluafunc(" .. idx .. ")"
end

utils.t = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

utils.autocmd = function(autocmd)
  if type(autocmd[#autocmd]) == "function" then
    autocmd[#autocmd] = "call " .. utils.lua2vim(autocmd[#autocmd])
  end
  local command = table.concat(vim.tbl_flatten({ "au", autocmd }), " ")
  cmd(command)
end

utils.augroup = function(group, autocommands)
  cmd("augroup " .. group)
  cmd("au!")
  for _, autocmd in ipairs(autocommands) do
    utils.autocmd(autocmd)
  end
  cmd("augroup END")
end

utils.eval = function(inStr)
  return assert(load(inStr))()
end

utils.set = {}

utils.set.diff = function(self, arr)
  local result = setmetatable({}, { __index = table })
  for _, v in ipairs(self) do
    if not vim.tbl_contains(arr, v) then
      result:insert(v)
    end
  end
  return result
end

utils.set.new = function(arr)
  return setmetatable(arr, { __index = utils.set })
end

return utils
