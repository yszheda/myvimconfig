
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" Make the shared ~/.vim runtime available to both Git Vim and native Vim.
let s:vim_config_dir = expand('~/.vim')
if isdirectory(s:vim_config_dir) && index(split(&runtimepath, ','), s:vim_config_dir) < 0
  let &runtimepath = s:vim_config_dir . ',' . &runtimepath
endif
let s:vim_after_dir = s:vim_config_dir . '/after'
if isdirectory(s:vim_after_dir) && index(split(&runtimepath, ','), s:vim_after_dir) < 0
  let &runtimepath = &runtimepath . ',' . s:vim_after_dir
endif
unlet s:vim_after_dir
unlet s:vim_config_dir

" add pathogen to manage plugins.
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" added by ys
" 2011-8-4
" reference: Vimer's blogs
" check the current operating system
if ( has("win32") || has("win95") || has("win64") )
	let g:iswindows=1
else
	let g:iswindows=0
endif
autocmd BufEnter * lcd %:p:h

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start whichwrap+=<,>,[,]
" set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" added by ys
" 2011-8-4
" reference: Vimer's blogs
set tabstop=4		" set the appearance of <TABLE> equals to 4 spaces
" set vb t_vb
" set nowrap		" never automatically change line

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" added by ys
" 2011-8-4
" reference: Vimer's blogs
if g:iswindows==1
	if has('mouse')
		set mouse=a
	endif
	au GUIEnter * simalt ~x
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Set mapleader
" added by ys
" 2011-7-21
let mapleader = ","
" Fast reloading of the .vimrc
map <silent> <leader>ss :source ~/.vimrc<cr>
" Fast editing of .vimrc
map <silent> <leader>ee :e ~/.vimrc<cr>
" When .vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

" Encoding
" added by ys
" 2011-7-21
let termencoding = &encoding
" set encoding=utf-8 
" set termencoding=utf-8
set fileencodings=utf-8,gbk
" set encoding=utf-8
" set fenc=cp936
" if g:iswindows == 1
"	source $VIMRUNTIME/delmenu.vim
" 	source $VIMRUNTIME/menu.vim
" 	language messages zh_CN.utf-8
" endif
" if v:lang = ~?'^\(zh\)|\(ja\)|\(ko\)'
" 	set ambiwidth = double
" endif
" set nobomb

set nu

" VimWiki settings
let g:vimwiki_use_mouse = 1
let g:vimwiki_list = [{"path": "D:/Dropbox/VimWiki", "path_html": "D:/Dropbox/VimWiki/Sites/wiki", "auto_export": 1}]

" ============================================================================
" LSP Configuration (vim-lsp + asyncomplete + vim-lsp-settings)
" ============================================================================

" LSP keymaps
nnoremap <silent> gd :<C-u>LspDefinition<CR>
nnoremap <silent> gD :<C-u>LspDeclaration<CR>
nnoremap <silent> gr :<C-u>LspReferences<CR>
nnoremap <silent> <leader>rn :<C-u>LspRename<CR>
nnoremap <silent> K :<C-u>LspHover<CR>
nnoremap <silent> <leader>ca :<C-u>LspCodeAction<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>

" LSP diagnostics
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_text_edit_enabled = 1

" Configure the buffer after a language server is attached.
augroup lsp_buffer_configuration
  autocmd!
  autocmd User lsp_buffer_enabled setlocal omnifunc=lsp#complete
augroup END

" asyncomplete completion settings
set completeopt=menuone,noinsert,noselect
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 1
let g:asyncomplete_popup_delay = 0

" Filetype mappings: CUDA gets cuda syntax, OpenCL -> cpp (clangd handles both)
augroup lsp_filetype_mappings
  autocmd!
  autocmd BufNewFile,BufRead *.cu,*.cuh,*.cps,*.cpsh set filetype=cuda
  autocmd BufNewFile,BufRead *.s,*.asm set filetype=asm
  autocmd BufNewFile,BufRead *.cl set filetype=cpp
augroup END

" LSP server configuration via vim-lsp-settings
" clangd for C/C++/CUDA/OpenCL
let g:lsp_settings = {
\   'clangd': {
\     'args': ['--background-index', '--clang-tidy'],
\     'allowlist': ['c', 'cpp', 'cuda'],
\   },
\   'pyright-langserver': {
\     'allowlist': ['python'],
\   },
\   'basedpyright-langserver': {
\     'allowlist': ['python'],
\   },
\}

" Do not prompt to install missing language servers
let g:lsp_settings_enable_suggestions = 0
function! s:compass_python_lsp_default() abort
  for l:server in ['basedpyright-langserver', 'pyright-langserver', 'jedi-language-server', 'pylsp']
    if exists('*lsp_settings#executable') && lsp_settings#executable(l:server)
      return l:server
    endif
  endfor
  return ''
endfunction
let g:lsp_settings_filetype_python = [function('<SID>compass_python_lsp_default')]

" Search the standard Windows LLVM install location for clangd.
let g:lsp_settings_extra_paths = [
\   'C:/Program Files/LLVM/bin',
\   expand('~/AppData/Roaming/npm'),
\   expand('~/AppData/Local/Programs/Python/Python314/Scripts'),
\]

" Compass project-local Vim LSP configuration loader
" The repository generator creates .clangd-lsp/vim_lsp.vim from the current Git HEAD.
function! s:load_compass_project_lsp() abort
  if &buftype !=# '' || empty(expand('%:p'))
    return
  endif
  let l:gitdir = finddir('.git', expand('%:p:h') . ';' )
  let l:gitfile = findfile('.git', expand('%:p:h') . ';' )
  if empty(l:gitdir) && empty(l:gitfile)
    return
  endif
  let l:gitentry = !empty(l:gitdir) ? l:gitdir : l:gitfile
  let l:config = fnamemodify(l:gitentry, ':h') . '/.clangd-lsp/vim_lsp.vim'
  if !filereadable(l:config)
    return
  endif
  if get(g:, 'compass_lsp_project_config', '') !=# l:config
    unlet! g:compass_repo_lsp_loaded
    unlet! g:compass_repo_lsp_diagnostics
    execute 'source ' . fnameescape(l:config)
    let g:compass_lsp_project_config = l:config
  endif
  setlocal omnifunc=lsp#complete
  if exists('*lsp#disable_diagnostics_for_buffer')
    if get(g:, 'compass_repo_lsp_diagnostics', 0)
      call lsp#enable_diagnostics_for_buffer()
    else
      call lsp#disable_diagnostics_for_buffer()
    endif
  endif
endfunction

augroup compass_project_lsp_loader
  autocmd!
  autocmd BufReadPost,BufNewFile,BufEnter * call <SID>load_compass_project_lsp()
augroup END

set guifont=Lucida_Console:h12:cANSI:qDRAFT
