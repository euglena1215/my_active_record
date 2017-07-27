require 'sqlite3_core'

class Sqlite3 < Database
	def initialize(db_name)
		@db = Sqlite3Core.new
		
		unless @db.open(db_name)
			raise "Can't open database(#{db_name})"
		end
	end

	def select(table_name, condition, where)
		@db.select(table_name, condition, where)
	end

	# column_name: :type のhashを返す
	def table_schema(table_name)
		hash = Hash.new
		schema = @db.select('sqlite_master', '*', nil)
					.select { |table| table["name"] == table_name }

		if schema.empty?
			raise "Not exist table #{table_name}"
		end

		schema[0]['sql'].split('(')[1]
			.split(')')[0]
			.split(',').map { |c| arr = c.split; hash[arr[0].to_sym] = arr[1].to_sym }

		hash
	end

	def column_name(table_name)
		table_schema(table_name).keys
	end
end
