require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(attribute_hash={})
   attribute_hash.each do |k, v|
  self.send("#{k}=", v)
   end
  end
  
    def self.table_name
      "#{self.to_s.downcase}s"
    end
    
  
    def self.column_names
      DB[:conn].results_as_hash = true
  
      sql = "PRAGMA table_info('#{table_name}')"
  
      table_info = DB[:conn].execute(sql)
      column_names = []
  
      table_info.each do |column|
        column_names << column["name"]
      end
      column_names.compact
    end

     def table_name_for_insert
      
      self.class.table_name
     end

     def col_names_for_insert
      self.class.column_names.delete_if {|column|column=="id"}.join(", ")
     end

     def values_for_insert
      values = []
      self.class.column_names.each do |column_name|
        values << self.send(column_name) unless self.send(column_name) == nil
        end
        return values.join(", ")
      end
    def self.find_by_name(name)
      sql = "SELECT * FROM #{table_name} WHERE name = ?"
      DB[:conn].execute(sql, name)
    end

    def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
    end
    
    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
      
    def self.find_by(hash)
      key, value = hash.first
      sql = "SELECT * FROM #{self.table_name} WHERE #{key.to_s} = ?"
      DB[:conn].execute(sql, value)
    end

end