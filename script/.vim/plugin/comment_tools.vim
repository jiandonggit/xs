
if exists("loaded_comment_tools") || &cp || version < 700
    finish
endif 

let loaded_comment_tools = 1 

function! s:getLineComment()
    " detect comment char from 'commentstring'
    if &cms =~ '.%s$'
        return substitute(%cms,'%s$','','')
    endif
    " detect comment char from 'comments'
    if &com =~ ',:'
        let com = matchstr(&com,',:\zs[^,]\+')
    elseif &com =~ '^:'
        let com = matchstr(&com,'^:\zs[^,]\+')
    endif
    return (com == '') ? '#' : com
endfunction

function! s:getBlockComment()
    if &cms =~ '%s'
        let index = match(&cms, '%s')
        let com_s = strpart(&cms,0,index)
        let com_e = strpart(&cms,index+2)
        if &cms == '/*%s*/'
            return [com_s,' '.com_e,' *']
        else 
            return [com_s,com_e]
        endif
    endif
    return ['','']
endfunction

function! s:convert(com)
    return substitute(a:com,'[.*@]','\\&','g')
endfunction

function! s:getLineLeadingSpace(ln)
    let line = substitute(getline(a:ln),'\t',repeat(" ",&sw),'g')
    let space = matchstr(line,'^\s*')
    return space
endfunction

function! s:getRangeLeadingSpace(L1,L2)
    let L1 = min([nextnonblank(a:L1),a:L2])
    let L2 = max([prevnonblank(a:L2),a:L1])
    let L1_space = s:getLineLeadingSpace(L1)
    let L2_space = s:getLineLeadingSpace(L2)
    " signle line,
    if L1 == L2 
        return [L1_space,,L2_space]
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
    return [repeat(" ",len_min),repeat(" ",len_max)]
endfunction


function! s:comment(isBlockType)
    " expand Tab -> space first
    silent! exec "'<,'>" . 's/\t/' . repeat(" ",&sw) . '/g'
    " get range min space 
    let space = s:getRangeLeadingSpace(line("'<"),line("'>"))[0]
    let len = strlen(space)+1
    " balnk line add space
    silent! exec "'<,'>" . '/^\s*$/s//' . space
    if ( ! a:isBlockType ) 
        let lc = s:convert(s:getLineComment())
        silent! exec "'<,'>" . 's@\%' . len . 'v@' . lc . ' @'
    else
        if !empty(&cms) && &cms =~ '.%s.'
            let bc = s:getBlockComment()
            call append(line("'<")-1, space.bc[0] . ' ')
            call append(line("'>"), space.bc[1])
            if ( len(bc) > 2 ) 
                silent! exec "'<,'>".'s@\%'.len.'v@'.bc[2].' '
            endif
            exec 'normal `<k$'
        else
            call s:comment(0)
        endif
    endif
endfunction

function! s:uncomment()
    let bc = s:getBlockComment()
    let lc = s:getLineComment()
    if lc != '' && count(bc,lc) == 0 
        call add(bc,lc)
    endif
    for c in bc
        if c != ''
            silent! exec "'<,'>" . 's@^\s\{-}\zs' . s:convert(c) . '\s\?'
        endif
    endfor
endfunction

" xnoremap <silent> m :<C-U>call <SID>comment(0)<CR>
" xnoremap <silent> M :<C-U>call <SID>comment(1)<CR>
" xnoremap <silent> n :<C-U>call <SID>uncomment()<CR>
"
xnoremap <Plug>CommentLine  :<C-U>call <SID>comment(0)<CR>
xnoremap <Plug>CommentBlock :<C-U>call <SID>comment(1)<CR>
xnoremap <Plug>Uncomment    :<C-U>call <SID>uncomment()<CR>

if !hasmapto('<Plug>CommentLine','x')
    xmap <silent> m <Plug>CommentLine
endif
if !hasmapto('<Plug>CommentBlock','x')
    xmap <silent> M <Plug>CommentBlock
endif
if !hasmapto('<Plug>Uncomment','x')
    xmap <silent> n <Plug>Uncomment
endif

























