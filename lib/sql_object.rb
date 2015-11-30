require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    columns = DBConnection.execute2(<<-SQL)
                                    SELECT
                                      *
                                    FROM
                                      #{self.table_name}
                                  SQL
    columns[0].map do |column|
      column.to_sym
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |el|
        attributes[column] = el
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
      @table_name ||= self.to_s.tableize
  end

  def self.all
    alls = DBConnection.execute(<<-SQL)
                                    SELECT
                                      #{self.table_name}.*
                                    FROM
                                      #{self.table_name}
                                  SQL
    parse_all(alls)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    found = DBConnection.execute(<<-SQL, id)
                                    SELECT
                                      #{self.table_name}.*
                                    FROM
                                      #{self.table_name}
                                    WHERE
                                      id = ?
                                  SQL
    self.parse_all(found)[0] unless found.empty?
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name_s = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name_s)
      self.send("#{attr_name_s}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |attr_name|
      self.send(attr_name)
    end
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.count).join(",")

    DBConnection.execute(<<-SQL, *self.attribute_values)
                          INSERT INTO
                            #{self.class.table_name} (#{col_names})
                          VALUES
                            (#{question_marks})
                          SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map{ |attr_name| "#{attr_name} = ?" }.join(',')
    DBConnection.execute(<<-SQL, *self.attribute_values)
                          UPDATE
                            #{self.class.table_name}
                          SET
                            #{set_line}
                          WHERE
                            id = #{self.id}
                          SQL

  end

  def save
    id.nil? ? insert : update
  end
end
