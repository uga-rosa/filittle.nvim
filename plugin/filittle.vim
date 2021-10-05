if exists('g:loaded_filittle')
  finish
endif
let g:loaded_filittle = 1

function! s:shutup_netrw() abort
  if exists('#FileExplorer')
    au! FileExplorer *
  endif
endfunction

augroup filittle
  au!
  au VimEnter * call s:shutup_netrw()
  au BufEnter * lua require("filittle").init()
  au User filittle lua require("filittle").init()
augroup END
