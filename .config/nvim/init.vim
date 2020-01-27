call plug#begin('~/.vim/plugged')
Plug 'iCyMind/NeoSolarized' 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
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
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#show_close_button = 0

" nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-e> :NERDTreeToggle<CR>

" vim-gitgutter
set updatetime=100
set signcolumn=yes

" fzf
nnoremap <C-t> :FZF<CR>
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>? :History<CR>
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" vim-markdown
let g:vim_markdown_folding_disabled = 1

autocmd filetype crontab setlocal nobackup nowritebackup
