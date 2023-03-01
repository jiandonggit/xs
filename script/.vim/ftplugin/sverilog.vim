
if exists("b:did_sverilog_ftplugin") || &cp
    finish
endif

let b:did_sverilog_ftplugin = 1

setlocal  define=^\\s*\\(`\\s*define\\\|parameter\\)
setlocal  include=^\\s*`\\s*include
setlocal  dict+=~/.vim//ftplugin/sverilog.vim
"setlocal dict+=$UVM_HOME/macros/*.svh
"setlocal com=s0:\ *\ -,m0:*\ \ ,ex0:*/,s1:/*m1:*,ex:*/,://
setlocal  formatoptions=tcorqlw
setlocal  nrformats=hex
setlocal  comments=s0:*\ -,m0:*\ \ ,ex0:*/,s1:/*,mb:*,ex:*/,://

"setlocal fdm=syntax  " large file will cause vim opening slowly
"setlocal fdc=3
"setlocal fdl=1
"setlocal nofen

if version >= 704
    setlocal formatoptions+=j
endif


abbr vir virtual
abbr ext extends
abbr fun function
abbr endf endfunction

if exists("loaded_matchit")
    let b:match_words = 
            \   '\<begin\>:\<end\>,' .
            \   '`ifn\?def\>:`el\%(se\|sif\)\>:`endif\>,' .
            \   '\<if\>:\<else\>,' .
            \   '\<function\>:\<endfunction\>,' .
            \   '\<task\>:\<endtask\>,' .
            \   '\<class\>:\<endclass\>,' .
            \   '\<module\>:\<endmodule\>,' .
            \   '\<sequence\>:\<endsequence\>,' .
            \   '\<property\>:\<endproperty\>,' .
            \   '\<package\>:\<endpackage\>,' .
            \   '\<clocking\>:\<endclocking\>,' .
            \   '\<covergroup\>:\<endgroup\>,' .
            \   '\<program\>:\<endprogram\>,' .
            \   '\<interface\>:\<endinterface\>,' .
            \   '\<protect\>:\<endprotect\>,' .
            \   '\<extends\>:\<endextends\>,' .
            \   '\<generate\>:\<endgenerate\>,' .
            \   '\<celldefine\>:\<endcelldefine\>,' .
            \   '\<case\%[xz]\>:\<endcase\>,' .
            \   '\<fork\>:\<join\%(_none\|_any\))\?\>,' .
            \   '\<specify\>:\<endspecify\>,' .
            \   '`uvm_timer_begin\>:`uvm_timer_end\>,' .
            \   '`fork_timer_begin\>:`fork_timer_begin\>' 

endif

function! s:getLineLeadingSpace(ln)
    let line = su(getline(a:ln),'\t',repeat(" ",&sw),'g')
    let space = matchstr(line,'^\s*')
    return space
endfunction

function! s:getRangeLeadingSpace(L1,L2)
    let L1 = min([nextnonblank(a:L1),a:L2])
    let L2 = max([prevnonblank(a:L2),a:L1])
    let L1_space = s:getLineLeadingSpace(L1)
    let L2_space = s:getLineLeadingSpace(L2)
    " single line,
    if L1 = L2
        return [L1_space,L2_space]
    endif
    " multi lines, return [min,max]
    let len_min = min([strlen(L1_space),strlen(L2_space)])
    let len_max = max([strlen(L1_space),strlen(L2_space)])
    while L1 < L2
        let L_space = s:getLineLeadingSpace(L1)
        let len_min = min([strlen(L_space),len_min])
        let len_max = max([strlen(L_space),len_max])
        let L1 = nextnonblank(L1+1)
    endwhile
    return [repeat(" ",len_min),repeat(" ",len_min)]
endfunction

function! s:insertBeginEnd()
    let space = s:getRangeLeadingSpace(line("'<"),line("'>"))[0]
    call append(line("'<")-1 ,space."begin")
    call append(line("'>") ,space."end")
    silent! exec "'<,'>s/^/".repeat(" ",&sw)
endfunction

function! s:comment(blockType)
    " convert Tab -> space first
    silent! exec "'<,'>" . 's/\t/' . repeat(" ",&sw) . '/g'
    " get range min space 
    let space = s:getRangeLeadingSpace(line("'<"),line("'>"))[0]
    let len = strlen(space)+1
    " blank line add space
    silent! exec "'<,'>" . '/^\s*$/s//' . space
    if( ! a:blockType )
        silent! exec "'<,'>" . 's#\%' . len . 'v#// #'
    else
        " range add *
        silent! exec "'<,'>" . 's#\%' . len . 'v# * #'
        " insert /* and */
        call append(line("'<")-1, space."/*")
        call append(line("'>"), space." */")
    endif
endfunction

function! s:uncomment()
    silent! exec "'<,'>" . 's#^\s\{-}\zs\(\/\*\+\|\*\+\/\|\/\/\s\?\)#'
    silent! exec "'<,'>" . 's#^\s\{-}\zs\(\s\*\s\?\)#'
endfunction

"vnoremap <Plug>VaddBE :<C-U>call <SID>insertBeginEnd()<CR>
"xmap b <Plug>VaddBE
xnoremap <silent> b :<C-U>call <SID>insertBeginEnd()<CR>

" add comment/uncomment 
if !hasmapto('m','x') | xnoremap <silent> m :<c-u>call <sid>comment(0)<cr> | endif
if !hasmapto('M','x') | xnoremap <silent> m :<c-u>call <sid>comment(1)<cr> | endif
if !hasmapto('n','x') | xnoremap <silent> n :<c-u>call <sid>uncomment()<cr>| endif

function! s:sv_insert_define_header0()
    let name = substitute(bufname('%'),'^.*/','','')
    let define = toupper(substitute(name,'\.','_','g'))
    if exists(":DoxLic") && 0 
        silent! exec ":DoxLic"
    else
        call append(0,' */')
        call append(0,' * ')
        call append(0,' * Description: ')
        call append(0,' * Revision: 1.0, '. $USER . strftime(" @%Y/%m/%d %T"))
        call append(0,' * ' .repeat('-',64))
        call append(0,' * History:')
        call append(0,' * ')
        call append(0,' * Create : ' . strftime("%F"))
        call append(0,' * Author : ' . $USER )
        call append(0,' * File   : ' . expand('%:t'))
        call append(0,' * ')
        call append(0,' * Copyright (C) xxx Electronic Technology Co., Ltd ')
        call append(0,'/*')
    endif
    call append(line('$'),'`ifndef __' .define . '__')
    call append(line('$'),'`define __' .define . '__')
    call append(line('$'),'')
    call append(line('$'),'`endif')
    call append(line('$'),'')
    call append(line('$'),'// vim: et:ts=4:sw=4:ft=sverilog')
    silent! exec "norm! 2jo\n"
endfunction

command! -nargs=0 SVIDH :call <SID>sv_insert_define_header0()




