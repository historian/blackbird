class Transitions::Table

  require 'transitions/table/builder'
  require 'transitions/table/changes'

  attr_reader :name, :options, :columns, :indexes

  def initialize(name, options={})
    @name    = name.to_s
    @options = { :id => true, :primary_key => 'id' }.merge(options)
    @columns = ActiveSupport::OrderedHash.new
    @indexes = ActiveSupport::OrderedHash.new

    if @options.delete(:id) and pk_name = @options.delete(:primary_key)
      add_column(pk_name, :integer, :primary => true)
    end
  end

  def hash
    [@name, @options, @columns, @indexes].hash
  end

  def primary_key
    @columns.values.each do |column|
      return column.name if column.primary?
    end
    nil
  end

  def add_column(name, type, options={})
    add_indexes_for_options(name, options)

    column = Transitions::Column.new(name, type, options)
    @columns[column.name] = column
  end

  def remove_column(name)
    @columns.delete(name.to_s)
    @indexes.values.each do |index|
      index.columns.delete(name.to_s)
      remove_index(index.options[:name]) if index.columns.empty?
    end
  end

  def change_column(name, type, options={})
    add_indexes_for_options(name, options)

    @columns[name.to_s].change(type, options)
  end

  def add_index(columns, options={})
    options[:name] ||= "index_#{@name}_on_#{Array(columns) * '_and_'}"
    index = Transitions::Index.new(columns, options)
    @indexes[index.name] = index
  end

  def remove_index(name)
    @indexes.delete(name.to_s)
  end

private

  def add_indexes_for_options(column, options={})
    if unique = options.delete(:unique)
      index_columns = [options.delete(:scope)].flatten.compact
      index_columns << column
      add_index(index_columns, :unique => true)
    end

    if options.delete(:index)
      add_index(column)
    end
  end

end