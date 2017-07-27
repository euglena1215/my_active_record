require './non_active_record.rb'
require './user.rb'

set_database('./db_test.sqlite3', :sqlite3)

user = User.new
