# filittle.nvim

A simple and fast file explorer for neovim written in Lua (optional support for devicons).

## Required

- neovim 0.5+
- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) (optional)

## Usage

This disables and replaces the default file explorer (netrw).

Of cource, you can also use `<C-o>` and `<C-i>` to jump.

## Setup

```lua
local options = {
  -- your config
}
require("filittle").setup(options)
```

Option to set it up.
- `devicons`: If true, use devicons.
- `disable_mapping`: if true, default mappings are disabled.
- `mappings`: table (key: lhs, value: a built-in function or a function defined by you)
- `show_hidden`: if true, hidden files/directories will always be displayed.

The built-in function can be specified as a string. [See here](#buitlin-function)

There is no need to call setup if you are using the default settings.

Default settings
```lua
local default_settigns = {
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
  show_hidden = false,
}
```

## Buitlin function

- `open`: Open a file or move to a directory.
- `split`: Open in split window.
- `vsplit`: Open in vertical split window.
- `tabedit`: Open in new tab.
- `up`: Move to parent directory.
- `home`: Move to home directory (like `cd ~`).
- `toggle_hidden`: Toggles the display of hidden files.
- `reload`: Redraw the screen.
- `touch`: Create a new file.
- `mkdir`: Create a new directory.
- `delete`: Delete a file or directory
- `rename`: Rename a file or directory
