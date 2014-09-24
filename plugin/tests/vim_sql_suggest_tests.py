import unittest
import vim_sql_suggest as sut


@unittest.skip("Don't forget to test!")
class VimSqlSuggestTests(unittest.TestCase):

    def test_example_fail(self):
        result = sut.vim_sql_suggest_example()
        self.assertEqual("Happy Hacking", result)
