class Transitions::IndexDefinition

  attr_reader :columns, :options

  def initialize(columns, options={})
    @columns, @options = [columns].flatten.compact, options
    @columns.collect! { |n| n.to_s }
  end

  def name
    @options[:name]
  end

  def ==(other)
    self.class === other and @columns == other.columns and @options == other.options
  end

end