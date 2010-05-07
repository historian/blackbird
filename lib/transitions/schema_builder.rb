class Transitions::SchemaBuilder

  def initialize(schema)
    @schema = schema
  end

  def table(schema, name, options={}, &block)
    name  = name.to_s
    table = @schema.tables[name] || begin
      @schema.tables[name] = Transitions::TableDefinition.new(name, options)
    end
    block.call(Transitions::TableBuilder.new(@schema, table)) if block
    self
  end

  def patch(schema, name, options={}, &block)
    patch = Transitions::Patch.new(schema, name, options, &block)
    @schema.patches[patch.name] = patch
    self
  end

end