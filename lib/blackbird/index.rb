class Blackbird::Index

  attr_reader :name, :columns, :options

  def initialize(table_name, columns, options={})
    @table_name = table_name
    @columns, @options = [columns].flatten.compact, options
    @columns.collect! { |n| n.to_s }
  end

  def process(visitor)
    if visitor.respond_to?(:visit_index)
      visitor.visit_index(self)
    end
  end

  def name
    @options[:name] ||= "index_#{@table_name}_on_#{Array(@columns) * '_and_'}"
  end

  def hash
    [@columns, @options].hash
  end

  def ==(other)
    self.hash == other.hash
  end

end
