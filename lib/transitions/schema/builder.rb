class Transitions::Schema::Builder

  def initialize(schema)
    @schema = schema
  end

  def table(fragment, name, options={}, &block)
    name  = name.to_s
    table = @schema.tables[name] || begin
      @schema.tables[name] = Transitions::Table.new(name, options)
    end
    block.call(Transitions::Table::Builder.new(@schema, fragment, table)) if block
    self
  end

  def patch(fragment, name, options={}, &block)
    patch = Transitions::Patch.new(fragment, name, options, &block)
    @schema.patches[patch.name] = patch
    self
  end

end