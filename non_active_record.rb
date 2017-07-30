require 'active_support/inflector'
require './db/sqlite3.rb'

module Database
  TYPE_WHITE_LIST = [:sqlite3]
end

def set_database(db_path, type)
  if Database::TYPE_WHITE_LIST.include?(type)
    $db = Object.const_get(type.to_s.capitalize).new(db_path)
  else
    raise 'Not allowed this database type.'
  end
end

class NonActiveRecord
  @@belongs_to_tables, @@has_many_tables = [], []

  def initialize(args = {})
    raise 'Need to inherit for using NonActiveRecord.' unless self.class.superclass == NonActiveRecord

    if $db == nil
      raise 'Not completed set database.'
    else
      # なにかしらのセットアップ
      @table_schema = $db.table_schema(self.class.table_name)

      define_column_name
      
      store_record_to(args)

      define_accessor_belongs_to
      define_accessor_has_many
    end
  end

  def save
    $db.insert(self.class.table_name, self.to_attr)
  end

  def update(attribute)
    if $db.update(self.class.table_name, attribute, self.id)
      @table_schema.keys.each do |column|
        if attribute.has_key?(column)
          instance_eval "@#{column} = #{attribute[column].inspect}"
        end
      end

      return true
    end

    false
  end

  def destroy
    $db.delete(self.class.table_name, self.id)
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
      hash = $db.select(table_name, { id: id })

      return nil if hash.empty?

      self.new(hash[0])
    end
    
    def where(condition)
      objects = []
      
      if condition == :all
        condition = nil
      end

      records = $db.select(table_name, condition)
      records.each do |record|
        objects << self.new(record)
      end
      objects
    end

    def all
      where(:all)
    end

    def belongs_to(table)
      if $db.table_schema(table_name).keys.include?("#{table}_id".to_sym)
        @@belongs_to_tables << table
      else
        raise "Not exist column: #{table}_id of table: #{table_name}"
      end
    end

    def has_many(tables)
      if $db.table_schema(tables.to_s).keys.include?("#{self.to_s.downcase}_id".to_sym)
        @@has_many_tables << tables
      else
        raise "Not exist column: #{self.to_s.downcase}_id of table: #{tables}"
      end
    end

    def table_name
      pluralize(self.to_s.downcase)
    end
  end

  private

  def define_column_name
    @table_schema.keys.each do |column|
      self.class.class_eval "attr_accessor :#{column}"
    end
  end

  def define_accessor_belongs_to
    @@belongs_to_tables.each do |belongs_to_table|
      instance_eval <<~EOS
        def #{belongs_to_table}
          if @#{belongs_to_table}_id.nil?
            nil
          else
            Object.const_get('#{belongs_to_table}'.capitalize).find @#{belongs_to_table}_id
          end
        end
      EOS
    end
  end

  def define_accessor_has_many
    @@has_many_tables.each do |has_many_table| 
      instance_eval <<~EOS
        def #{has_many_table}
          Object.const_get(self.class.singularize('#{has_many_table}').capitalize).where(#{self.class.to_s.downcase}_id: self.id)
        end
      EOS
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
