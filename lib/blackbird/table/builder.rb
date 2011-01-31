class Blackbird::Table::Builder

  def initialize(schema, fragment,  table)
    @schema, @fragment, @table = schema, fragment, table
  end

  ##
  # Scope a number of column definitions. All the column and index
  # options can be passed here. also :prefix and :suffix can be passed
  # and they prefix or suffix the names of the indexes and columns.
  def scope(options={}, &block)
    _scope, @scope = @scope, (@scope || {}).merge(options)
    if block.arity != 1
      instance_eval(&block)
    else
      yield(self)
    end
  ensure
    @scope = _scope
  end

  ##
  # Remove any previously defined scopes
  def without_scope(&block)
    _scope, @scope = @scope, nil
    if block.arity != 1
      instance_eval(&block)
    else
      yield(self)
    end
  ensure
    @scope = _scope
  end

  
  ##
  # Define a column
  def column(name, type, options={})
    options = @scope.merge(options) if @scope
    options = { :null => true }.merge(options)
    
    name = "#{options[:prefix]}#{name}" if options[:prefix]
    name = "#{name}#{options[:suffix]}" if options[:suffix]
    
    if @table.columns[name.to_s]
      @table.change_column(name, type, options)
    else
      @table.add_column(name, type, options)
    end
  end

  ##
  # Remove a column
  def remove_column(name)
    options = @scope || {}
    
    name = "#{options[:prefix]}#{name}" if options[:prefix]
    name = "#{name}#{options[:suffix]}" if options[:suffix]
    
    @table.remove_column(name)
  end


  ##
  # Define an index
  def index(columns, options={})
    options = @scope.merge(options) if @scope

    columns = [columns].flatten.collect do |name|
      name = "#{options[:prefix]}#{name}" if options[:prefix]
      name = "#{name}#{options[:suffix]}" if options[:suffix]
      name
    end
    
    @table.add_index(columns, options)
  end

  ##
  # Remove an index
  def remove_index(name)
    options = @scope || {}
    
    name = "#{options[:prefix]}#{name}" if options[:prefix]
    name = "#{name}#{options[:suffix]}" if options[:suffix]
    
    @table.remove_index(name)
  end

  ##
  # Rename a previously defined columns. This also creates a patch to
  # migrate any data in the old column to the new column.
  def rename(old_name, new_name)
    options = @scope
    if options
      new_name = "#{options[:prefix]}#{new_name}" if options[:prefix]
      new_name = "#{new_name}#{options[:suffix]}" if options[:suffix]
      
      old_name = "#{options[:prefix]}#{old_name}" if options[:prefix]
      old_name = "#{old_name}#{options[:suffix]}" if options[:suffix]
    end
    
    column = @table.columns[old_name.to_s]

    without_scope do
      self.remove old_name
      self.column new_name, column.type, column.options
    end
    
    msg = "Renaming #{@table.name}.#{old_name} to #{@table.name}.#{new_name}"
    patch = Blackbird::Patch.new(@fragment, msg) do |p|
      t = p.table(@table.name)

      if t.add?(new_name) and t.remove?(old_name)
        t.rename(old_name, new_name)
      end
    end
    @schema.patches[patch.name] = patch
  end

  def remove(name)
    remove_column name
  end

end
