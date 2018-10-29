if exists('b:did_ftplugin') || &ft isnot# 'man'
    finish
endif

" When I open a man page, I immediately want to be able to cycle through
" options with `;` and `,`.
sil! call lg#motion#repeatable#make#set_last_used(']O', {'bwd': ',', 'fwd': ';'})

" maximize the window, the 1st time we load a man page
wincmd _

" Set the name of the scratch buffer; ex:    man(1)
" otherwise, we would have [Scratch] as a placeholder
if empty(bufname('%'))
    file $MAN_PN
endif

" Why the `if` condition?
" Suppose we open a man buffer:
"
"         $ man bash
"
" The command `file $MAN_PN` names it using the value environment variable:
"
"         $MAN_PN    ex: bash(1)
"
" Then we look for a reference, and click on it.
" A new man buffer is loaded, and the command would again try to name the new
" buffer with the same name `$MAN_PN`.
" It would give an error because a buffer with this name already exists.
" Besides, there's no need to rename the subsequent buffers, somehow they're
" automatically correctly named when opened from Vim (instead of the shell).

" Options {{{
"
" We can't give the value `wipe` to 'bufhidden'.
" Indeed, after clicking on a reference in a man buffer, the original buffer
" would be wiped out. We couldn't get back to it with `C-T`.

setl buftype=nofile
setl noswapfile
setl nobuflisted
setl bufhidden=hide

setl nomodified
setl noexpandtab
setl tabstop=8
setl softtabstop=8
setl shiftwidth=8

setl nonumber
setl norelativenumber
setl foldcolumn=0
setl colorcolumn=0
setl nofoldenable

" Kind of help buffer
setl nomodifiable
setl readonly

" Formatting
setl nolist
setl ignorecase

"}}}
" Mappings {{{

" I often look for the name of a (sub)section.
nno  <buffer><nowait>  g/  /^\s*

" I frequently hit `p` by accident. It raises the error:
"
"     E21: Cannot make changes, 'modifiable' is off
nno  <buffer><nowait><silent>  p  <nop>
nno  <buffer><nowait><silent>  q  :<c-u>call lg#window#quit()<cr>

nmap  <buffer><nowait><silent>  <cr>  <c-]>
nmap  <buffer><nowait><silent>  <bs>  <c-t>

nno  <buffer><nowait><silent>  <c-]>  :Man<cr>
nno  <buffer><nowait><silent>  K      :Man<cr>
nno  <buffer><nowait><silent>  <c-t>  :call man#pop_tag()<cr>

noremap  <buffer><expr><nowait><silent>  [H  man#bracket_rhs('heading', 0)
noremap  <buffer><expr><nowait><silent>  ]H  man#bracket_rhs('heading', 1)

noremap  <buffer><expr><nowait><silent>  [<c-h>  man#bracket_rhs('subheading', 0)
noremap  <buffer><expr><nowait><silent>  ]<c-h>  man#bracket_rhs('subheading', 1)
"                                          │
"                                          └ can't use `h`:
"                                                it would conflict with `]h` (next path)

noremap  <buffer><expr><nowait><silent>  [O  man#bracket_rhs('option', 0)
noremap  <buffer><expr><nowait><silent>  ]O  man#bracket_rhs('option', 1)
"                                         │
"                                         └  can't use `o`:
"                                                it would prevent us from typing `[oP`

nno  <buffer><nowait><silent>  ]p  :<c-u>call man#zsh#move_in_pages('fwd')<cr>
nno  <buffer><nowait><silent>  [p  :<c-u>call man#zsh#move_in_pages('bwd')<cr>

noremap  <buffer><expr><nowait><silent>  [r  man#bracket_rhs('reference', 0)
noremap  <buffer><expr><nowait><silent>  ]r  man#bracket_rhs('reference', 1)

if stridx(&rtp, 'vim-lg-lib') >= 0
    call lg#motion#repeatable#make#all({
        \ 'mode': '',
        \ 'buffer': 1,
        \ 'axis': {'bwd': ',', 'fwd': ';'},
        \ 'from': expand('<sfile>:p').':'.expand('<slnum>'),
        \ 'motions': [
        \     {'bwd': '[H',     'fwd': ']H'},
        \     {'bwd': '[<c-h>', 'fwd': ']<c-h>'},
        \     {'bwd': '[O',     'fwd': ']O'},
        \     {'bwd': '[p',     'fwd': ']p'},
        \     {'bwd': '[r',     'fwd': ']r'},
        \ ]})
endif

" init {{{1

let s:pager = !exists('b:man_sect')

if s:pager
    call man#init_pager()
endif

" Variables {{{1

let b:did_ftplugin = 1

" Teardown {{{1

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
    \ . (empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
    \ . "
    \ setl bh< bt< cc< fdc< ic< nobl< noet< nofen< nolist< noma< nomod< nonu< nornu< noswf< ro< sw< sts< ts<
    \|unlet! b:man_sect
    \
    \|nunmap <buffer> g/
    \|nunmap <buffer> <c-]>
    \|nunmap <buffer> <cr>
    \|nunmap <buffer> <bs>
    \|nunmap <buffer> K
    \|nunmap <buffer> <c-t>
    \|nunmap <buffer> p
    \|nunmap <buffer> q
    \|nunmap <buffer> [H
    \|nunmap <buffer> ]H
    \|nunmap <buffer> [<c-h>
    \|nunmap <buffer> ]<c-h>
    \|nunmap <buffer> [O
    \|nunmap <buffer> ]O
    \|nunmap <buffer> [p
    \|nunmap <buffer> ]p
    \|nunmap <buffer> [r
    \|nunmap <buffer> ]r
    \"

