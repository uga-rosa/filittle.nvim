function! s:shutup_netrw() abort
  if exists("#FileExplorer")
    au! FileExplorer *
  endif
endfunction

augroup filittle
  au!
  au VimEnter * call s:shutup_netrw()
  au BufEnter * lua require("filittle").init()
  au BufLeave * let b:filittle_prev_filetype = &filetype
augroup END
