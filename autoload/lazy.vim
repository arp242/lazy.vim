scriptversion 3
if exists('g:loaded_lazy')
	finish
endif
let g:loaded_lazy = 1

" List all snippets; if echo is 1 it's printed, or it's returned if it's 0.
fun! lazy#list(echo) abort
	let snips = copy(get(g:, 'lazy_snippets', ''))
	if snips is# '' || len(snips) is 0
		return
	endif
	for ft in split(&ft, '\.')
		let snips = copy(get(g:lazy_snippets, ft, ''))
		if snips isnot ''
			break
		endif
	endfor
	if snips is# '' || len(snips) is 0
		return
	endif

	for [k, v] in items(snips)
		if type(v) is v:t_list
			let v = join(v, "\n")
		endif
		let v = substitute(v, "[\n\x08]", '', 'g')
		let v = substitute(v, "\t", ' ', 'g')
		let v = substitute(v, " \+", ' ', 'g')

		if a:echo
			echo printf('%-10s %s', k, s:left(v, &columns - 15))
		else
			let snips[k] = v
		endif
	endfor
	return snips
endfun

" Insert text based on <cword>
fun! lazy#insert_cword(from_insert) abort
	try
		let snip = s:find_snip(expand('<cword>'))
	catch
		if a:from_insert
			echoerr v:exception
		else
			echohl Error | echom v:exception | echohl None
		endif
		return
	endtry
	if snip isnot# ''
		return lazy#insert_text(snip)
	endif

	" Show list if there's no matches.
	" TODO: better filtering.
	let snips = lazy#list(0)
	if snips is# 0
		return
	endif

	let list = []
	for [k, v] in items(snips)
		call add(list, printf('%-10s %s', k, s:left(v, &columns - 25)))
	endfor

	" TODO: add setting to override the menu; can override anything except
	" callback.
	call popup_menu(list, #{
		\ callback:        {id, result -> s:popup_cb(list, id, result)},
		\ cursorline:      1,
		\ pos:             'topleft',
		\ line:            'cursor+1',
		\ col:             'cursor',
		\ title:           '─ lazy.vim',
		\ padding:         [0, 1, 0, 1],
		\ border:          [],
		\ borderchars:     ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
		\ })
	return
endfun

fun! s:popup_cb(list, id, result) abort
	let snip = split(a:list[a:result - 1], ' ')[0]
	let text = s:find_snip(snip)
	call lazy#insert_text(text)
endfun

" Insert the text from snip.
fun! lazy#insert_text(snip) abort
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

	" Set cursor position to \b.
	for line in snip
		let c = stridx(line, "\b")
		if c > -1
			exe "normal! f\b\"_x"
			break
		endif
	endfor
endfun

" Find snippet text by shortcut.
fun! s:find_snip(word) abort
	let snips = copy(get(g:, 'lazy_snippets', ''))
	if snips is# '' || len(snips) is 0
		throw 'lazy.vim: no snippets defined (g:lazy_snippets is undefined or empty)'
	endif
	for ft in split(&ft, '\.')
		let snips = copy(get(g:lazy_snippets, ft, ''))
		if snips isnot ''
			break
		endif
	endfor
	if snips is# '' || len(snips) is 0
		throw printf('lazy.vim: no snippets for this filetype (g:lazy_snippets[%s] is undefined or empty)', &ft)
	endif
	return get(snips, a:word, '')
endfun

fun! s:left(str, maxlen) abort
	let l:str = a:str
	if len(a:str) > a:maxlen
		let l:str = l:str[:a:maxlen] .. '…'
	endif
	return l:str
endfun
