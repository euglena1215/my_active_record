require 'sqlite3_core'

class Sqlite3 < Database
	def initialize(db_name)
		@db = Sqlite3Core.new
		
		unless @db.open(db_name)
			raise "Can't open database(#{db_name})"
		end
	end

	def select(table_name, condition, where)
		records = @db.select(table_name, condition, where)
		formatted_records = format_records(records, table_name)
	end

	def insert(table_name, record)
		record_arr = []
		column_name(table_name).each do |column|
			if record.has_key?(column)
				record_arr << record[column]
			else
				record_arr << nil
			end
		end

		@db.insert(table_name, record_arr)
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

	private

	def format_records(records, table_name)
		schema = table_schema(table_name)

		formatted_records = []
		records.each do |record|
			formatted_record = {}
			record.each do |column, value|
				formatted_record[column.to_sym] = case schema[column.to_sym]
													when :integer then value.to_i
													when :text, :varchar then value
													when :numeric then value.to_f
												  end
			end
			formatted_records << formatted_record
		end
		formatted_records
	end
end
