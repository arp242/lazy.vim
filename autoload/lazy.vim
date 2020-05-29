scriptversion 3
if exists('g:loaded_lazy')
	finish
endif
let g:loaded_lazy = 1

" Insert text based on <cword>
fun! lazy#insert_cword()
	let snips = get(g:, 'lazy_snippets', '')
	if snips is# '' || len(snips) is 0
		return s:error('no snippets defined (g:lazy_snippets is undefined or empty)')
	endif
	for ft in split(&ft, '\.')
		let snips = get(g:lazy_snippets, ft, '')
		if snips isnot ''
			break
		endif
	endfor
	if snips is# '' || len(snips) is 0
		return s:error('no snippets for this filetype (g:lazy_snippets[%s] is undefined or empty)', &ft)
	endif

	let word = expand('<cword>')
	let snip = get(snips, word, '')
	if snip is# ''
		" TODO: show popup menu with options.
		return s:error('no snippet for "%s"', word)
	endif

	call lazy#insert_text(snip)
endfun

" Insert the text from snip.
fun! lazy#insert_text(snip)
	let snip = a:snip
	if type(a:snip) isnot v:t_list
		let snip = split(a:snip, "\n")
	endif

	" Adjust indentation.
	let indent = matchstr(getline('.'), '^\s*')
	let snip = snip->map({_, v -> indent .. v})

	" Insert the snippet; replace the line if that's all on that.
	if getline('.') =~ '^\s*' .. snip[0] .. '\s*$'
		call setline('.', snip[0])
	else
		" TODO: get line, substitute at correct position. Maybe be smart if
		" what's typed already matches what we would insert?
		call setline('.', snip[0])
	endif
	if len(snip) > 1
		call append('.', snip[1:])
	endif

	" Set cursor position to \b, or the end of the snippet if there is no \b.
	for line in snip
		let c = stridx(line, "\b")
		if c > -1
			exe printf('normal! %dl', c)
			call setline('.', substitute(getline('.'), "\b", '', 'g'))
			break
		endif
		normal! j
	endfor
endfun

" TODO: this doesn't display from insert mode.
fun! s:error(msg, ...)
    let msg = a:msg
    if len(a:000) > 0
      let msg = call('printf', [a:msg] + a:000)
    endif

	echohl Error
	echom 'lazy.vim: ' .. msg
	echohl None
endfun
