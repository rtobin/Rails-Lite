require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    return @columns if @columns
    var = DBConnection.execute2("SELECT * FROM #{self.table_name}").first
    var.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |arg|

      define_method("#{arg}=") do |val|
        attributes[arg] = val
      end

      define_method("#{arg}") do
        attributes[arg]
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.tableize
  end

  def self.all
    stuff = DBConnection.execute("SELECT #{self.table_name}.* FROM #{table_name};")
    self.parse_all(stuff)

    # (<<-SQL)
    #   SELECT
    #     #{table_name}.*
    #   FROM
    #     #{table_name}
    # SQL
  end

  def self.parse_all(results)
    results.map do |params|
      new(params)
    end
  end

  def self.find(id)
    stuff = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{table_name}
      WHERE
        #{self.table_name}.id = ?
      ;
    SQL

    return nil if stuff.empty?

    self.new(stuff.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", value.to_s)
    end
    self.class.columns
  end

  def attributes
    @attributes ||= Hash.new(nil)
  end

  def attribute_values
    @attributes.values
  end

  def insert
    col_names = self.attributes.keys.join(", ")
    q_marks = ["?"] * self.attributes.keys.count
    q_marks = q_marks.join(", ")
    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
      ;
    SQL
    self.id = DBConnection.last_insert_row_id
 end


  def update
    col_names_and_q_marks = self.attributes.keys.join(" = ?, ") + " = ?"
    DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names_and_q_marks}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
