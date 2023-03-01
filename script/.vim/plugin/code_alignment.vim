
" Uasge: 
"           1) visual/select mode
"              select multiple lines then press shortcut <F7>
"              # you can remap shortcut in ~/.vimrc (e.g.: xmap x <Plug>AlignCode).
"
"           2) command mode
"           [range]AC       # align with default keys
"           [range]ACK key  # align with specified key
"           [range]ACP b:AC_pattern # align with specified b:AC_pattern
"
"           :1,10AC
"           :1,10ACK =
"           :1,10ACP '\u'
"
"

if exists("loaded_code_alignment") || &cp || version < 700
    finish
endif

let loaded_code_alignment = 1 

command! -nargs=1 -range AC  :call <SID>AlignCode(<line1>,<line2>)
command! -nargs=1 -range ACK :call <SID>AlignCodeWithKey(<q-args>,<line1>,<line2>,1)
command! -nargs=1 -range ACP :call <SID>AlignCodeWithKey(<args>,<line1>,<line2>,1)

vnoremap <Plug>AlignCode  :AC<CR>
if !hasmapto('<Plug>AlignCode','v')
    xmap <F7> <Plug>AlignCode
endif
if !hasmapto('<Plug>AlignCode','n')
    nmap <F7> gv<Pl>AlignCode
endif

let s:AC_keys = ['==','=','(',')',',',';']

function! s:AlignCodeWithKey(key,start,end,flag)
    let K = a:key

    let b:AC_index = []
    let b:AC_lines = []
    let b:AC_infos = []

    let b:AC_pattern = K
    if K == '='
        let b:AC_pattern = '[<>=!]\@<!==\@!'
    elseif K == '=='
        let b:AC_pattern = '\%([=!]=\|[<>]=\?\)'
    elseif K == ':'
        let b:AC_pattern = ':\@<!::\@!'
    endif

    silent! exec a:start . ',' . a:end . 's/\t/' . repeat(" ",&sw) . '/g'

    let lnum = a:start
    while ( lnum <= a:end )
        let line = getline(lnum)
        let index = match(line,b:AC_pattern)
        if index > 0 
            let index_end = matchend(line,b:AC_pattern)
            let lspace = strlen(matchstr(strpart(line,0,index),'\s*$'))
            let rspace = strlen(matchstr(strpart(line,index_end),'^\s*'))
            call add(b:AC_infos, [lspace, index_end-index, rspace])
            call add(b:AC_index, index)
            call add(b:AC_lines, lnum)
        endif
        let lnum = lnum + 1 
    endwhile

    if !empty( b:AC_index )

        let max=max(b:AC_index)
        let min=min(b:AC_index)

        let lspace_min = min(map(copy(b:AC_infos),'v:val[0]'))
        let lspace_max = max(map(copy(b:AC_infos),'v:val[1]'))
        let rspace_min = min(map(copy(b:AC_infos),'v:val[2]'))
        let rspace_max = max(map(copy(b:AC_infos),'v:val[2]'))

        let align_position = max + 1 - lspace_min + ( lspace_min ? 1 : 0 )

        if max == min && lspace_min <= 1 && rspace_min <= 1 && rspace_max <= 1
            echo "[" . K . '] already aligned !'
            return
        endif 

        for lnum in b:AC_lines

            " get current info
            let curr_info = get(b:AC_infos,index(b:AC_lines,lnum))

            " if has rspace, adjust to min 1 
            let rspace_adj = curr_info[2] ? (keylen_max - curr_info[1] + 1) : 0 

            exec lnum . 's/' . b:AC_pattern . '\s*/'
                        \ . '\=printf("' . repeat(" ",(max-min+1))
                        \ . '%s",substitute(submatch(0),"\\s\\+$","'
                        \ . repeat(" ", rspace_adj) . '",""))'
            exec lnum . 's/\%' . align_position . 'v\s*'

        endfor

        echo "[" . K . "] align  done !"
    elseif a:flag
        echo "[" . K . '] not found !'
    endif 

endfunction

function! s:AlignCode(start,end)
    for item in s:AC_keys
        call s:AlignCodeWithKey(item,a:start,a:end,0)
    endfor
endfunction

" vim:ts=4:sw=4:ft=vim




