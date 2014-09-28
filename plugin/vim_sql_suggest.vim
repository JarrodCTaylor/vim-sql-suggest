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
" psql libexample -c "select tablename from pg_tables where schemaname = 'public'"
" psql libexample -c "select column_name from information_schema.columns where table_name = 'users'"

" --------------------------------
"  Function(s)
" --------------------------------
function! UpdateTableNames()
python << endPython
query_string = "{0} -e 'SHOW tables;'".format(vim.eval("g:suggest_db"))
tables = subprocess.check_output(query_string, shell=True)
vim.command("let g:sql_tables = {}".format(tables[1:]))
endPython
endfunction

function! UpdateColNames()
python << endPython
try:
    vim.command("call UpdateTableNames()")
    table_cols = []
    for table in vim.eval("g:sql_tables"):
        query_string = "{0} -e 'SHOW COLUMNS FROM {1}'".format("mysql -u root test", table)
        columns = subprocess.check_output(query_string, shell=True)
        table_cols.extend([{"word": column.split("\t")[0], "menu": table, "dup": 1} for column in columns.rstrip().split("\n")[1:]])
    vim.command("let g:sql_suggest_columns = {}".format(table_cols))
except Exception as e:
    print(e)
endPython
endfunction

func! CompleteColumn()
        execute "normal! h"
        let l:word = expand('<cword>')
        let l:position = col('.')
        execute "normal! A\<space>"
        call UpdateColNames()
        let l:list = g:sql_suggest_columns
        let l:matches = []
        for item in l:list
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
inoremap <Leader>ci <C-R>=CompleteColumn()<CR>
