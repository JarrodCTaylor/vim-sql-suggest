" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import vim
python import os
python import subprocess
python sys.path.append(vim.eval('expand("<sfile>:h")'))

" --------------------------------
"  TEMP MOVE THIS WHERE IT BELONGS
" --------------------------------
let g:suggest_db = "mysql -u root test"
"let g:suggest_db = "psql -U Jrock libexample"

" --------------------------------
"  Function(s)
" --------------------------------
function! UpdateDBSpecificQueryStatements()
python << endPython
queries = {
  "psql_tables": "-c \\\"select tablename from pg_tables where schemaname = 'public'\\\"",
  "psql_columns": "-c \\\"select column_name from information_schema.columns where table_name = 'users'\\\"",
  "mysql_tables": "-e 'SHOW tables;'",
  "mysql_columns": "-e 'SHOW COLUMNS FROM"
}
db_type = vim.eval("g:suggest_db").split(" ")[0]
get_tables_query = queries[db_type + "_tables"]
get_columns_query = queries[db_type + "_columns"]
vim.command("let b:get_tables_query = \"{}\"".format(get_tables_query))
vim.command("let b:get_columns_query = \"{}\"".format(get_columns_query))
endPython
endfunction

function! UpdateTableNames()
python << endPython
query_string = "{0} {1}".format(vim.eval("g:suggest_db"), vim.eval("b:get_tables_query"))
tables = subprocess.check_output(query_string, shell=True)
vim.command("let g:sql_suggest_tables = {}".format(tables.rstrip().split("\n")[1:]))
endPython
endfunction

function! UpdateColNames()
python << endPython
vim.command("call UpdateTableNames()")
table_cols = []
for table in vim.eval("g:sql_suggest_tables"):
    query_string = "{0} {1} {2}'".format(vim.eval("g:suggest_db"), vim.eval("b:get_columns_query"), table)
    columns = subprocess.check_output(query_string, shell=True)
    table_cols.extend([{"word": column.split("\t")[0], "menu": table, "dup": 1} for column in columns.rstrip().split("\n")[1:]])
vim.command("let g:sql_suggest_columns = {}".format(table_cols))
endPython
endfunction

function! UpdateCompletionList(completeFor)
    call UpdateDBSpecificQueryStatements()
    if a:completeFor == "table"
        call UpdateTableNames()
        let b:list = g:sql_suggest_tables
    else
        call UpdateColNames()
        let b:list = g:sql_suggest_columns
    endif
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

" --------------------------------
"  Expose our commands to the user
" --------------------------------
" --------------------------------
"  This does not need to stay
inoremap <Leader>cc <C-R>=SQLComplete("column")<CR>
inoremap <Leader>ct <C-R>=SQLComplete("table")<CR>
