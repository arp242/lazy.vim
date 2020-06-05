The really simple snippet manager.

Snippets are loaded per-filetype from `g:lazy_snippets`:

    let g:lazy_snippets = #{
        \ go: #{
            \ err: "if err != nil {\n\treturn fmt.Errorf(\"\b: %w\", err)\n}",
        \ },
    \ }

The cursor will be set to `\b` (that is, the BS character, 0x08). You can use
`\b` inside `".."` strings, but in `'..'` strings or external files you'll have
to use a literal character; use `<C-v><C-h>` to insert one. You can use
`readfile()` to load snippets from a file:

    let g:lazy_snippets['go']['tt'] = readfile($HOME .. '/.vim/snip/tt.go')

Now press `<C-s>` in normal or insert mode to find a snippet based on the
`<cword>`. If you want a different mapping:

	nmap <C-t> <Plug>(lazy-insert-cword)
	imap <C-t> <Plug>(lazy-insert-cword)

you can use the `:Lazy` command to list snippets for the current filetype.

Note: many terminals eat `<C-s>` and will stop the terminal output (`<C-q>` to
resume); you probably want to disable this in your shell config `setopt
noflowcontrol` in zsh; or `stty -ixon quit undef`).

Note 2: you need a fairly new Vim for this plugin to work, as I'm too lazy to
make it more compatible 😅

Alternatives:

- https://github.com/joereynolds/vim-minisnip
