class Transitions::ColumnDefinition

  attr_reader :name, :type, :options

  def initialize(name, type, options={})
    @name, @type, @options = name.to_s, type, options
  end

  def primary?
    !!@options[:primary]
  end

  def hash
    [@name, @type, @options].hash
  end

end