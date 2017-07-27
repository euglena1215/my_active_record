require 'sqlite3_core'

sqlite3 = Sqlite3Core.new
sqlite3.open './db_test.sqlite3'
p sqlite3.exec 'select * from tb_test'
p sqlite3.select('sqlite_master', '*', nil)
# p sqlite3.insert('tb_test', [7, 'jjj', 20])
# p sqlite3.add_column('tb_test', 'age', 'integer')
sqlite3.close