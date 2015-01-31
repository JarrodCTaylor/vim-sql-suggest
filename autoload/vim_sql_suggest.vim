" ================================
" Plugin Imports
" ================================
python import sys
python import vim
python import os
python import subprocess
python sys.path.append(vim.eval('expand("<sfile>:h")'))
python from vim_sql_suggest import *

" ================================
" Plugin Function(s)
" ================================

"""
" The plugin offers to complete either table or columns names. This function
" delegates to the appropriate python function to populate the completionList
" with the desired contents.
"""
function! UpdateCompletionList(completeFor, wordToComplete)
python << endPython
complete_for = vim.eval("a:completeFor")
if complete_for == "table":
    vim.command("let b:completionList = {}".format(get_table_names(vim.eval("g:suggest_db"))))
else:
    vim.command("let b:completionList = {}".format(get_column_names(vim.eval("g:suggest_db"), vim.eval("a:wordToComplete"))))
endPython
endfunction

"""
" The complete function is called while in insert mode. We check the
" character that is two chars behind the cursor. If it is ' ' then the
" user hasn't specified a word to complete if there is a non ' ' character
" there then we grab the <cWORD> because we need to know if there is a '.'
" at the end of the word that has been entered.
"""
function! UpdateWordToComplete()
    if getline(".")[col(".")-2] == " "
        let b:wordToComplete = ""
    else
        execute "normal! b"
        let b:wordToComplete = expand('<cWORD>')
    endif
endfunction

"""
" If the word to complete ends with a '.' then we make the assumption that
" the dot is preceded with a table name and the user wants all of the
" columns for that table returned as complete options.
"""
function! UpdateMatches()
    if b:wordToComplete[len(b:wordToComplete) - 1] == "."
        let b:matches = b:completionList
    else
        let b:matches = []
        for item in b:completionList
            if(match(item["word"],'^'.b:wordToComplete)==0)
                call add(b:matches,item)
            endif
        endfor
    endif
endfunction

function! SQLComplete(completeFor)
    call UpdateWordToComplete()
    let l:cursorPosition = col('.')
    execute "normal! A\<space>"
    call UpdateCompletionList(a:completeFor, b:wordToComplete)
    call UpdateMatches()
    redraw!
    call complete(l:cursorPosition, b:matches)
    return ''
endfunc

"""
" A convenience function that informs the user of the current database and
" allows them to provide a connection to a new database.
"""
function! vim_sql_suggest#UpdateSuggestDB()
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
