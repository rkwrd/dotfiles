" A minimal vimrc for new vim users to start with.
"
" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible


" Disable swap files because it's just plain infuriating how vim handles them
set noswapfile

" Added for python
filetype off

" Set relative line numbering
set relativenumber

" Set foldmethod for vimwiki to allow list folding
let g:vimwiki_folding='list'

" Set fold method to marker
set foldmethod=marker

" Plugin management "{{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
" "call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'davidhalter/jedi-vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'ervandew/supertab'
Plugin 'vimwiki/vimwiki'
Plugin 'mattn/calendar-vim'

" Add all your plugins here (note older versions of  used Bundle
" instead of Plugin)


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on	"required


" vimwiki: use markdown syntax"{{{
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
augroup filetypedetect
	au! BufRead,BufNewFile */vimwiki/*        set filetype=vimwiki
augroup END
    "}}}
"}}}

set laststatus=2
" Make backspace behave in a sane manner.
set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on

" Show line numbers
set number

" Allow hidden buffers, don't limit to 1 file per window/split
set hidden

" Enable folding
" set foldmethod=indent
" set foldlevel=99

" Key mappings"{{{
" Enable folding with space bar
nnoremap <space> za

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" Map python interpreter to F10
nnoremap <F10> :!clear;python2.7 %<CR>
" Remap leader key to "-"
let mapleader = ","

" Disable hjkl movement
" noremap h <NOP>
" noremap j <NOP>
" noremap k <NOP>
" noremap l <NOP>
" Remap escape key
inoremap jj <ESC>"}}}

" toggle relative/absolute line numbers
function! NumberToggle()
	if(&relativenumber == 1)
		set number
	else
		set relativenumber
	endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>
