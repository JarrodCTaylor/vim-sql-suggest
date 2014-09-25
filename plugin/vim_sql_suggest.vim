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

" --------------------------------
"  Function(s)
" --------------------------------
function! TemplateExample()
python << endOfPython

from vim_sql_suggest import vim_sql_suggest_example

for n in range(5):
    print(vim_sql_suggest_example())

endOfPython
endfunction

function! UpdateTableNames()
python << endPython
tbls = subprocess.check_call("{0} -e 'SHOW tables;' > /tmp/db-tables.txt".format(vim.eval("g:suggest_db")), shell=True)
def read_file_lines(file_to_read):
    if os.path.isfile(file_to_read):
        with open(file_to_read, "r") as f:
            return [l.rstrip('\n') for l in f.readlines()]
tables = read_file_lines("/tmp/db-tables.txt")
vim.command("let g:sql_tables = {}".format(tables[1:]))
endPython
endfunction

function! UpdateColNames()
python << endPython

def read_file_lines(file_to_read):
    if os.path.isfile(file_to_read):
        with open(file_to_read, "r") as f:
            return [l.rstrip('\n') for l in f.readlines()]

try:
    # TODO make this actually loop through the table and build up the dict of columns
    table_cols = []
    if os.path.exists("/tmp/query-out.txt"):
        os.remove("/tmp/query-out.txt")
    for table in vim.eval("g:sql_tables"):
        subprocess.check_call("{0} -e 'SHOW COLUMNS FROM {1}' >> /tmp/query-out.txt".format(vim.eval("g:suggest_db"), table), shell=True)
    vim.command("let g:sql_suggest_columns = {}".format([{"word": column.split("\t")[0], "menu": vim.eval("g:suggest_tbl")} for column in read_file_lines("/tmp/query-out.txt")[1:]]))
    #[{"word": column.split("\t")[0], "menu": vim.eval("g:suggest_tbl")} for column in read_file_lines("/tmp/query-out.txt")[1:]]
except:
    pass
endPython
endfunction

func! CustomComplete()
        execute "normal! b"
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

" psql libexample -c "select tablename from pg_tables where schemaname = 'public'"
" psql libexample -c "select column_name from information_schema.columns where table_name = 'users'"
" --------------------------------
"  Expose our commands to the user
" --------------------------------
" --------------------------------
"  This does not need to stay
inoremap <Leader>ci <C-R>=CustomComplete()<CR>
" --------------------------------
command! Example call TemplateExample()
