# filittle.nvim

\* alpha version

A simple and fast file explorer for neovim written in Lua (optional support for devicons).

This disables and replaces the default file explorer (netrw).

## Required

- neovim 0.5+
- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) (optional)

## Setup

Add the following to your init.vim file.

```lua
lua require("filittle").setup()
```

## Feature

- `open`: Open a file or move to a directory.
- `reload`: Redraw the screen.
- `up`: Move to parent directory.
- `home`: Move to home directory (like `cd ~`).
- `toggle_hidden`: Toggles the display of hidden files.
- `newdir`: Create a new directory.
- `newfile`: Create a new file.
- `delete`: Delete a file or directory
- `rename`: Rename a file or directory

Default mappings are below.

```lua
local defaults = {
  open = { "<cr>", "l", "o" },  -- string or array-like table
  reload = "R",
  up = "h",
  home = "~",
  toggle_hidden = "+",
  newdir = "nd",
  newfile = "nf",
  delete = "d",
  rename = "r",
}
```

If you want to change mappings, pass it as an argument to setup.

It won't be merged, so any keys you didn't specify will be disabled.

```lua
lua << EOL
require("filittle").setup({
  open = "<cr>",
  reload = "R",
  up = "h",
  -- home is disabled
  toggle_hidden = "+",
  newdir = "n",
  newfile = "f",
  delete = "d",
  rename = "r",
})
EOL
```

Of cource, you can also use `<C-o>` and `<C-i>` to jump.

## Options

- Always show hidden files.

```vim
let g:filittle_show_hidden = v:true  " Anything but false or nil
```
