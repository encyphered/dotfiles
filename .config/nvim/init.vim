call plug#begin('~/.vim/plugged')
Plug 'overcache/NeoSolarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'APZelos/blamer.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

let g:python_host_prog = '/usr/local/bin/python'

set number
set hlsearch
set ignorecase
set smartcase

set relativenumber

set cursorline

" indent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set copyindent

" tabs
nmap <leader>1 :tabnext 1<CR>
nmap <leader>2 :tabnext 2<CR>
nmap <leader>3 :tabnext 3<CR>
nmap <leader>4 :tabnext 4<CR>
nmap <leader>5 :tabnext 5<CR>
nmap <leader>6 :tabnext 6<CR>
nmap <leader>7 :tabnext 7<CR>
nmap <leader>8 :tabnext 8<CR>
nmap <leader>9 :tabnext 9<CR>
nmap <leader>- :tabprevious<CR>
nmap <leader>= :tabnext<CR>

nnoremap <leader>n :tabnew<CR>

" neosolarized
set termguicolors
colorscheme NeoSolarized
set background=dark

" airline
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_tabs=1
let g:airline#extensions#tabline#tab_nr_type=1
let g:airline#extensions#tabline#left_sep=' '
let g:airline#extensions#tabline#left_alt_sep='|'
let g:airline#extensions#tabline#buffer_idx_mode=1
let g:airline#extensions#tabline#show_close_button=0

" nerdtree
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

map <C-e> :NERDTreeToggle<CR>

" vim-gitgutter
set updatetime=100
set signcolumn=yes

" fzf
nnoremap <C-p> :FZF<CR>
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>? :History<CR>
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

nnoremap <C-h> :bprevious<CR>
nnoremap <C-l> :bnext<CR>

" vim-markdown
let g:vim_markdown_folding_disabled = 1

autocmd filetype crontab setlocal nobackup nowritebackup

let g:blamer_enabled = 1
let g:blamer_delay = 500

function TabTerm()
  :tabnew
  :terminal
endfunction

" terminal
nnoremap <leader>t :exec TabTerm()<CR>

augroup TerminalStuff
  autocmd TermOpen * setlocal nonumber norelativenumber
  autocmd TermOpen * :startinsert
  autocmd TermClose * bd!
augroup END
let g:terminal_color_8='#3e5358'
tnoremap <leader><ESC> <C-\><C-n>
