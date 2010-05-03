class Transitions::TableDefinition

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

  def rename(name)
    @name = name.to_s
  end

  def add_column(name, type, options={})
    if unique = options.delete(:unique)
      index_columns = [options.delete(:scope)].flatten.compact
      index_columns << name
      add_index(index_columns, :unique => true)
    end

    if options.delete(:index)
      add_index(name)
    end

    column = Transitions::ColumnDefinition.new(name, type, options)
    @columns[column.name] = column
  end

  def remove_column(name)
    @columns.delete(name.to_s)
    @indexes.values.each do |index|
      index.columns.delete(name.to_s)
      remove_index(index.options[:name]) if index.columns.empty?
    end
  end

  def rename_column(old_name, new_name)
    column = @columns.delete(old_name.to_s)
    column.rename(new_name.to_s)
    @columns[new_name.to_s] = columns
  end

  def change_column(name, type, options={})
    @columns[name.to_s].change(type, options)
  end

  def add_index(columns, options={})
    options[:name] ||= "index_#{@name}_on_#{Array(columns) * '_and_'}"
    index = Transitions::IndexDefinition.new(columns, options)
    @indexes[index.name] = index
  end

  def remove_index(name)
    @indexes.delete(name.to_s)
  end


  def integer(name, options={})
    add_column(name, :integer, options)
  end

  def float(name, options={})
    add_column(name, :float, options)
  end

  def decimal(name, options={})
    add_column(name, :decimal, options)
  end

  def string(name, options={})
    add_column(name, :string, options)
  end

  def text(name, options={})
    add_column(name, :text, options)
  end

  def boolean(name, options={})
    add_column(name, :boolean, options)
  end

  def binary(name, options={})
    add_column(name, :binary, options)
  end

  def datetime(name, options={})
    add_column(name, :datetime, options)
  end

  def date(name, options={})
    add_column(name, :date, options)
  end

  def timestamp(name, options={})
    add_column(name, :timestamp, options)
  end

  def remove(name)
    remove_column name
  end

end