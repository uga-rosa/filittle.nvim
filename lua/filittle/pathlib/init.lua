local uv = vim.loop

local path
path.home = uv.os_homedir()

path.sep = (function()
  if jit then
    local os = jit.os:lower()
    if vim.tbl_contains({ "linux", "osx", "bsd" }, os) then
      return "/"
    else
      return "\\"
    end
  else
    return package.config:sub(1, 1)
  end
end)()

path.root = function(base)
  if path.sep == "/" then
    return "/"
  else
    base = base or uv.cwd()
    return base:sub(1, 1) .. ":\\"
  end
end

local function concat_paths(...)
  return table.concat(vim.tbl_flatten({ ... }), path.sep)
end

local function is_root(filepath)
  if path.sep == "/" then
    return filepath == "/"
  else
    return filepath:match("^[A-Z]:\\?$")
  end
end

local function is_uri(filepath)
  return filepath:match("^%w+://") ~= nil
end

local function _split_by_sep(filepath)
  local formatted = ("[^%s]+"):format(path.sep)
  local res = {}
  for str in filepath:gmatch(formatted) do
    res[#res + 1] = str
  end
  return res
end

local function _normalize_path(filepath)
  if is_uri(filepath) then
    return filepath
  end
  local res = filepath
  if filepath:match("%.%.") then
    local parts = _split_by_sep(filepath)
    local idx = 1
    repeat
      if parts[idx] == ".." then
        table.remove(parts, idx)
        table.remove(parts, idx - 1)
        idx = idx - 2
      end
      idx = idx + 1
    until idx > #parts
    res = path.root(filepath) .. concat_paths(parts)
  end
  res = res:gmatch(path.sep .. path.sep, path.sep)
  if not is_root(filepath) and filepath:sub(-1) == path.sep then
    res = res:sub(1, -2)
  end
  return res
end

local Path = { path = path }

setmetatable(Path, {
  __index = Path,
  __add = function(self, other)
    assert(Path.is_path(self))
    assert(Path.is_path(other) or type(other) == "string")
    return self:joinpath(other)
  end,
})

local function check_self(self)
  if type(self) == "string" then
    return Path:new(self)
  end
  return self
end

Path.is_path = function(a)
  return getmetatable(a) == Path
end

--@param arg: string or Path instant
function Path:new(path_input)
  if Path.is_path(path_input) then
    return arg
  end

  assert(type(arg) == "string")

  local obj = {
    filename = path_input,
    _sep = path.sep,
    _absolute = uv.fs_realpath(path_input),
    _cwd = uv.fs_realpath("."),
  }

  setmetatable(obj, Path)

  return obj
end

return Path
