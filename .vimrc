" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal g'\"" | endif
"endif

" Uncomment the following to have Vim load indentation rules according to the
" detected filetype. Per default Debian Vim only load filetype specific
" plugins.
"if has("autocmd")
"  filetype indent on
"endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes) in terminals

" Source a global configuration file if available
" XXX Deprecated, please move your changes here in /etc/vim/vimrc
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

if filereadable("/usr/share/vim/vim71/vimrc_example.vim")
  source /usr/share/vim/vim71/vimrc_example.vim
endif

if filereadable("/usr/share/vim/vim72/vimrc_example.vim")
  source /usr/share/vim/vim72/vimrc_example.vim
endif

if filereadable("/usr/share/vim/vim73/vimrc_example.vim")
  source /usr/share/vim/vim73/vimrc_example.vim
endif

if filereadable("/usr/share/vim/vim74/vimrc_example.vim")
  source /usr/share/vim/vim74/vimrc_example.vim
endif

if filereadable("/usr/share/vim/vim80/vimrc_example.vim")
  source /usr/share/vim/vim80/vimrc_example.vim
endif

" --- gallen add begin ---
colors desert
"set ts=2
set tabstop=2
set shiftwidth=2
nnoremap <silent> <f12> :TlistToggle<cr>
nnoremap <silent> <f9> :wincmd p<cr>
nnoremap <silent> <f5> :bn<cr>
nnoremap <silent> <f6> :bp<cr>
nnoremap <silent> <f7> :b#<cr>
let Tlist_Exit_OnlyWindow = 1

" for utf8 , big5 edit ...
let &termencoding=&encoding
set encoding=utf8
set fileencodings=utf-8,big5,gbk,ucs-bom,cp950,cp936

" for cflow plug in ...
au BufNewFile,BufRead *.cflow setf cflow

set guifont=Courier\ New\ 11

set nowrap              " don't wrap by default
set tw=0                " don't jump to newline after col 80

" --- gallen add end ---
