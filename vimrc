" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

set nocompatible " 不兼容vi模式，需要最先设置，否则对其他设置有影响

" 判断操作系统类型
function! OSX()
    return has('macunix')
endfunction
function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! WINDOWS()
    return (has('win16') || has('win32') || has('win64'))
endfunction

source ~/.vim/plug.vim

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup " 保存文件时不备份旧文件
set history=100		" keep 100 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" 显示正在输入的命令

"  不使用EX 模式
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" 支持鼠标
if has('mouse')
  set mouse=a
endif

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  filetype plugin indent on
  augroup vimrcEx
  au!
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  " 打开文件光标自动跳转到上一次退出的位置
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" 查看文件在上次保存之后做的更改
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif


let mapleader = ","  " 这个leader就映射为逗号“，”

"set nowrap " 超出一行时不折行
"set noerrorbells " 错误时不响铃
set number " 显示行号
set smartindent "  智能对齐
" 第一行设置tab键为4个空格，第二行设置当行之间交错时使用4个空格
set tabstop=4
set shiftwidth=4
set showmatch " 高亮显示匹配的括号
set matchtime=1 " 高亮时间（十分之一秒）
"中文编码
let &termencoding=&encoding
set fileencodings=utf-8,gbk,ucs-bom,cp936

set scrolloff=5 " 光标上下两侧保留的最少行数

"折叠
set foldenable " 允许折叠
:autocmd FileType * exec ":call SetFold()"
func! SetFold()
	if &filetype=='cpp' || &filetype=='java'
		set foldmethod=syntax "用语法高亮定义折叠
	elseif &filetype=='python' || &filetype=='sh'
		set foldmethod=indent "用缩进定义折叠
	else
		set foldmethod=manual "手工定义折叠
	endif
endfunc

set foldlevel=99 " 打开文件默认不折叠

set completeopt=preview,menu " 代码补全

" 配色
colorscheme desert

" 查找与替换
set incsearch	" 增量搜索
set nohlsearch " 取消搜索高亮
set ignorecase " 搜索模式忽略大小写
set smartcase " 如果搜索包含大写，不使用 ignorecase

" 设置常用快捷键
"nnoremap <leader>c <ESC>mpgg"+yG`p
"vnoremap <leader>c "+y
"nnoremap <leader>v <ESC>"+p
nnoremap <leader>cw :cwindow<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprevious<CR>
nnoremap <F12> <ESC>mpgg=G`p

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"注释与反注释
:autocmd FileType * exec ":call SetNotes()"

func! SetNotes()
	if &filetype=='cpp' || &filetype=='java'
		nnoremap <buffer> <leader>a <ESC>:s#^#//<CR>i<ESC>
		vnoremap <buffer> <leader>a <ESC>:'<,'>s#^#//<CR>i<ESC>
		nnoremap <buffer> <leader>d <ESC>:s#^\(\s*\)//\(\s*\)#\1\2<CR>i<ESC>
		vnoremap <buffer> <leader>d <ESC>:'<,'>s#^\(\s*\)//\(\s*\)#\1\2<CR>i<ESC>
	elseif &filetype=='sh' || &filetype=='py'
		nnoremap <buffer> <leader>a <ESC>:s/^/#<CR>i<ESC>
		vnoremap <buffer> <leader>a <ESC>:'<,'>s/^/#<CR>i<ESC>
		nnoremap <buffer> <leader>d <ESC>:s/^\(\s*\)#\(\s*\)/\1\2<CR>i<ESC>
		vnoremap <buffer> <leader>d <ESC>:'<,'>s/^\(\s*\)#\(\s*\)/\1\2<CR>i<ESC>
	endif
endfunc

"设置编译运行
map <F9> :call CompileRun()<CR><CR><CR>
map <F8> :call Run()<CR>
func! Run()
	if &filetype=='cpp'
		exec "!./a.out"
	elseif &filetype=='java'
		exec "!java Main"
	elseif &filetype=='sh'
		exec "w"
		exec "!bash %"
	elseif &filetype=='python'
		exec "w"
		exec "!python %"
	endif
endfunc

func! CompileRun()
	exec "w"
	call SetCompile()
	exec "make"
	exec "cw 6"
endfunc

func! SetCompile()
	if &filetype=='cpp'
		set makeprg=g++-5\ -std=c++11\ %
	elseif &filetype=='java'
		set makeprg=javac\ %
	elseif &filetype=='dot'
		set makeprg=dot\ -Tpng\ -o%<.png\ %
	endif
endfunc

if has("gui_running")&&LINUX()
	" 设置gvim 字体和行间距
	set guifont=Courier\ New\ Bold\ 13
	set linespace=-5
	set guioptions=
endif

" vim-easy-align
map <leader>e <Plug>(EasyAlign)

" cpp enhanced highlight
let g:cpp_class_scope_highlight=1
let g:cpp_member_variable_highlight=1
let g:cpp_class_decl_highlight=1
let g:cpp_experimental_simple_template_highlight=1
let g:cpp_concepts_highlight=1

" taglist
nnoremap <leader>tt :TlistToggle<CR>
nnoremap <leader>tu :TlistUpdate<CR>
"let Tlist_Use_Right_Window=1 " 窗口显示在右边
"let Tlist_Show_One_File=1 " 只显示当前文件的tag
"let Tlist_Sort_Type='name' " tag排序规则为以名字排序
"let Tlist_GainFocus_On_ToggleOpen=1 " 打开窗口即获得焦点
"let Tlist_Auto_Update=0 " 禁止自动更新标签
let Tlist_Max_Submenu_Items=20 " 设置子目录项目最大个数
let Tlist_File_Fold_Auto_Close=1 " 关闭其他文件的标签
let Tlist_Display_Prototype=1 " 显示标签的原型，默认只显示名称
let Tlist_Use_SingleClick=1 " 单击跳转，默认双击
let Tlist_Exit_OnlyWindow=1 " 如果taglist是最后一个窗口则退出
let Tlist_WinWidth=30 " 窗口宽度
"let Tlist_Ctags_Cmd='/usr/bin/ctags' " ctags路径

" The-NERD-tree
nnoremap <leader>l :NERDTreeToggle<CR>
"let loaded_nerd_tree=1 " 禁用NERDTree
let NERDTreeQuitOnOpen=1 " 打开文件后关闭目录
let NERDTreeWinPos='left' " 窗口显示位置
let NERDTreeWinSize=25 " 窗口宽度

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py' " 配置文件
nnoremap <leader>jd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>jf :YcmCompleter FixIt<CR>
nnoremap <leader>jt :YcmCompleter GetType<CR>

let g:ycm_confirm_extra_conf=0 " 关闭载入配置文件提示
"let g:ycm_autoclose_preview_window_after_completion = 1 " 补全后关闭预览
let g:ycm_autoclose_preview_window_after_insertion = 1 " 离开输入模式后关闭预览
let g:ycm_max_diagnostics_to_display = 30 " 最多显示多少错误提示
let g:ycm_key_invoke_completion='<S-Space>' " 自动补全快捷键
let g:ycm_seed_identifiers_with_syntax=1 "语法关键字补全
let g:ycm_min_num_of_chars_for_completion=2 " 从第几个字符开始补全
let g:ycm_warning_symbol = '>' " 警告标识
let g:ycm_min_num_identifier_candidate_chars = 0 " 提示的标识符最小长度
let g:ycm_complete_in_comments = 1 " 在注释里也补全
let g:ycm_complete_in_strings = 1 " 在字符串里也补全
let g:ycm_disable_for_files_larger_than_kb = 1000 " 文件过大不检测
let g:ycm_key_detailed_diagnostics='<leader>je' " 显示详细错误信息

let g:close_open_ycm = 1
noremap <leader>jj :call CloseOrOpenYcm()<CR>
function! CloseOrOpenYcm()
	if g:close_open_ycm==1
		let g:close_open_ycm=0
		let g:ycm_auto_trigger=0
		"let g:ycm_filetype_whitelist={}
	else
		let g:close_open_ycm=1
		let g:ycm_auto_trigger=1
		"let g:ycm_filetype_whitelist={'*' : 1}
	endif
endfunction

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'skywind3000/asyncrun.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'
Plug 'luochen1990/rainbow' " 彩色括号
Plug 'scrooloose/nerdtree'
Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

let g:rainbow_active = 1
