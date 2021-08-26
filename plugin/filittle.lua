if vim.g.loaded_filittle then
  return
end
vim.g.loaded_filittle = true

vim.cmd([[
au! FileExplorer *
augroup _filettle_
  au!
  au BufEnter * lua require("filittle").init()
augroup END
]])
