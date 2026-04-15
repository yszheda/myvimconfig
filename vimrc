
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
" set the font
" set gfw=幼?:h10:cGB2312

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
