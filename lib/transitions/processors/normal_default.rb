class Transitions::Processors::NormalDefault

  def visit_column(column)
    column.options.delete(:default) if column.options[:default].nil?
  end

end