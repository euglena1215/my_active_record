require 'active_support/inflector'
require './db/database.rb'
require './db/sqlite3.rb'

def set_database(db_name, type)
	if Database::TYPE_WHITE_LIST.include?(type)
		$db = Object.const_get(db_type.to_s.capitalize).new(db_name)
	else
		raise 'Not allowed this database type.'
	end
end

class NonActiveRecord
	def initialize(args = {})
		if $db == nil
			raise 'Not completed set database.'
		else
			# なにかしらのセットアップ
			@column_name = $db.column_name(self.class.table_name)
			
			define_column_name

			store_record_to(args)
		end
	end

	class << self
		include ActiveSupport::Inflector

		def find(id)
			record = self.new
			hash = $db.select(table_name, '*', "id = #{id}")

			return nil if hash.empty?

			hash[0].each do |k,v|
				m = k + '='
				record.send(m.to_sym, v)
			end
			record
		end

		def table_name
			pluralize(self.to_s.downcase)
		end
	end

	private

	def define_column_name
		@column_name.each do |column|
			self.class.class_eval "attr_accessor :#{column}"
		end
	end

	def store_record_to(info)

	end

end