" --------------------------------
" Add our plugin to the path
" --------------------------------
python import sys
python import vim
python sys.path.append(vim.eval('expand("<sfile>:h")'))

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

function! UpdateColNames()
python << endPython
import vim
import subprocess
import os

def read_file_lines(file_to_read):
    if os.path.isfile(file_to_read):
        with open(file_to_read, "r") as f:
            return [l.rstrip('\n') for l in f.readlines()]

mysql_db = "mysql -u root test"
mysql_tbl = "tutorials_tbl"
try:
    tbl_info = subprocess.check_call("{0} -e 'SHOW COLUMNS FROM {1}' > /tmp/query-out.txt".format(mysql_db, mysql_tbl), shell=True)
    vim.command("let b:columns = {}".format([{"word": column.split("\t")[0], "menu": mysql_tbl} for column in read_file_lines("/tmp/query-out.txt")[1:]]))
except:
    pass
endPython
endfunction

func! CustomComplete()
        execute "normal! b"
        let b:word = expand('<cword>')
        let b:position = col('.')
        execute "normal! A\<space>"
        call UpdateColNames()
        let b:list = b:columns
        let b:matches = []
        for item in b:list
            if(match(item["word"],'^'.b:word)==0)
                call add(b:matches,item)
            endif
        endfor
        call complete(b:position, b:matches)
        return ''
endfunc

" psql libexample -c "select tablename from pg_tables where schemaname = 'public'"
" psql libexample -c "select column_name from information_schema.columns where table_name = 'users'"
" --------------------------------
"  Expose our commands to the user
" --------------------------------
command! Example call TemplateExample()
