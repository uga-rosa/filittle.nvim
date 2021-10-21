local path = {}

local uv = vim.loop

path.sep = (function()
  local os = string.lower(jit.os)
  if vim.tbl_contains({ "linux", "osx" }, os) then
    return "/"
  else
    return "\\"
  end
end)()

path.root = (function()
  if path.sep == "/" then
    return "/"
  else
    return uv.cwd():sub(1, 1) .. ":\\"
  end
end)()

path.home = (function()
  return uv.os_homedir()
end)()

local Path = {
  path = path,
}

function Path:new(pathname)
  if pathname ~= path.root and vim.endswith(pathname, path.sep) then
    pathname = pathname:sub(1, -2)
  end
  local last_sep = -pathname:reverse():find(path.sep)
  local parent = pathname:sub(1, last_sep)
  local name = pathname:sub(last_sep + 1)
  return setmetatable({
    filename = pathname,
    _sep = path.sep,
    _absolute = uv.fs_realpath(pathname),
    _parent = parent,
    _name = name,
  }, {
    __index = Path,
  })
end

function Path:_stat()
  return uv.fs_stat(self.filename)
end

function Path:_lstat()
  return uv.fs_lstat(self.filename)
end

function Path:exists()
  return self:_stat() and true or false
end

function Path:type()
  if not self:exists() then
    return
  end
  return self:_stat().type
end

function Path:ltype()
  if not self:exists() then
    return
  end
  return self:_lstat().type
end

function Path:is_dir()
  return self:type() == "directory"
end

function Path:is_link()
  return self:ltype() == "link"
end

function Path:mkdir()
  if self:exists() then
    print("Already exists: " .. self.filename)
  end
  if vim.fn.mkdir(self.filename) == 1 then
    return true
  else
    error("Couldn't create directory: " .. self.filename)
  end
end

-- This is different from the original touch, which simply creates a new file.
function Path:touch()
  if self:exists() then
    print("Already exists: " .. self.filename)
  end
  local fd = uv.fs_open(self.filename, "w", 420)
  if not fd then
    error("Couldn't create file: " .. self.filename)
  end
  uv.fs_close(fd)
  return true
end

function Path:delete()
  if not self:exists() then
    print("Doesn't exist: " .. self.filename)
  end
  local obj = self:type()
  local flag = obj == "directory" and "rf" or ""
  if vim.fn.delete(self.filename, flag) == 0 then
    return true
  else
    error(("Couldn't delete %s: %s"):format(obj, self.filename))
  end
end

function Path:rename(newname)
  if not newname then
    error("No new name.")
  end
  local newpath = Path:new(self._parent .. newname)
  if newpath:exists() then
    error("Already exists: " .. newpath)
  end
  if vim.fn.rename(self.filename, newpath.filename) == 0 then
    return true
  else
    error(("Couldn't rename from: %s, to: %s"):format(self.filename, newpath.filename))
  end
end

function Path:joinpath(name)
  if self.filename == self.path.root then
    return Path:new(self.filename .. name)
  end
  return Path:new(self.filename .. self._sep .. name)
end

function Path:scandir(show_hidden)
  local data = {}
  local fd = uv.fs_scandir(self.filename)
  if fd then
    while true do
      local name = uv.fs_scandir_next(fd)
      if not name then
        break
      end
      if show_hidden or name:sub(1, 1) ~= "." then
        data[#data + 1] = self:joinpath(name)
      end
    end
  end
  return data
end

return Path
