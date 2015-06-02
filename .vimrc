set nocompatible

set nu
set incsearch
set hlsearch
set noswapfile
set hidden
set tags=./tags;

set hidden
set backspace=eol,indent,start

" force load of golang plugin
filetype off
filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim

filetype on
filetype plugin on
filetype plugin indent on
syntax on

set foldmethod=syntax
set foldlevelstart=99

" switch to manual folding on edit to avoid fold opening
au insertenter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
au insertleave,winleave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

set showcmd
set so=10
set modeline

set guioptions-=T

set wildmenu
set wildmode=list:longest,full

" Default to make for make
set makeprg=make\ -j

set et
set tabstop=2
set shiftwidth=2
set softtabstop=2

set clipboard=unnamedplus

" Set extra colors here so new colorschemes don't override them.
au colorscheme * highlight def link RightMargin Error
au colorscheme * highlight def link ExtraWhitespace Question

au bufwinenter * call HighlightTooLongLines()
au bufwinenter * call HighlightTrailingWhitespace()

" tab/shift-tab in visual mode handles indent
vmap <Tab> >gv
vmap <S-Tab> <LT>gv

" better window switching
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

let mapleader=","

" better buffer manipulation
nnoremap <leader>n :bn<CR>
nnoremap <leader>p :bp<CR>
nnoremap <leader>c :bp\|bd #<CR>

" map new tab to a split
map <C-w>gf <C-w><C-f>

" map clang-format
map <C-f> :pyf /usr/share/vim/addons/syntax/clang-format-3.5.py<CR>
imap <C-f> :pyf /usr/share/vim/addons/syntax/clang-format-3.5.py<CR>

" map shift-I in visual to act like visualextra
vnoremap <expr> I mode() ==# 'V' ? "\<C-v>0I" : "I"

autocmd bufenter * setlocal cursorline
autocmd winenter * setlocal cursorline
autocmd winleave * setlocal nocursorline
setlocal cursorline

hi cursorline guibg=#292929
hi colorcolumn guibg=#200000

" if editing .vimrc source it on write
autocmd bufwritepost .vimrc source %
autocmd bufwritepost vimwiki/*.wiki execute 'Vimwiki2HTML'
  
" highlight too long lines based on textwidth
function! HighlightTooLongLines()
  if !exists('b:noTooLongLines')
    if &textwidth != 0
      exec 'match RightMargin /\%>' . &textwidth . 'v.\+/'
    endif
  endif
endfunction

" highlight trailing whitespace
function! HighlightTrailingWhitespace()
  if !exists('b:noExtraWhitespace')
    exec 'match ExtraWhitespace /\s\+$\| \+\ze\t/'
  endif
endfunction

" new shell execute that pipes output to window
function! s:ExecuteInShell(command)
  let command = join(map(split(a:command), 'expand(v:val)'))
  let winnr = bufwinnr('^' . command . '$')
  silent! execute  winnr < 0 ? 'botright new ' . fnameescape(command) : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
  echo 'Executing ' . command . '...'
  silent! execute 'silent %!'. command
"  silent! execute 'resize ' . line('$')
  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
  silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
  echo 'Execution of ' . command . ' complete.'
endfunction

command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)
command! -nargs=* Git call s:ExecuteInShell('git '.<q-args>)
command! -nargs=* Make call s:ExecuteInShell('make '.<q-args>)

command! T G TODO(dhamon)

" create file-close and file-quit to close buffers without destroying splits
map fc <Esc>:call CleanClose(1)<CR>
" map fq <Esc>:call CleanClose(0)<CR>

function! CleanClose(tosave)
  if (a:tosave == 1)
    w!
  endif
  let todelbufNr = bufnr("%")
  let newbufNr = bufnr("#")
  if ((newbufNr != -1) && (newbufNr != todelbufNr) && buflisted(newbufNr))
    execute "b".newbufNr
  else
    bnext
  endif

  if (bufnr("%") == todelbufNr)
    new
  endif
  execute "bd".todelbufNr
endfunction

" allow easy swapping of buffers between splits
map mw <Esc>:call MarkWindowSwap()<CR>
map sw <Esc>:call DoWindowSwap()<CR>

function! MarkWindowSwap()
  let g:markedWinNum = winnr()
  echo 'Marked window'
endfunction

function! DoWindowSwap()
  let destWinNum = winnr()
  let destBuf = bufnr("%")
  exe g:markedWinNum . "wincmd w"
  let markedBuf = bufnr("%")
  exe 'hide buf' destBuf
  exe destWinNum . "wincmd w"
  exe 'hide buf' markedBuf
  echo 'Swapped buffers'
endfunction

" Smart braces
function! SmartBraceComplete()
  echo 'Completing brace...'
  if getline(line('.')-1) =~ '^\s*\(class\|struct\)'
    echo 'class'
    normal i};
  "else if getline(line('.')-1) =~ '^\s*namespace'
  "  echo 'namespace'
  "  normal i}  \/\/ end namespace
  else
    echo 'normal'
    normal i}
  endif
endfunction

inoremap {<CR> {<CR><Esc>:call SmartBraceComplete()<CR>O

""" Switch back and forth between: (credit David Reiss)
"         .h / -inl.h / .cc / .mm / .py / .js / _test.* / _unittest.*
"  with   ,h / ,i     / ,c  / ,m  / ,p  / ,j  / ,t      / ,u
let pattern = '\(\(_\(unit\)\?test\)\?\.\(cc\|js\|py\|mm\)\|\(-inl\)\?\.h\)$'
nmap ,c :e <C-R>=substitute(expand("%"), pattern, ".cc", "")<CR><CR>
nmap ,h :e <C-R>=substitute(expand("%"), pattern, ".h", "")<CR><CR>
nmap ,i :e <C-R>=substitute(expand("%"), pattern, "-inl.h", "")<CR><CR>
nmap ,t :e <C-R>=substitute(expand("%"), pattern, "_test.", "") . substitute(expand("%:e"), "h", "cc", "")<CR><CR>
nmap ,u :e <C-R>=substitute(expand("%"), pattern, "_unittest.", "") . substitute(expand("%:e"), "h", "cc", "")<CR><CR>
nmap ,m :e <C-R>=substitute(expand("%"), pattern, ".mm", "")<CR><CR>
nmap ,p :e <C-R>=substitute(expand("%"), pattern, ".py", "")<CR><CR>
nmap ,j :e <C-R>=substitute(expand("%"), pattern, ".js", "")<CR><CR>

map <A-]> :vsplit <CR>:exec("tag ".expand("<cword>"))<CR>

nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" A freaking fast and easy way to search through sources in your project.
"
" Add this to your ~/.vimrc to perform Git Grep within Vim session, with a
" nice
" multiple-choice miniwindow, etc.
"
" In Normal (non-insert) mode:
"   <Ctrl+X> * -- git grep for word under cursor
"                 (i.e. like plain *, but on multiple files)
" When selecting text:
"   <Ctrl+X> / -- git grep for current selection
" A command-line variant:
"   :G <search string>
"
" After getting the miniwindow (i.e. quickfix):
"   arrows + <Enter> to jump to the corresponding line
"   <Ctrl+W> <Ctrl+W> to switch to another Vim window
"   :ccl to close the quickfix window.


" Returns the selected area as text
function! GetVisual() range
  let reg_save = getreg('"')
  let regtype_save = getregtype('"')
  let cb_save = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save
  return selection
endfunction

" Perform git grep
function! GitGrep(word, args)
  let pattern="\"" . a:args . "\""
  if a:word
    let pattern="-w " . pattern
  endif

  exec "Ggrep " . pattern
endfunction

command! -nargs=? G call GitGrep(0, <q-args>)
nmap <C-x>* :call GitGrep(1, "<cword>")<CR>
vmap <C-x>/ :call GitGrep(0, GetVisual())<CR>

let g:ycm_add_preview_to_completeopt = 0
let g:ycm_extra_conf_globlist = ['~/git/*', '!~/*']
let g:ycm_key_list_select_completion = ['<C-n>']
let g:ycm_key_list_previous_completion = ['<C-p>']

let g:session_directory = '~/.vimsessions'
let g:session_persist_globals = ['&makeprg']
let g:session_menu = 0
let g:session_autosave = 'no'
let g:session_autoload = 'no'

let g:ctrlp_custom_ignore = '\v[\/](\.(git|hg|svn)|CMakeFiles|build|dist|.*\.pyc)$'

call pathogen#infect()

" allow fugitive's git grep to open quickfix
autocmd QuickFixCmdPost *grep* cwindow

set laststatus=2
set statusline=%n\ %{fugitive#statusline()}\ %<%F%h%m%r%h%w\ %y\ %{&ff}\ %{strftime(\"%d/%m/%Y\")}\ %{strftime(\"%H:%M\")}%=\ col:%c%V\ pos:%o\ line:%l/%L\ %P
au insertenter * hi statusline term=reverse ctermfg='red' gui=undercurl guisp=Magenta
au insertleave * hi statusline term=reverse ctermfg='green' gui=bold,reverse
hi statusline term=reverse ctermfg='green' 

set t_Co=256
set background=dark
colorscheme inkpot
if &diff
  colorscheme murphy
endif
au filetype wiki colorscheme koehler

" transparent bg
highlight! Normal ctermbg=none

" better diff colors
highlight! DiffAdd cterm=bold ctermfg=17 ctermbg=2 gui=none guifg=bg guibg=Green
highlight! DiffDelete cterm=bold ctermfg=17 ctermbg=1 gui=none guifg=bg guibg=Red
highlight! DiffChange cterm=bold ctermfg=17 ctermbg=3 gui=none guifg=bg guibg=Yellow
highlight! DiffText   cterm=bold ctermfg=17 ctermbg=6 gui=none guifg=bg guibg=Cyan

