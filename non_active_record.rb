require 'active_support/inflector'
require './db/database.rb'
require './db/sqlite3.rb'

def set_database(db_path, type)
	if Database::TYPE_WHITE_LIST.include?(type)
		$db = Object.const_get(type.to_s.capitalize).new(db_path)
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
			@table_schema = $db.table_schema(self.class.table_name)

			define_column_name

			store_record_to(args)
		end
	end

	def save
		$db.insert(self.class.table_name, self.to_attr)
	end

	def update
	end

	def destroy
	end

	def to_attr
		attribute = {}
		@table_schema.keys.each do |column|
			attribute[column] = send(column)
		end
		attribute
	end

	class << self
		include ActiveSupport::Inflector

		def find(id)
			hash = $db.select(table_name, "id = #{id}")

			return nil if hash.empty?

			# hashの値が全てstringなのでデータが全てstringとして格納されてしまう
			self.new(hash[0])
		end

		def find_by(column_name:)
		end

		def where(condition)
			objects = []
			
			unless condition == :all
				condition_str = query_str_to(condition)
			end

			records = $db.select(table_name, condition_str)
			records.each do |record|
				objects << self.new(record)
			end
			objects
		end

		def all
			where(:all)
		end

		def table_name
			pluralize(self.to_s.downcase)
		end

		private

		def query_str_to(hash)
			str = ''
			count = 0
			hash.each do |k,v|
				if v.instance_of?(Array)
					str += k.to_s + ' in ' + v.inspect.gsub('[','(').gsub(']',')')
				else
					str += k.to_s + ' = ' + v.inspect
				end
				count += 1
				str += ' and ' if count != hash.size
			end
			str
		end
	end

	private

	def define_column_name
		@table_schema.keys.each do |column|
			self.class.class_eval "attr_accessor :#{column}"
		end
	end

	def store_record_to(info)
		@table_schema.keys.each do |column|
			if info.has_key?(column)
				instance_eval "@#{column} = #{info[column].inspect}"
			else
				instance_eval "@#{column} = nil"
			end
		end
	end
end
