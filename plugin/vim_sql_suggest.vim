" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import vim
python import os
python import subprocess
python sys.path.append(vim.eval('expand("<sfile>:h")'))
python from vim_sql_suggest import *

" --------------------------------
"  Function(s)
" --------------------------------
function! UpdateCompletionList(completeFor)
python << endPython
complete_for = vim.eval("a:completeFor")
if complete_for == "table":
    vim.command("let b:list = {}".format(get_table_names(vim.eval("g:suggest_db"))))
else:
    vim.command("let b:list = {}".format(get_column_names(vim.eval("g:suggest_db"))))
endPython
endfunction

function! SQLComplete(completeFor)
    execute "normal! h"
    let l:word = expand('<cword>')
    let l:position = col('.')
    execute "normal! A\<space>"
    call UpdateCompletionList(a:completeFor)
    let l:matches = []
    for item in b:list
        if(match(item["word"],'^'.l:word)==0)
            call add(l:matches,item)
        endif
    endfor
    call complete(l:position, l:matches)
    return ''
endfunc
