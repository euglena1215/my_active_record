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
	def table_schema(table_name = nil)
		info = Hash.new
		schema = @db.select('sqlite_master', '*', nil)
		schema.each do |s|
			hh = Hash.new

			schema[0]['sql'].split('(')[1].split(')')[0].split(',').each do |c|
				arr = c.split
				hh[arr[0].to_sym] = arr[1].to_sym 
			end

			info[s['name']] = hh
		end

		return info if table_name.nil?

		info[table_name]
	end

	def column_name(table_name)
		table_schema(table_name).keys
	end
end
