class Blackbird::Schema::Builder

  def initialize(schema)
    @schema = schema
  end

  def table(fragment, name, options={}, &block)
    name  = name.to_s
    table = @schema.tables[name] || begin
                                      @schema.tables[name] = Blackbird::Table.new(name, options)
                                    end

    if block
      builder = Blackbird::Table::Builder.new(@schema, fragment, table)
      if block.arity != 1
        builder.instance_eval(&block)
      else
        block.call(builder)
      end
    end

    self
  end

end
