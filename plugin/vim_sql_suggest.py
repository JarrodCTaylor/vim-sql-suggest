import subprocess


def get_db_specific_query_statements(suggest_db):
    queries = {
        "psql_tables": "-c \"select tablename from pg_tables where schemaname = 'public'\"",
        "psql_columns": "-c \"select column_name from information_schema.columns where table_name = ",
        "mysql_tables": "-e 'SHOW tables;'",
        "mysql_columns": "-e 'SHOW COLUMNS FROM"
    }
    db_type = suggest_db.split(" ")[0]
    return (queries[db_type + "_tables"], queries[db_type + "_columns"])


def get_table_names(suggest_db):
    get_tables_query, _ = get_db_specific_query_statements(suggest_db)
    query_string = "{0} {1}".format(suggest_db, get_tables_query)
    tables = subprocess.check_output(query_string, shell=True)
    if suggest_db.split(" ")[0] == "mysql":
        return tables.rstrip().split("\n")[1:]
    elif suggest_db.split(" ")[0] == "psql":
        return [table.strip() for table in tables.rstrip().split("\n")[2:-1]]


def get_column_names(suggest_db):
    table_cols = []
    for table in get_table_names(suggest_db):
        if suggest_db.split(" ")[0] == "mysql":
            query_string = "{0} {1} {2}'".format(suggest_db, get_db_specific_query_statements(suggest_db)[1], table)
            columns = subprocess.check_output(query_string, shell=True)
            table_cols.extend([{"word": column.split("\t")[0], "menu": table, "dup": 1} for column in columns.rstrip().split("\n")[1:]])
        elif suggest_db.split(" ")[0] == "psql":
            query_string = "{0} {1} '{2}'\"".format(suggest_db, get_db_specific_query_statements(suggest_db)[1], table)
            columns = subprocess.check_output(query_string, shell=True)
            table_cols.extend([{"word": column.strip(), "menu": table, "dup": 1} for column in columns.rstrip().split("\n")[2:-1]])
    return table_cols
