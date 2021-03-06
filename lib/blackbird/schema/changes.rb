class Blackbird::Schema::Changes

  def self.analyze!(current, future)
    new(current, future).analyze!
  end

  attr_reader :new_tables, :old_tables, :changed_tables, :unchanged_tables

  def initialize(current, future)
    @current, @future = current, future
  end

  def analyze!
    @table_changes = (@current.tables.keys | @future.tables.keys).uniq
    @table_changes = @table_changes.inject({}) do |memo, table_name|
      memo[table_name] ||= Blackbird::Table::Changes.analyze!(
        @current.tables[table_name], @future.tables[table_name])
      memo
    end

    @new_tables      = (@future.tables.keys - @current.tables.keys).sort
    @old_tables      = (@current.tables.keys - @future.tables.keys).sort
    @changed_tables  = @table_changes.inject([]) do |memo, (table_name, table)|
      if @new_tables.include?(table_name)
        memo
      elsif @old_tables.include?(table_name)
        memo
      elsif table.has_changes?
        memo << table_name
        memo
      else
        memo
      end
    end.sort
    @unchanged_tables = (@table_changes.keys -
      (@changed_tables + @new_tables + @old_tables)).sort

    self
  end

  def table(name)
    @table_changes[name.to_s]
  end

  def add?(name)
    @new_tables.include?(name.to_s)
  end

  def remove?(name)
    @old_tables.include?(name.to_s)
  end

  def change?(name)
    @changed_tables.include?(name.to_s)
  end

  def unchange?(name)
    @unchanged_tables.include?(name.to_s)
  end

  def exists?(name)
    @table_changes.key?(name.to_s)
  end

end