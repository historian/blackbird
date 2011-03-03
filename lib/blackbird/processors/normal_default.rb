class Blackbird::Processors::NormalDefault

  def visit_column(column)
    column.options.delete(:default) if column.options[:default].nil?
    # column.options.delete(:null)    if column.options[:null] == true
  end

end