class Transitions::Processors::IndexedColumns

  def visit_table(table)
    @current_table = table
  end

  def visit_column(column)
    options = column.options

    if options.delete(:unique)
      index_columns = [options.delete(:scope)].flatten.compact
      index_columns << column.name
      @current_table.add_index(index_columns, :unique => true)
    end

    if options.delete(:index)
      @current_table.add_index(column.name)
    end

  end

end
