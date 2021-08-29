# filittle.nvim

A simple and fast file explorer for neovim written in Lua (optional support for devicons).

Note: filittle.nvim doesn't provide default mappings.

## Required

- neovim 0.5+
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) (optional)

## Usage

This disables and replaces the default file explorer (netrw).

Of cource, you can also use `<C-o>` and `<C-i>` to jump.

## Setup

Option to set it up.
- devicons: boolen (whether to enable nvim-web-devicons)
- mappings: table (key: lhs, value: a built-in function or a function defined by you)

The built-in function can be specified as a string. [See here](#buitlin-function)

Exanple
```lua
require("filittle").setup({
  devicons = true,
  mappings = {
    ["<cr>"] = "open",
    ["l"] = "open",
    ["<C-x>"] = "split",
    ["<C-v>"] = "vsplit",
    ["<C-t>"] = "tabedit",
    ["h"] = "up",
    ["~"] = "home",
    ["R"] = "reload",
    ["+"] = "toggle_hidden",
    ["t"] = "touch",
    ["m"] = "mkdir",
    ["d"] = "delete",
    ["r"] = "rename",
  },
})
```

## Buitlin function

- `open`: Open a file or move to a directory.
- `split`: Open in split window.
- `vsplit`: Open in vertical split window.
- `tabedit`: Open in new tab.
- `reload`: Redraw the screen.
- `up`: Move to parent directory.
- `home`: Move to home directory (like `cd ~`).
- `toggle_hidden`: Toggles the display of hidden files.
- `touch`: Create a new file.
- `mkdir`: Create a new directory.
- `delete`: Delete a file or directory
- `rename`: Rename a file or directory

## Global options

- Always show hidden files.

```lua
vim.g.filittle_show_hidden = true -- Anything but false or nil
```
