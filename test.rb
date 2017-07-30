require './non_active_record.rb'

set_database('./db_test.sqlite3', :sqlite3)

require './post.rb'
require './user.rb'

u = User.find 1

user = User.new


db = Sqlite3Core.new
db.open('./db_test.sqlite3')
db.update('users', {age: 1000} ,1)
