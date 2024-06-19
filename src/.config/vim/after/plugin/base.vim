set nobackup
set noswapfile
set nowritebackup
set splitbelow     " New horizontal window splits open below
set splitright     " New vertical window splits open to the right
set updatetime=100 " ms, sync frequency to swapfile. Affects airline/git-gutter

set t_vb=    " Disable visual bell
set ttyfast  " are slow terminals even relevant in 2020+?
set showcmd  " show partial normal mode keys

set laststatus=2          " Always on
set statusline=[%n]\ %f%m " buffer (%n) path (%f) modified (%m)

set norelativenumber      " relative numbers kills performance on old hardware
"syntax sync minlines=256  " improve syntax performance
set nocursorcolumn        " on in nvim, explicit for better performance
set nocursorline          " on in nvim, explicit for better performance

" neovim adds inccommand for highlightin searches and :s// :g//
set ignorecase  " Prefix with \C in searches to be case sensitive again
set incsearch   " Search highlights only next result as you type

" The all-important default indent settings; filetypes to tweak
set expandtab    " Convert tab -> spaces, use <C-v><Tab> <Leader>t to tab
set tabstop=2    " Tabs take up four spaces
set shiftwidth=2 " The number of cells to indent when using '>' or '<'

" If the target line uses tabs for identing
nnoremap <unique> <silent> j j:if getline('.')[0:0] == "\t"<Bar>set noexpandtab<Bar>elseif getline('.')[0:0] == " "<Bar>set expandtab<Bar>endif<CR>
nnoremap <unique> <silent> k k:if getline('.')[0:0] == "\t"<Bar>set noexpandtab<Bar>elseif getline('.')[0:0] == " "<Bar>set expandtab<Bar>endif<CR>

if v:version >= 800
  set nofixendofline      " Do not auto-change the last character in a file
  set foldmethod=indent   " I dislike automatic collapsing
  set nofoldenable        " Expand all collapsed sections
endif


set nrformats-=octal  " Leading 0s are not recognised as octals
"set formatoptions+=j  " Delete comment leaders when joining lines
"set formatoptions-=c  " Do not auto-wrap comments when exceeding textwidth
"set formatoptions-=o  " Do not auto add comments on normal 'o' or 'O'
"set formatoptions-=r  " Do not auto add comments on <Enter>
set list
set listchars=nbsp:¬,tab:\ \ ,extends:»,precedes:«


" This should be set after `filetype plugins ident on`.
" Seems like we need both this and 
augroup GeneralCustom
  autocmd!
  autocmd BufEnter * set formatoptions=qjl
augroup END

" Use UTF-8 if we can and env LANG didn't tell us not to
if has('multi_byte') && !exists('$LANG') && &encoding ==# 'latin1'
  set encoding=utf-8
endif

" Neovim prints random 'q' if ${TERM} is set wrong in the first login terminal
" See https://stackoverflow.com/questions/4229658
"if ! has("gui_running") |  set guicursor= | endif


" ==============================================================================
" Completion Menu
" ==============================================================================

" Wildmenu settings; see also plugin/wildignore.vim
set wildmenu                " Use wildmenu
set wildmode=list:longest   " Tab press completes and lists
silent! set wildignorecase  " Case insensitive, if supported

"" Auto complete
"inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" Avoid completing with only one item. Causes problems when deleting
set completeopt=menu,menuone,preview,noinsert,noselect

" ==============================================================================
" Colours and Highlights
" ==============================================================================

set bg=light                                       " Light mode
highlight! Error ctermfg=231 ctermbg=red guibg=red " Better for light mode

" For transparent background
"highlight! Normal      ctermbg=NONE guibg=NONE
"highlight! NonText     ctermbg=NONE guibg=NONE
"highlight! NormalFloat ctermbg=NONE guibg=NONE

" Linting stuff
" I like the 80-character because it's nice for reasoning about line-wrap,
" it is a reasonable amount of text for projectors (low resolution), and it
" works nicely for opening multiple GUI windows and splits.
set colorcolumn=81  " Archaic 80-character width, keep to before the line
highlight! ColorColumn ctermfg=red ctermbg=yellow guibg=yellow
highlight! HighlightedWhitespace ctermbg=Grey guibg=Grey
call matchadd('HighlightedWhitespace', '\s\+$')  " For trailing whitespace
call matchadd('HighlightedWhitespace', '\t')     " For tab idents
highlight! Visual cterm=NONE ctermbg=LightYellow ctermfg=NONE

" Not linking to a vim highlight group (e.g. group 'Todo' only appears in
" comments) because nvim-treesitter disables vim syntax highlighting when
" it is active (with the appropriate config in nvim-treesitter).
highlight! Admonition ctermbg=yellow guibg=yellow
call matchadd('Admonition', '@TODO\|\<TODO')
call matchadd('Admonition', '@FIXME\|\<FIXME')
call matchadd('Admonition', '@VOLATILE\|\<VOLATILE')   " To mark implicit dependencies
call matchadd('Admonition', '@UNSAFE\|\<UNSAFE')       " From Rust
call matchadd('Admonition', '@NOTE\|\<NOTE')           " From AsciiDoctor
call matchadd('Admonition', '@IMPORTANT\|\<IMPORTANT') " From AsciiDoctor
call matchadd('Admonition', '@TIP\|\<TIP')             " From AsciiDoctor
call matchadd('Admonition', '@CAUTION\|\<CAUTION')     " From AsciiDoctor
call matchadd('Admonition', '@WARNING\|\<WARNING')     " From AsciiDoctor

highlight clear SignColumn
highlight GitGutterAdd ctermfg=Black ctermbg=Green
highlight GitGutterChange ctermfg=Black ctermbg=Yellow
highlight GitGutterDelete ctermfg=Black ctermbg=Red
highlight GitGutterChangeDelete ctermfg=Black ctermbg=Magenta



" ==============================================================================
" Emac/Helix-inspired movement
" ==============================================================================
inoremap <C-A> <Home>
cnoremap <C-A> <Home>
inoremap <C-E> <End>
cnoremap <C-E> <End>
inoremap <unique> <M-b> <C-Left>
cnoremap <unique> <M-b> <C-Left>
inoremap <unique> <M-f> <C-Right>
cnoremap <unique> <M-f> <C-Right>
inoremap <unique> <C-u> <C-o>d0
inoremap <unique> <C-k> <C-o>d$
inoremap <unique> <C-y> <Esc>Pa

" C-x C-t in Emacs
inoremap <unique> <C-l> <C-o>:move +1<CR>
inoremap <unique> <C-h> <C-o>:move -2<CR>
vnoremap <unique> <C-l> :move '>+1<CR>gv
vnoremap <unique> <C-h> :move '<-2<CR>gv

" Helix
nnoremap <unique> [g       :GitGutterPrevHunk<CR>
nnoremap <unique> ]g       :GitGutterNextHunk<CR>
vnoremap <unique> s        :MultipleCursorsFind<Space>
nnoremap <unique> <Bar>    :.!
vnoremap <unique> <Bar>    :!
nnoremap <unique> <Space>w :write<CR>
nnoremap <unique> <Space>q :quit<CR>



" ==============================================================================
" General Bindings
" ==============================================================================

" Disable help
nnoremap <unique> <F1> <Nul>
" Disable Ex mode (can still use gQ)
nnoremap <unique> Q    q
nnoremap <unique> q    <Nul>



" Inspired by 'tpope/vim-unimpaired'
nnoremap <unique> yor :setlocal <C-r>=&rnu        ? "no":""<CR>rnu<bar>setlocal rnu?<CR>
nnoremap <unique> yoi :setlocal <C-r>=&ignorecase ? "no":""<CR>ignorecase<bar>setlocal ignorecase?<CR>
nnoremap <unique> yop :setlocal <C-r>=&paste      ? "no":""<CR>paste<bar>setlocal paste?<CR>
nnoremap <silent> <expr> <unique> yos &spell
  \? ':setlocal nospell<Bar>setlocal spell?<CR>'
  \: ':setlocal spell spelllang=' . input('spelllang=', 'en_gb') . '<Bar>setlocal spelllang?<CR>'
nnoremap <unique> yof :setlocal <C-r>=&foldenable ? "no":""<CR>foldenable<bar>setlocal foldenable?<CR>
nnoremap <unique> yoh :setlocal <C-r>=&hlsearch   ? "no":""<CR>hlsearch<bar>setlocal hlsearch?<CR>
nnoremap <unique> yon :setlocal <C-r>=&number     ? "no":""<CR>number<bar>setlocal number?<CR>
nnoremap <unique> yox :if exists('syntax_on') \| syntax on \| else \| syntax off \| endif<CR>
nnoremap <unique> [q  :cprevious<CR>
nnoremap <unique> ]q  :cnext<CR>
nnoremap <unique> [l  :lprevious<CR>
nnoremap <unique> ]l  :lnext<CR>

" Spelling
nnoremap <unique> <Leader>sus :setlocal spell spelllang=en_US,cjk<CR>
nnoremap <unique> <Leader>sgb :setlocal spell spelllang=en_GB,cjk<CR>

" Select the same selection again after doing an indent
nnoremap <unique> > >>
nnoremap <unique> < <<
vnoremap <unique> > >gv
vnoremap <unique> < <gv



" ==============================================================================
" Vim Barbaric
" ==============================================================================

" Set IME to the decativated version (i.e. english keyboard) for normal mode
" IMEs by convention have two states: active and deactivated.
" Extraction of 'rlue/vim-barbaric', this has more elaborate logic that is
" will not always activate your IME if you deactivated it.
"
" But if you do want to always activate it (always proc e.g. Japanese on insert
" mode) as we do here, a good idea is to have two english keyboards, one for
" the deactivated version and one for the active. That way you can, outside of
" vim, activate an English keyboard to stay in English on insert mode.
"
" I choose this over 'rlue/vim-barbaric' because 1) less plugins and 2) I always
" want to be in English for normal mode. 'rlue/vim-barbaric' maintains whatever
" mode you started with on entering vim
set timeoutlen=1000  " https://github.com/rlue/vim-barbaric/issues/15
set ttimeoutlen=0    " Immediately run fcitx-remote after entering/leaving
augroup CustomBarbaric
  autocmd!
  autocmd InsertEnter * if executable('fcitx-remote')  | call system('fcitx-remote -o') | endif
  autocmd InsertLeave * if executable('fcitx-remote')  | call system('fcitx-remote -c') | endif
  autocmd InsertEnter * if executable('fcitx5-remote') | call system('fcitx5-remote -o') | endif
  autocmd InsertLeave * if executable('fcitx5-remote') | call system('fcitx5-remote -c') | endif
  " This always prints some ANSI escape codes, not sure how to fix it
  " Deactivate on VimEnter
  "autocmd VimEnter    * if executable('fcitx-remote') | call system('fcitx-remote -c') | endif
augroup END



" ==============================================================================
" Clipboard
" ==============================================================================
" Consider trick of `if has("clipboard") @+ = @* = @"` ?
nnoremap <unique> <space>y :silent call system("clipboard.sh --write", @")<CR>
vnoremap <unique> <space>y y:call system('clipboard.sh --write', @")<CR>gv
inoremap <unique> <leader>p
  \ <C-o>:setlocal paste<Bar>
  \let @" = system('clipboard.sh --read')<CR><C-r>"
  \<C-o>:setlocal nopaste<CR>

augroup CleanupNoPaste
  autocmd!
  autocmd InsertLeave * set nopaste
augroup END




" ==============================================================================
" Extra functionality
" ==============================================================================
" Snippets
nnoremap <unique>        !                  :read !
inoremap <unique>        <C-x>8             <C-o>:silent read !printf \%b \\u00
inoremap <unique>        <LocalLeader>t     <C-v><Tab>
inoremap <unique>        <LocalLeader><Tab> <C-r>=ChooseSnippet(&filetype)<CR>
inoremap <unique>        <LocalLeader>ss    <C-r>=ChooseSnippet("symbols")<CR>
inoremap <unique> <expr> <LocalLeader>sa    '<C-r>=ChooseSnippet("'
  \ .  input("Choose filetype for snippet.sh: ") . '")<CR>'
inoremap <unique>        <LocalLeader>sl     <C-o>:silent read !snippets.sh -t<CR>

" Move cursor and replace placeholder '<>'
inoremap <unique> <LocalLeader>p <C-o>?<><CR><C-o>d2l
inoremap <unique> <LocalLeader>n <C-o>/<><CR><C-o>d2l
nnoremap <unique> <LocalLeader>p ?<><CR>c2l
nnoremap <unique> <LocalLeader>n /<><CR>c2l

function ChooseSnippet(filetype) abort
  return system("tmux-window-output-to-buffer.sh snippets.sh " . shellescape(a:filetype))
endfunction


nnoremap <unique> <Space>ewc :echo
  \ "words: " . system('wc -w "' . expand('%') . '"')
  \ . "chars: ". system('wc -m "' . expand('%') . '"')<CR>
vnoremap <unique> <Space>ewc y:echo
  \ "words: " . system('wc -w ', @")
  \ . "chars: ". system('wc -m ', @")<CR>
" transform append
nnoremap <unique> <Leader>zp 0yt<Bar>f<Bar>a
  \<C-r>=system("language.sh pinyin \"" . @" . '"')<CR>
  \<C-h><Bar><Esc>0j
nnoremap <unique> <Space>c
  \ :silent call system("    setsid reloadvim.sh --ignore-checks '"
  \. line('w0') . "' '" . line('.') . "' '" . col('.') . "' '"
  \. expand('%') . "' &")<CR>

" Knowledge Management
nnoremap <unique> <Leader>kt :edit <C-r>=system(
    \"tmux.sh run-in-new-window zet.sh tags -u 2>/dev/null")<CR><Del><CR>
nnoremap <unique> <Leader>ki :edit <C-r>=system(
    \"tmux.sh run-in-new-window zet.sh incoming -u"
    \ . " " . shellescape(expand("%:p")) . " 2>/dev/null")<CR><Del><CR>
nnoremap <unique> <Leader>ko :edit <C-r>=system(
    \"tmux.sh run-in-new-window zet.sh outgoing -u"
    \ . " " . shellescape(expand("%:p")) . " 2>/dev/null")<CR><Del><CR>
nnoremap <unique> <Leader>kl :edit <C-r>=system(
    \"tmux.sh run-in-new-window zet.sh list -u 2>/dev/null")<CR><Del><CR>
