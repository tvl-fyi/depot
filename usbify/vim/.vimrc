" -- BEGIN: Vundle config --
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'

" All of your Plugins must be added before the following line
Plugin 'othree/yajs.vim'
Plugin 'crusoexia/vim-monokai'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'mileszs/ack.vim'
Plugin 'sjl/clam.vim'
Plugin 'kien/ctrlp.vim'

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" -- END: Vundle config --


" backspace settings
set backspace=2
set backspace=indent,eol,start


" keyword completion
inoremap ;; <C-n>


" -- Syntastic Settings --
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_javascript_checkers = ['gjslint']


" Basic settings
syntax on
set number
set tabstop=2
set expandtab
set shiftwidth=2
colorscheme monokai
set t_Co=255


" Ensure that <header> is "," character
let mapleader = ","


" Define highlighting groups
highlight InterestingWord1 ctermbg=Cyan ctermfg=Black
highlight InterestingWord2 ctermbg=Yellow ctermfg=Black
highlight InterestingWord3 ctermbg=Magenta ctermfg=Black


" h1 highlighting
nnoremap <silent> <leader>h1 :execute 'match InterestingWord1 /\<<c-r><c-w>\>/'<CR>
nnoremap <silent> <leader>xh1 :execute 'match none'<CR>

" h2 highlighting
nnoremap <silent> <leader>h2 :execute '2match InterestingWord2 /\<<c-r><c-w>\>/'<CR>
nnoremap <silent> <leader>xh2 :execute '2match none'<CR>

" h3 highlighting
nnoremap <silent> <leader>h3 :execute '3match InterestingWord3 /\<<c-r><c-w>\>/'<CR>
nnoremap <silent> <leader>xh3 :execute '3match none'<CR>

"clear all highlighted groups
nnoremap <silent> <leader>xhh :execute 'match none'<CR> :execute '2match none'<CR> :execute '3match none'<CR>


" add 80 character wrap line
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/


" map jj to <Esc>
imap jj <Esc>

" map ctrl + n to :NERDTree
map <C-n> :NERDTreeToggle<CR>


" BOL and EOL
nnoremap H ^
nnoremap L $


" set -o emacs line-editor defaults
inoremap <C-a> <Esc>I
inoremap <C-e> <Esc>A


" trim trailing whitespace on save
autocmd BufWritePre *.{js,py,tpl,html} :%s/\s\+$//e


" set default font and size
set guifont=Operator\ Mono:h16


" -- fuzzy-finder --
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = {
  \ 'dir':  'node_modules'
  \ }

