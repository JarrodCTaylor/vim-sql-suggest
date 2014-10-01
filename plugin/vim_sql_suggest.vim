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
function! UpdateCompletionList(completeFor, wordToComplete)
python << endPython
complete_for = vim.eval("a:completeFor")
if complete_for == "table":
    vim.command("let b:list = {}".format(get_table_names(vim.eval("g:suggest_db"))))
else:
    vim.command("let b:list = {}".format(get_column_names(vim.eval("g:suggest_db"), vim.eval("a:wordToComplete"))))
endPython
endfunction

function! SQLComplete(completeFor)
    " TODO break this out to a update l:word function
    if getline(".")[col(".")-2] == " "
        let l:word = ""
    else
        execute "normal! b"
        let l:word = expand('<cWORD>')
    endif
    let l:position = col('.')
    execute "normal! A\<space>"
    call UpdateCompletionList(a:completeFor, l:word)
    " TODO break this out to a update l:matches function
    " Words ending with a '.' are tables and we want all columns
    if l:word[len(l:word) - 1] == "."
        let l:matches = b:list
    else
        let l:matches = []
        for item in b:list
            if(match(item["word"],'^'.l:word)==0)
                call add(l:matches,item)
            endif
        endfor
    endif
    redraw!
    call complete(l:position, l:matches)
    return ''
endfunc

function! UpdateSuggestDB()
python << endPython
def python_input(message = 'input'):
    vim.command('call inputsave()')
    vim.command("let user_input = input('" + message + ": ')")
    vim.command('call inputrestore()')
    return vim.eval('user_input')

current_db = int(vim.eval('exists("g:suggest_db")'))
print("The current database is: {}".format(vim.eval("g:suggest_db") if current_db else "Undefined"))
new_db = python_input("Enter the desired DB")
vim.command('let g:suggest_db = "{}"'.format(new_db))
endPython
endfunction

command! UpdateSuggestDB call UpdateSuggestDB()
