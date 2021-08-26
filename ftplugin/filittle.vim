nnoremap <Plug>(filittle-open)          <cmd>lua require("filittle.operator").open()<cr>
nnoremap <Plug>(filittle-reload)        <cmd>lua require("filittle.operator").reload()<cr>
nnoremap <Plug>(filittle-up)            <cmd>lua require("filittle.operator").up()<cr>
nnoremap <Plug>(filittle-toggle_hidden) <cmd>lua require("filittle.operator").toggle_hidden()<cr>
nnoremap <Plug>(filittle-newdir)        <cmd>lua require("filittle.operator").newdir()<cr>

nmap <buffer><nowait> <cr> <Plug>(filittle-open)
nmap <buffer><nowait> R    <Plug>(filittle-reload)
nmap <buffer><nowait> h    <Plug>(filittle-up)
nmap <buffer><nowait> +    <Plug>(filittle-toggle_hidden)
nmap <buffer><nowait> nd   <Plug>(filittle-newdir)
