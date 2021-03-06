let NERDTreeIgnore = ['\.pyc$', '__pycache__', '.git']
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize=48
let g:NERDTreeShowHidden=1

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

noremap [nerdtree-p] <Nop>
nmap <Leader>n [nerdtree-p]
xmap <Leader>n [nerdtree-p]

map <silent> [nerdtree-p]n :NERDTreeToggle<cr>
map <silent> [nerdtree-p]b :NERDTreeFromBookmark<Space>
map <silent> [nerdtree-p]f :NERDTreeFind<cr>

