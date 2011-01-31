class Blackbird::Column

  attr_reader :name, :type, :options

  def initialize(name, type, options={})
    options.delete(:default) if options[:default] == nil
    @name, @type, @options = name.to_s, type, options
  end

  def clean_options
    @options.except(:index, :unique, :scope)
  end

  def primary?
    !!@options[:primary]
  end

  def hash
    [@name, @type, clean_options].hash
  end

  def change(type, options={})
    @type, @options = type, options
  end

  def ==(other)
    self.hash == other.hash
  end

end