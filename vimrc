" ensure autocmd's don't get defined twice
autocmd!

" reload changes automatically when saved
autocmd! bufwritepost .vimrc source ~/.vimrc

set nocompatible

set runtimepath+=~/.vim

if has("multi_byte")
	if &termencoding == ""
		let &termencoding = &encoding
	endif
	set encoding=utf-8
	setglobal fileencoding=utf-8
	"setglobal bomb
	set fileencodings=ucs-bom,utf-8,latin1
endif

" pathogen (https://github.com/tpope/vim-pathogen)
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

"general ui
set showmatch
set ruler
set showmode
"show e.g. number of lines selected
set showcmd
set title
" turn off beeps
set vb
" margin while scrolling
set scrolloff=3

" Persistent undo
let undodir = expand('~/.vim/undo')
if !isdirectory(undodir)
  call mkdir(undodir)
endif
set undodir=~/.vim/undo
set undofile " Create FILE.un~ files for persistent undo

" search settings
set incsearch
set ignorecase
set smartcase
set hlsearch
"clear search highlighting by hitting enter
nnoremap <cr> :noh<CR><CR>:<backspace>

if has('mouse')
  set mouse=a
  " use with <alt> on OSX; set cursor position; scroll
endif

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" syntax highlight and indentation settings
syntax on
set autoindent
filetype plugin indent on
set cindent
" make the backspace key work with autoindent
set backspace=indent,eol,start
" indent/unindent selected lines in visual mode
vmap <tab> >gv
vmap <s-tab> <gv
" if wrap is turned on, we want these setttings
set linebreak
set nolist
" prevent hard-wrapping
set textwidth=0 wrapmargin=0
" turn off all code folding
autocmd BufEnter * set nofoldenable

" hybrid relative and absolute number for current line;
" if v:version <= 703, we only get 'relativenumber'
set number
set relativenumber
highlight LineNr cterm=NONE ctermfg=DarkGrey ctermbg=NONE
highlight CursorLineNr cterm=NONE ctermfg=Yellow ctermbg=NONE

" type identification help
autocmd BufRead,BufNewFile *.t setfiletype perl
" make this explicit so the markdown plugin doesn't take it
autocmd BufRead,BufNewFile *.mdwn setfiletype ikiwiki
autocmd BufRead,BufNewFile *.md setfiletype markdown
autocmd BufRead,BufNewFile *.json setfiletype javascript syntax=javascript

" defaults
autocmd BufEnter * setlocal nowrap tabstop=4 shiftwidth=4 softtabstop=4

" type-specific settings
autocmd BufEnter *.txt setlocal wrap
" markdown
autocmd FileType mkd setlocal expandtab
autocmd FileType ikiwiki setlocal expandtab
autocmd FileType javascript setlocal expandtab

" highlight text past 80 columns, for these types
autocmd BufWinEnter *.t let w:m2=matchadd('Search', '\%>80v.\+', -1)
autocmd BufWinEnter *.p? let w:m2=matchadd('Search', '\%>80v.\+', -1)
autocmd BufWinEnter *.sh let w:m2=matchadd('Search', '\%>80v.\+', -1)

" vim-gitgutter
highlight clear SignColumn

" sudo write
ca w!! w !sudo tee >/dev/null "%"

" shortcuts for paste mode in normal and insert modes
" DON'T REMEMBER WHAT THIS DOES, AND IT CAUSES A ONE-SECOND DELAY AFTER
" HITTING :
"nnoremap  :set invpaste paste?<CR>
"set pastetoggle=

" shortcuts to comment/uncomment lines
map ,# :s/^/#<CR><CR>
map ,## :s/^#<CR><CR>

" shortcut to wrap text to 75 columns
map ,w !fmt<CR>

" configure Supertab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabMidWordCompletion = "0"

" auto-complete when in command-mode
set wildmenu

" make the tmux status line show the currently-edited file
if &term == "screen" || &term == "screen-256color"
        set t_ts=
endif
"if &term == "screen" || &term == "screen-256color" || &term == "xterm" || &term == "xterm-color" || &term == "xterm-256color"
        set title
"endif
autocmd BufEnter * let &titlestring = "vim " . expand("%:h") . "/" . expand("%:t")

