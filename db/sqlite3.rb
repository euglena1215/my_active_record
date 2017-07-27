require 'sqlite3_core'

class Sqlite3
	include Database

	def initialize(db_name)
		@db = Sqlite3Core.new
		
		unless @db.open(db_name)
			raise "Can't open database(#{db_name})"
		end
	end

	def select(table_name, condition, where)
		@db.select(table_name, condition, where)
	end

	def column_name(table_name)
		schema = @db.select('sqlite_master', '*', nil)
					.select { |table| table["name"] == table_name }

		if schema.empty?
			raise "Not exist table #{table_name}"
		end

		schema[0]["sql"].split('(')[1]
			.split(')')[0]
			.split(',')
			.map { |column| column.split[0] }
	end
end
