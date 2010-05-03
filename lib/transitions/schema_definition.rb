class Transitions::SchemaDefinition

  attr_reader :tables

  def initialize
    @tables = {}
  end

  def create_table(name, options={})
    table = Transitions::TableDefinition.new(name, options)
    yield(table) if block_given?
    @tables[table.name] = table
  end

  def change_table(name)
    table = @tables[name.to_s]
    yield(table) if block_given?
  end

  def rename_table(old_name, new_name)
    table = @tables.delete(old_name.to_s)
    table.rename(new_name.to_s)
    @tables[new_name.to_s] = table
  end

  def drop_table(name)
    @tables.delete(name.to_s)
  end

end