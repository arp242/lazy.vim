nnoremap <Plug>(lazy-insert-cword)      :call lazy#insert_cword()<CR>
inoremap <Plug>(lazy-insert-cword) <C-o>:call lazy#insert_cword()<CR>

if !mapcheck('<C-s>', 'n') && !hasmapto('<Plug>(lazy-insert-cword)', 'n')
	nmap <C-s> <Plug>(lazy-insert-cword)
endif
if !mapcheck('<C-s>', 'i') && !hasmapto('<Plug>(lazy-insert-cword)', 'i')
	imap <C-s> <Plug>(lazy-insert-cword)
endif

command! Lazy call lazy#list(1)
