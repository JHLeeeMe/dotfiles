""""""""""
" plugin "
""""""""""
call plug#begin()

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mfussenegger/nvim-dap'
Plug 'rust-lang/rust.vim'
Plug 'liuchengxu/vista.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nanotech/jellybeans.vim'

call plug#end()

"""""""""""""""
" key mapping "
"""""""""""""""
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

let mapleader=","
nnoremap <Leader>rc :rightbelow vnew ~/.config/nvim/init.vim<CR>
nnoremap <F3> :Vista coc<CR>
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <F9> :RustRun<CR>
nnoremap <F10> :RustTest<CR>
"nnoremap <F12> :w<CR> :!make %:r; %:r<CR>
nnoremap <F12> :w<CR> :!g++ %:r.cpp -o ./bin/%:r; ./bin/%:r<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-A-h> 3<C-w><
nnoremap <C-A-j> 3<C-w>-
nnoremap <C-A-k> 3<C-w>+
nnoremap <C-A-l> 3<C-w>>

" window size
nnoremap <S-m> <C-w>_<C-w><bar>
nnoremap <A-m> <C-w>=
" fzf.vim
nnoremap <silent> <C-f> :Files<CR>
" airline for tab
nmap <A-1> <Plug>AirlineSelectTab1
nmap <A-2> <Plug>AirlineSelectTab2
nmap <A-3> <Plug>AirlineSelectTab3
nmap <A-4> <Plug>AirlineSelectTab4
nmap <A-5> <Plug>AirlineSelectTab5

nmap <silent> gr <Plug>(coc-references)
" <Ctrl + Space> 를 눌러서 자동완성 적용
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
" for coc-pairs enhanced <CR>
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                     \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

set tabstop=4
set shiftwidth=4
set expandtab
set colorcolumn=80
set cursorline
set nu rnu

colorschem jellybeans

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "cpp" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

" code folding
set nofoldenable
set foldlevel=1
set fillchars=fold:\
set foldtext=CustomFoldText()
setlocal foldmethod=expr
setlocal foldexpr=GetPotionFold(v:lnum)
autocmd BufReadPost,FileReadPost * normal zR
function! GetPotionFold(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  endif
  let this_indent = IndentLevel(a:lnum)
  let next_indent = IndentLevel(NextNonBlankLine(a:lnum))
  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent
  endif
endfunction
function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction
function! NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1
  while current <= numlines
      if getline(current) =~? '\v\S'
          return current
      endif
      let current += 1
  endwhile
  return -2
endfunction
function! CustomFoldText()
  " get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
      let line = getline(v:foldstart)
  else
      let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif
  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = " " . foldSize . " lines "
  let foldLevelStr = repeat("+--", v:foldlevel)
  let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr))
  return line . expansionString . foldSizeStr . foldLevelStr
endfunction
