class Transitions::Table::Builder

  def initialize(schema, fragment,  table)
    @schema, @fragment, @table = schema, fragment, table
  end


  def column(name, type, options={})
    if @table.columns[name.to_s]
      @table.change_column(name, type, options)
    else
      @table.add_column(name, type, options)
    end
  end

  def remove_column(name)
    @table.remove_column(name)
  end


  def index(columns, options={})
    @table.add_index(columns, options)
  end

  def remove_index(name)
    @table.remove_index(name)
  end

  def rename(old_name, new_name)
    column = @table.columns[old_name.to_s]
    self.remove old_name
    self.column new_name, column.type, column.options

    msg = "Renaming #{@table.name}.#{old_name} to #{@table.name}.#{new_name}"
    patch = Transitions::Patch.new(@fragment, msg) do |p|
      t = p.table(@table.name)

      if t.add?(new_name) and t.remove?(old_name)
        t.rename(old_name, new_name)
      end
    end
    @schema.patches[patch.name] = patch

  end


  def integer(name, options={})
    column(name, :integer, options)
  end

  def float(name, options={})
    column(name, :float, options)
  end

  def decimal(name, options={})
    column(name, :decimal, options)
  end

  def string(name, options={})
    column(name, :string, options)
  end

  def text(name, options={})
    column(name, :text, options)
  end

  def boolean(name, options={})
    column(name, :boolean, options)
  end

  def binary(name, options={})
    column(name, :binary, options)
  end

  def datetime(name, options={})
    column(name, :datetime, options)
  end

  def date(name, options={})
    column(name, :date, options)
  end

  def timestamp(name, options={})
    column(name, :timestamp, options)
  end

  def remove(name)
    remove_column name
  end

  def timestamps
    datetime :created_at
    datetime :updated_at
  end

end