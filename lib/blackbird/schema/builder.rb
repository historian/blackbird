class Blackbird::Schema::Builder

  def initialize(schema)
    @schema = schema
  end

  def table(fragment, name, options={}, &block)
    name  = name.to_s
    table = @schema.tables[name] || begin
      @schema.tables[name] = Blackbird::Table.new(name, options)
    end
    block.call(Blackbird::Table::Builder.new(@schema, fragment, table)) if block
    self
  end

  def patch(fragment, name, options={}, &block)
    patch = Blackbird::Patch.new(fragment, name, options, &block)
    @schema.patches[patch.name] = patch
    self
  end

end