

setlocal isf+=+,{,},(,)
setlocal isf-=,
setlocal includeexpr=CustomIncludeExpr(v:fname)
function! CustomIncludeExpr(fname)
    " convert '$(ENV)' to '${ENV}'
    let fname = substitute(a:fname,'\$(\(\w\+\))','${\1}','g')
    " remove C style lib/include prefix
    let fname = substitute(fname,'^-[IL]','','')
    " remove sverilog style include prefix
    let fname = substitute(fname,'^+incdir+','','')
    " remove '(NUM)'
    let fname = substitute(fname,'(\d*)','','g')
    " remove '(' not line '$('
    let fname = substitute(fname,'\$\@<!(','','g')
    " remove alone ')'
    let fname = substitute(fname,'\((.*\)\@<!)','','g')
    return fname
endfunction
