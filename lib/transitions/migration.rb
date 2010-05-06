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

      @instructions << [
        :create_table, table_name, table.options.merge(:id => has_pk, :primary_key => pk_name)]

      table.columns.each do |name, column|
        next if name == pk_name
        @instructions << [
          :add_column, table_name, name, column.type, column.options]
      end

      table.indexes.each do |name, index|
        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end
  end

  def change_existing_tables
    # new columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      changes.new_columns.each do |name|
        column = future_table.columns[name]
        @instructions << [
          :add_column, table_name, name, column.type, column.options]
      end

      changes.new_indexes.each do |name|
        index = future_table.indexes[name]
        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end

    # column changes
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)
      future_table  = @future.tables[table_name]

      changes.changed_columns.each do |name|
        column = future_table.columns[name]
        @instructions << [
          :change_column, table_name, name, column.type, column.options]
      end

      changes.changed_indexes.each do |name|
        index = future_table.indexes[name]
        @instructions << [
          :remove_index, table_name, {:name => name}]
        @instructions << [
          :add_index, table_name, index.columns, index.options]
      end
    end

    # old columns
    @changes.changed_tables.each do |table_name|
      changes       = @changes.table(table_name)

      changes.old_indexes.each do |name|
        @instructions << [
          :remove_index, table_name, {:name => name}]
      end

      changes.old_columns.each do |name|
        @instructions << [
          :remove_column, table_name, name]
      end
    end
  end

  def remove_old_tables
    @changes.old_tables.each do |table_name|
      @instructions << [
        :drop_table, table_name]
    end
  end

end