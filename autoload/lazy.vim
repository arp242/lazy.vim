scriptversion 3
if exists('g:loaded_lazy')
	finish
endif
let g:loaded_lazy = 1

" List all snippets; if echo is 1 it's printed, or it's returned if it's 0.
fun! lazy#list(echo) abort
	if &ft is# ''
		return
	endif
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
		let snip = expand('<cword>')
		let text = s:find_snip(snip)
	catch
		if a:from_insert
			echoerr v:exception
		else
			echohl Error | echom v:exception | echohl None
		endif
		return
	endtry
	if text isnot# ''
		return lazy#insert_text(text)
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
	if a:result == -1
		return
	endif
	let snip = split(a:list[a:result - 1], ' ')[0]
	call lazy#insert_text(s:find_snip(snip))
endfun

" Insert the text.
fun! lazy#insert_text(text) abort
	let text = a:text
	if type(a:text) isnot v:t_list
		let text = split(a:text, "\n")
	endif

	" Adjust indentation.
	let indent = matchstr(getline('.'), '^\s*')
	let text = text->map({_, v -> indent .. v})

	" Insert the snippet; replace the line if that's all on that.
	if getline('.') =~ '^\s*' .. text[0] .. '\s*$'
		call setline('.', text[0])
	else
		" TODO: get line, substitute at correct position. Maybe be smart if
		" what's typed already matches what we would insert?
		call setline('.', text[0])
	endif
	if len(text) > 1
		call append('.', text[1:])
	endif

	" Set cursor position to \b.
	let i = 0
	for line in text
		let c = stridx(line, "\b")
		if c > -1
			if i > 0
				exe 'normal! ' .. i .. 'j'
			endif
			exe "normal! f\b\"_x"
			let i = -1
			break
		endif
		let i += 1
	endfor

	" Move back cursor to where it was if there's no \b
	" TODO: not ideal.
	if i isnot -1
		normal! ^
	endif
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
