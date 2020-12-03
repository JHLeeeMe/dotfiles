set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
Plugin 'AutoComplPop'
Plugin 'davidhalter/jedi-vim'

"""""""""
" theme "
"""""""""
Plugin 'nanotech/jellybeans.vim'
" lugin 'sickill/vim-monokai'

call vundle#end()            " required

syntax on
filetype plugin indent on    " required
let python_version_3=1
let python_highlight_all=1
let g:pydiction_location='$HOME/.vim/pydiction/complete-dict'

"""""""""""""""
" key mapping "
"""""""""""""""
let mapleader=","
nnoremap <Leader>rc :rightbelow vnew ~/.vimrc<CR>
nnoremap <C-F> :NERDTreeFind<CR>
nnoremap <F7> :NERDTreeToggle<CR>

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

"""""""""""""""
" theme-color "
"""""""""""""""
color jellybeans
"color monokai
