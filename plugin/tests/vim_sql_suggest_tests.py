import unittest
from mock import patch
import vim_sql_suggest as sut


class VimSqlSuggestTests(unittest.TestCase):

    def test_get_db_specific_query_statuments_with_mysql_database_connection(self):
        table_query, column_query = sut.get_db_specific_query_statements("mysql -u root test")
        self.assertEqual(table_query, "-e 'SHOW tables;'")
        self.assertEqual(column_query, "-e 'SHOW COLUMNS FROM")

    def test_get_db_specific_query_statuments_with_psql_database_connection(self):
        table_query, column_query = sut.get_db_specific_query_statements("psql -U Jrock test")
        self.assertEqual(table_query, "-c \"select tablename from pg_tables where schemaname = 'public'\"")
        self.assertEqual(column_query, "-c \"select column_name from information_schema.columns where table_name = ")

    @patch('subprocess.check_output')
    def test_get_table_names_for_mysql(self, sb_output):
        sb_output.return_value = "Tables_in_test\ntable1\ntable2\ntable3"
        table_list = sut.get_table_names("mysql -u root test")
        self.assertEqual(table_list, ["table1", "table2", "table3"])

    @patch('subprocess.check_output')
    def test_get_table_names_for_psql(self, sb_output):
        sb_output.return_value = " tablename\n----------\n table1\n table2\n table3\n(3 rows)"
        table_list = sut.get_table_names("psql -U Jrock test")
        self.assertEqual(table_list, ["table1", "table2", "table3"])

    @patch('subprocess.check_output')
    def test_get_column_names_for_mysql(self, sb_output):
        with patch('subprocess.check_output', side_effect=["Tables_in_test\ntable1\ntable2",
                                                           "Field\tType\tNull\tKey\tDefault\tExtra\nid\tint(11)\tNO\tPRI\tNULL\tauto_increment\nthing\tvarchar(100)\tNO\tNULL\t",
                                                           "Field\tType\tNull\tKey\tDefault\tExtra\nid\tint(11)\tNO\tPRI\tNULL\tauto_increment\nthing\tvarchar(100)\tNO\tNULL\t"]):
            col_list = sut.get_column_names("mysql -u root test")
            expected_return_val = [{'dup': 1, 'menu': 'table1', 'word': 'id'},
                                   {'dup': 1, 'menu': 'table1', 'word': 'thing'},
                                   {'dup': 1, 'menu': 'table2', 'word': 'id'},
                                   {'dup': 1, 'menu': 'table2', 'word': 'thing'}]
            self.assertEqual(col_list, expected_return_val)

    @patch('subprocess.check_output')
    def test_get_column_names_for_psql(self, sb_output):
        with patch('subprocess.check_output', side_effect=[" tablename\n----------\n table1\n table2\n(2 rows)",
                                                           " column_name\n----------\n id\n thing\n(2 rows)",
                                                           " column_name\n----------\n id\n stuff\n(2 rows)"]):
            col_list = sut.get_column_names("psql -U Jrock test")
            expected_return_val = [{'dup': 1, 'menu': 'table1', 'word': 'id'},
                                   {'dup': 1, 'menu': 'table1', 'word': 'thing'},
                                   {'dup': 1, 'menu': 'table2', 'word': 'id'},
                                   {'dup': 1, 'menu': 'table2', 'word': 'stuff'}]
            self.assertEqual(col_list, expected_return_val)
