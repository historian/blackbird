class Transitions::IndexDefinition

  attr_reader :name, :columns, :options

  def initialize(columns, options={})
    @columns, @options = [columns].flatten.compact, options
    @columns.collect! { |n| n.to_s }
  end

  def name
    @options[:name]
  end

  def hash
    [@columns, @options].hash
  end

end