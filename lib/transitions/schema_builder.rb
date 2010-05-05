class Transitions::SchemaBuilder

  def initialize(schema)
    @schema = schema
  end

  def table(name, options={}, &block)
    block, options = options, {} if Proc === options and block.nil?

    name  = name.to_s
    table = @schema.tables[name] || begin
      @schema.tables[name] = Transitions::TableDefinition.new(name, options)
    end
    block.call(Transitions::TableBuilder.new(@schema, table)) if block
    self
  end

  def patch(name, options={}, &block)
    block, options = options, {} if Proc === options and block.nil?

    patch = Transitions::Patch.new(name, options, &block)
    @schema.patches[patch.name] = patch
    self
  end

end