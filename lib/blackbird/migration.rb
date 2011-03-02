# Blackbird::Migration is responsible for creating database instructions
class Blackbird::Migration

  attr_reader :instructions

  def self.build(current, future, changes)
    new(current, future, changes).build
  end

  def initialize(current, future, changes)
    @current, @future, @changes = current, future, changes
    @instructions = []
  end

  def build
    remove_old_indexes

    create_new_tables
    change_existing_tables
    remove_old_tables

    create_new_indexes

    self
  end

private

  def create_new_tables
    @changes.new_tables.each do |table_name|
      table = @future.tables[table_name]

      pk_name = table.primary_key
      has_pk  = !!pk_name
      table_opts = {}
      table_opts[:id]          = false   if has_pk == false
      table_opts[:primary_key] = pk_name if pk_name and pk_name != 'id'

      log "--- Creating table #{table_name}"
      run :create_table, table_name, table.options.merge(table_opts)

      table.columns.each do |name, column|
        next if name == pk_name

        log " +c #{name}:#{column.type}"
        run :add_column, table_name, name, column.type, column.options
      end
    end
  end

  def change_existing_tables
    # new columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      unless changes.new_columns.empty?
        log "--- Constructive changes for #{table_name}"
      end

      changes.new_columns.each do |name|
        column = future_table.columns[name]

        log " +c #{name}:#{column.type}"
        run :add_column, table_name, name, column.type, column.options
      end
    end

    # column changes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      current_table = @current.tables[table_name]
      future_table  = @future.tables[table_name]

      unless changes.changed_columns.empty?
        log "--- Mutative changes for #{table_name}"
      end

      changes.changed_columns.each do |name|
        column = future_table.columns[name]

        log " ~c #{name}:#{column.type} #{current_table.columns[name].options.inspect} => #{column.options.inspect}"
        run :change_column, table_name, name, column.type, column.options
      end
    end

    # old columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      current_table = @current.tables[table_name]

      unless changes.old_columns.empty?
        log "--- Destructive changes for #{table_name}"
      end

      changes.old_columns.each do |name|
        column = current_table.columns[name]

        log " -c #{name}:#{column.type}"
        run :remove_column, table_name, name
      end
    end
  end

  def remove_old_tables
    @changes.old_tables.each do |table_name|
      log "-- Dropping table #{table_name}"
      run :drop_table, table_name
    end
  end

  def remove_old_indexes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      current_table = @current.tables[table_name]

      changes.old_indexes.each do |name|
        index = current_table.indexes[name]

        log(index.options[:unique]       ?
            " -u #{index.columns * ' '}" :
            " -i #{index.columns * ' '}" )
        run :remove_index, table_name, {:name => name}
      end
    end

    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      changes.changed_indexes.each do |name|
        index = future_table.indexes[name]

        log(index.options[:unique]       ?
            " ~u #{index.columns * ' '}" :
            " ~i #{index.columns * ' '}" )

        run :remove_index, table_name, {:name => name}
      end
    end
  end

  def create_new_indexes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      changes.changed_indexes.each do |name|
        index = future_table.indexes[name]

        log(index.options[:unique]       ?
            " ~u #{index.columns * ' '}" :
            " ~i #{index.columns * ' '}" )

        run :add_index, table_name, index.columns, index.options
      end
    end

    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      changes.new_indexes.each do |name|
        index = future_table.indexes[name]

        log(index.options[:unique]       ?
            " +u #{index.columns * ' '}" :
            " +i #{index.columns * ' '}" )

        run :add_index, table_name, index.columns, index.options
      end
    end

    @changes.new_tables.each do |table_name|
      table = @future.tables[table_name]

      table.indexes.each do |name, index|
        log(index.options[:unique]       ?
            " +u #{index.columns * ' '}" :
            " +i #{index.columns * ' '}" )

        run :add_index, table_name, index.columns, index.options
      end
    end
  end

  def run(*instruction)
    @instructions << instruction
  end

  def log(message)
    if Blackbird.options[:verbose]
      run :log, message
    end
  end

end