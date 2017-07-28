class Database
	TYPE_WHITE_LIST = [:sqlite3]

	def select(table_name, condition)
		raise NotImplementedError
	end

	def column_name(table_name)
		raise NotImplementedError
	end
end
