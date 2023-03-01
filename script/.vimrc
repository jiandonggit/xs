set nocompatible
set number
set autoindent
set cindent
set expandtab
set splitbelow
set splitright
set incsearch
set showcmd
set wildmenu
"set cursorline
set shiftround
set hlsearch
set ruler
set smarttab
set textwidth=0
set tabstop=4
set shiftwidth=4
set backspace=2
"set mouse=a
set scrolloff=4
"set showtabline=2
"set background=light
set nobackup
set wildmode=list:longest,full
set display=lastline
set fileencodings=utf-8,gb18030
set encoding=utf-8
set pastetoggle=<F2>
set isfname=@,48-57,/,.,-,_,,,$,%,~,[,],{,}
set viewdir=~/.vimview

if !empty(glob("/usr/share/dict/words"))
    set dict+=/usr/share/dict/words
endif

if version >=704
    set formatoptions+=jor
else
    set formatoptions+=or
endif

syntax on
filetype plugin indent on 
runtime macros/matchit.vim
color default

execute pathogen#infect()

let mapleader = ','
map <Leader>q :q<CR>
map <Leader>rc :tabe ~/.vimrc<CR>
nmap <Leader>d :bd<CR>
nmap <silent> <C-H>  :noh<CR>
nnoremap gM  50%zz

inoremap <C-L>  <C-X><C-L>
inoremap <C-F>  <C-X><C-F>
inoremap <C-K>  <C-X><C-K>
"inoremap <C-O>  <C-X><C-O>
nnoremap j gj
nnoremap k gk
exec "nmap <F9>  yyp<C-A>" . repeat("l.",9)
nmap <silent> <F5> :e!<CR>
nmap <C-N>  :tabe<space>
vmap <F12> :s/^\s*\d\+\s*<CR>gv=
nnoremap <C-K>  :colo random<CR>


for i in range(1,9) | exec "map <A-" . i . "> " . i . "gt" | endfor
for i in range(1,9) | exec "map <Leader>" . i . " " . i . "gt" | endfor

if has("gui_running")
    
    set guioptions-=T
    "set guioptions-=m
    set guitablabel=%(%N\ %m%r%t%)
    set showtabline=2
    set guifont=Liberation\ Mono\ 14
    set cursorline
    set lines=35
    set columns=100

    nmap <C-TAB> gt
    nmap <C-S-TAB> gT
    imap <S-Insert> <C-R>*
    imap <C-V> <C-R>*
    cmap <S-Insert> <C-R>*

    " if ( strftime("%H") >= 18 )
    "     colo darktango
    " else
    "     colo donbass
    " endif
    
endif

hi matchparen cterm=bold,reverse
"ctermbg=0 ctermfg=5
"hi search ctermfg=Yellow ctermbg=0 cterm=reverse
syn match ErrorMsg '\<Error\>\c'

if has("autocmd")
    au BufNewFile * if &ft == 'sverilog'  | exec ':SVIDH' | endif
                \ | if &ft == 'c' || &ft == 'cpp' | exec ':CIDH' | endif
    au BufNewFile * if &ft == ''  | se syn=log | endif
                \ | if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

                
"
"" Doxygen
"
let g:DoxygenTookit_commentType = "C"
let g:DoxygenTookit_authorName  = $USER
let g:DoxygenTookit_licenseTag  = "\<enter>"
let g:DoxygenTookit_licenseTag .= " Copyright (C) xxx Co., Ltd \<enter>\<enter>"
let g:DoxygenTookit_licenseTag .= " File   : " . expand('%:t') ."\<enter>"
let g:DoxygenTookit_licenseTag .= " Author : " . g:DoxygenTookit_authorName."\<enter>"
let g:DoxygenTookit_licenseTag .= " Create : " . strftime("%F") . "\<enter>\<enter>"
let g:DoxygenTookit_licenseTag .= " History: \<enter>"
let g:DoxygenTookit_licenseTag .= " ".repeat('-',64) . "\<enter>"
let g:DoxygenTookit_licenseTag .= " Revision: 1.0, " . g:DoxygenTookit_authorName. strftime(" @%Y/%m/%d %T") . "\<enter>"
let g:DoxygenTookit_licenseTag .= " Description: \<enter>"

nmap <F2> <Plug>DoxygenLic
nmap <F3> <Plug>DoxygenVer
nmap <F4> <Plug>DoxygenFunc

" if has("gui_running") && !empty(glob("/etc/redhat-release"))
"     let g:REDHAT_VERSION = matchstr(readfile("/etc/redhat-release")[0],'\d')
"     if g:REDHAT_VERSION >= 7
"         " == redhat7 work in gvim/vim
"         " NOTE: system() respons slow
"         "inoremap <silent> <exc> <esc>:call system("ibus engine xkb:us::eng")<cr>
"     else
"         " = redhat work in gvim only
"         inoremap <exc> <exc><C-@>
"     endif
" endif


let g:netrw_dirhistmax = 0 
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>f :NERDTreeFind<CR>
nnoremap <leader>t :NERDTreeToggle<CR>
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:indentLine_enabled = 1 
let g:indentLine_color_term = 'darkgray'
let g:indentLine_char = "┆"  " echo nr2char(9478)

let g:vim_json_conceal = 0 
let g:vim_json_warnings = 0 

let g:snipMate = {'snippet_version' : 1}

silent! source ~/.vimrc.user








