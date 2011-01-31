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
    evaluate_patches

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

      log "--- Creating table #{table_name}"
      run :create_table, table_name, table.options.merge(:id => has_pk, :primary_key => pk_name)

      table.columns.each do |name, column|
        next if name == pk_name

        log " +c #{name}:#{column.type}"
        run :add_column, table_name, name, column.type, column.clean_options
      end
    end
  end

  def evaluate_patches
    @evaluated_patches = []
    @changes.new_patches.each do |patch_name|

      patch = @future.patches[patch_name]
      patch.call(@changes)
      @evaluated_patches << patch

    end
  end

  def apply_patches
    @evaluated_patches.each do |patch|

      log "--- Applying patch #{patch.name}"
      @instructions.concat(patch.instructions)

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
        run :add_column, table_name, name, column.type, column.clean_options
      end
    end

    apply_patches

    # column changes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      unless changes.changed_columns.empty?
        log "--- Mutative changes for #{table_name}"
      end

      changes.changed_columns.each do |name|
        column = future_table.columns[name]

        log " ~c #{name}:#{column.type}"
        run :change_column, table_name, name, column.type, column.clean_options
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