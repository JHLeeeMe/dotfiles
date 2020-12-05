" Vundle
set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

""""""""""""""""""""""""""""""""
Plugin 'vim-airline/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
Plugin 'AutoComplPop'
Plugin 'davidhalter/jedi-vim'

" Themes
Plugin 'nanotech/jellybeans.vim'
Plugin 'sickill/vim-monokai'
""""""""""""""""""""""""""""""""

call vundle#end()
filetype plugin indent on    " required


" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let python_version_3=1
let python_highlight_all=1
let g:pydiction_location='$HOME/.vim/pydiction/complete-dict'
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

" basic setting
syntax on  " 구문 강조
set expandtab  " Tab 대신 스페이스
set tabstop=4  " Tab 너비
set hlsearch  " 검색어 하이라이트
set incsearch  " 키워드 입력시 점진적 검색
set cursorline  " 편집 위치에 커서 라인 설정
set nu rnu  " number & rnumber

" key mapping
let mapleader=","
nnoremap <Leader>rc :rightbelow vnew ~/.vimrc<CR>
nnoremap <C-F> :NERDTreeFind<CR>
nnoremap <F7> :NERDTreeToggle<CR>

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

noremap <bar> <C-w><bar><C-w>_
noremap \ <C-w>=
noremap <Leader>nu :set nu! rnu!<CR>

" theme-color
"color jellybeans
color monokai
