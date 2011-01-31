class Blackbird::Column

  attr_reader :name, :type, :options

  def initialize(name, type, options={})
    options.delete(:default) if options[:default] == nil
    @name, @type, @options = name.to_s, type, options
  end

  def process(visitor)
    if visitor.respond_to?(:visit_column)
      visitor.visit_column(self)
    end
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
    self.hash == other.hash
  end

end