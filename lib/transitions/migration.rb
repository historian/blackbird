# Transitions::Migration is responsible for creating database instructions
class Transitions::Migration

  attr_reader :instructions

  def self.build(current, future, changes)
    new(current, future, changes).build
  end

  def initialize(current, future, changes)
    @current, @future, @changes = current, future, changes
    @instructions = []
  end

  def build
    create_new_tables
    change_existing_tables
    remove_old_tables

    self
  end

private

  def create_new_tables
    @changes.new_tables.each do |table_name|
      table = @future.tables[table_name]

      pk_name = table.primary_key
      has_pk  = !!pk_name

      if Transitions.options[:verbose]
        @instructions << [
          :log, "--- Creating table #{table_name}"]
      end

      @instructions << [
        :create_table, table_name, table.options.merge(:id => has_pk, :primary_key => pk_name)]

      table.columns.each do |name, column|
        next if name == pk_name

        if Transitions.options[:verbose]
          @instructions << [
            :log, " +c #{name}:#{column.type}"]
        end

        @instructions << [
          :add_column, table_name, name, column.type, column.options]
      end

      table.indexes.each do |name, index|
        if Transitions.options[:verbose]
          @instructions << [
            :log, (index.options[:unique] ?
                    " +u #{index.columns * ' '}" :
                    " +i #{index.columns * ' '}" )]
        end

        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end
  end

  def apply_patches
    @changes.new_patches.each do |patch_name|

      if Transitions.options[:verbose]
        @instructions << [
          :log, "--- Applying patch #{patch.name}"]
      end

      patch = @future.patches[patch_name]
      patch.call(@changes)

      @instructions.concat(patch.instructions)

    end
  end

  def change_existing_tables
    # new columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      if Transitions.options[:verbose]
        unless changes.new_columns.empty? and changes.new_indexes.empty?
          @instructions << [
            :log, "--- Constructive changes for #{table_name}"]
        end
      end

      changes.new_columns.each do |name|
        column = future_table.columns[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, " +c #{name}:#{column.type}"]
        end

        @instructions << [
          :add_column, table_name, name, column.type, column.options]
      end

      changes.new_indexes.each do |name|
        index = future_table.indexes[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, (index.options[:unique] ?
                    " +u #{index.columns * ' '}" :
                    " +i #{index.columns * ' '}" )]
        end

        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end

    apply_patches

    # column changes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      if Transitions.options[:verbose]
        unless changes.changed_columns.empty? and changes.changed_indexes.empty?
          @instructions << [
            :log, "--- Mutative changes for #{table_name}"]
        end
      end

      changes.changed_columns.each do |name|
        column = future_table.columns[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, " ~c #{name}:#{column.type}"]
        end

        @instructions << [
          :change_column, table_name, name, column.type, column.options]
      end

      changes.changed_indexes.each do |name|
        index = future_table.indexes[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, (index.options[:unique] ?
                  " ~u #{index.columns * ' '}" :
                  " ~i #{index.columns * ' '}" )]
        end

        @instructions << [
          :remove_index, table_name, {:name => name}]
        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end

    # old columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      current_table = @current.tables[table_name]

      if Transitions.options[:verbose]
        unless changes.old_columns.empty? and changes.old_indexes.empty?
          @instructions << [
            :log, "--- Destructive changes for #{table_name}"]
        end
      end

      changes.old_indexes.each do |name|
        index = current_table.indexes[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, (index.options[:unique] ?
                    " -u #{index.columns * ' '}" :
                    " -i #{index.columns * ' '}" )]
        end

        @instructions << [
          :remove_index, table_name, {:name => name}]
      end

      changes.old_columns.each do |name|
        column = current_table.columns[name]

        if Transitions.options[:verbose]
          @instructions << [
            :log, " -c #{name}:#{column.type}"]
        end

        @instructions << [
          :remove_column, table_name, name]
      end
    end
  end

  def remove_old_tables
    @changes.old_tables.each do |table_name|
      if Transitions.options[:verbose]
        @instructions << [
          :log, "-- Dropping table #{table_name}"]
      end

      @instructions << [
        :drop_table, table_name]
    end
  end

end