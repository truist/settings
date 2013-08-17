" reload changes automatically when saved
autocmd! bufwritepost .vimrc source ~/.vimrc

" pathogen (https://github.com/tpope/vim-pathogen)
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" vim-gitgutter
highlight clear SignColumn

"general ui
set showmatch
set ruler
set showmode
" turn off beeps
set vb
" margin while scrolling
set scrolloff=3

" 
" search settings
"
set incsearch
set ignorecase
set smartcase

"
" syntax highlight and indentation settings
"
autocmd BufRead,BufNewFile *.t set filetype=perl
syntax on

" indentation / tabbing
set autoindent
filetype plugin indent on
set cindent
" make the backspace key work with autoindent
set backspace=indent,eol,start
au BufEnter *.tt set nowrap tabstop=4 shiftwidth=4
au BufEnter *.mdwn set expandtab nowrap tabstop=4 shiftwidth=4 softtabstop=4
au BufEnter *.ep set nowrap tabstop=4 shiftwidth=4
au BufEnter *.html set nowrap tabstop=4 shiftwidth=4
au BufEnter *.css set nowrap tabstop=4 shiftwidth=4

" indent/unindent selected lines in visual mode
vmap <tab> >gv
vmap <s-tab> <gv

" shortcuts for paste mode in normal and insert modes
" DON'T REMEMBER WHAT THIS DOES, AND IT CAUSES A SECOND-DELAY AFTER
" HITTING :
"nnoremap  :set invpaste paste?<CR>
"set pastetoggle=

" highlight text past 80 columns
au BufWinEnter *.t let w:m2=matchadd('Search', '\%>80v.\+', -1)
au BufWinEnter *.p? let w:m2=matchadd('Search', '\%>80v.\+', -1)
au BufWinEnter *.sh let w:m2=matchadd('Search', '\%>80v.\+', -1)

" shortcuts to comment/uncomment lines
map ,# :s/^/#<CR>
map ,## :s/^#<CR>

" shortcut to wrap text to 80 columns
map ,w !fmt -81<CR>

" delete/change/etc text between parentheseis
" to use: type 'dp' or 'cp' (etc.) while in normal mode
onoremap p i(


" configure Supertab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabMidWordCompletion = "0"


"
" make the tmux status line show the currently-edited file
"
if &term == "screen" || &term == "screen-256color"
        set t_ts=
endif
if &term == "screen" || &term == "screen-256color" || &term == "xterm" || &term == "xterm-color" || &term == "xterm-256color"
        set title
endif
autocmd BufEnter * let &titlestring = "vim " . expand("%:h") . "/" . expand("%:t")

