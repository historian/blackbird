class Transitions::SchemaDefinition

  attr_reader :tables

  def initialize
    @tables  = {}
    @patches = ActiveSupport::OrderedHash.new
  end

  def table(name, options={})
    table = @tables[name.to_s] || begin
      @tables[name.to_s] = Transitions::TableDefinition.new(name, options)
    end
    yield(table) if block_given?
    self
  end
  
  def patch(name, options={}, &block)
    patch = Transitions::Patch.new(name, options, &block)
    @patches[patch.name] = patch
    self
  end

end