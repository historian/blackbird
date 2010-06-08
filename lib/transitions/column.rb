class Transitions::Column

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

  def change(type, options={})
    @type, @options = type, options
  end

  def ==(other)
    self.class === other and @name == other.name and @type == other.type and @options == other.options
  end

end