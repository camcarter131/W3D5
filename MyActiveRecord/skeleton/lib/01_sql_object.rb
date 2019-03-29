require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT *
      from #{self.table_name}
    SQL

    @columns.first.each.map(&:to_sym)
  end

  def self.finalize!
    
    self.columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=") { |value| attributes[col] = value }
    end
    
      
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    name = self.to_s
    name.downcase! + 's'
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      from #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |sub_hash| self.new(sub_hash) }
  end

  def self.find(id)
    all_objects = self.all
    all_objects.each do |object|
      return object if object.id == id
    end
    nil
  end

  def initialize(params = {})
    params.each do |attr, value|
       attr = attr.to_sym
       if !self.class.columns.include?(attr)
        raise "unknown attribute '#{attr}'"
       end
       self.send("#{attr}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
#     INSERT INTO table_name (column1, column2, column3, ...)
# VALUES (value1, value2, value3, ...);
    DBConnection.execute(<<-SQL)
      INSERT INTO #{self.table_name}
        ()
      VALUES 
        ()
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
