class Transitions::Migration

  attr_reader :instructions

  def self.build(current, future)
    new(current, future).build
  end

  def self.run!(current, future)
    build(current, future).run!
  end

  def initialize(current, future)
    @current, @future = current, future
    @instructions = []
  end

  def build
    create_new_tables
    change_existing_tables
    remove_old_tables

    self
  end

  def run!
    connection.transaction do
      @instructions.each do |instruction|
        connection.__send__(*instruction)
      end
    end
    true
  end

private

  def connection
    ActiveRecord::Base.connection
  end

private

  def create_new_tables
    new_tables = (@future.tables.keys - @current.tables.keys)

    new_tables.each do |table_name|
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
    existing_tables = (@future.tables.keys & @current.tables.keys)

    changed_tables = existing_tables.inject([]) do |memo, table_name|
      current_table = @current.tables[table_name]
      future_table  = @future.tables[table_name]

      memo << table_name unless current_table.hash == future_table.hash

      memo
    end

    changed_tables.each do |table_name|
      current_table = @current.tables[table_name]
      future_table  = @future.tables[table_name]

      create_new_columns      current_table, future_table
      create_new_indexes      current_table, future_table
    end

    changed_tables.each do |table_name|
      current_table = @current.tables[table_name]
      future_table  = @future.tables[table_name]

      change_existing_columns current_table, future_table
      change_existing_indexes current_table, future_table
    end

    changed_tables.each do |table_name|
      current_table = @current.tables[table_name]
      future_table  = @future.tables[table_name]

      remove_old_indexes      current_table, future_table
      remove_old_columns      current_table, future_table
    end
  end

  def remove_old_tables
    old_tables = (@current.tables.keys - @future.tables.keys)

    old_tables.each do |table_name|
      @instructions << [
        :drop_table, table_name]
    end
  end

private

  def create_new_columns(current_table, future_table)
    new_columns = (future_table.columns.keys - current_table.columns.keys)

    new_columns.each do |column_name|
      column = future_table.columns[column_name]

      @instructions << [
        :add_column, current_table.name,
        column_name, column.type, column.options]
    end
  end

  def change_existing_columns(current_table, future_table)
    existing_columns = (future_table.columns.keys & current_table.columns.keys)

    existing_columns.each do |column_name|
      current_column = current_table.columns[column_name]
      future_column  = future_table.columns[column_name]

      next if current_column.hash == future_column.hash

      @instructions << [
        :change_column, current_table.name,
        column_name, future_column.type, future_column.options]
    end
  end

  def remove_old_columns(current_table, future_table)
    old_columns = (current_table.columns.keys - future_table.columns.keys)

    old_columns.each do |column_name|
      @instructions << [
        :remove_column, current_table.name, column_name]
    end
  end

private

  def create_new_indexes(current_table, future_table)
    new_indexes = (future_table.indexes.keys - current_table.indexes.keys)

    new_indexes.each do |index_name|
      index = future_table.indexes[index_name]
      @instructions << [
        :add_index, current_table.name, index.columns, index.options]
    end
  end

  def change_existing_indexes(current_table, future_table)
    existing_indexes = (future_table.indexes.keys & current_table.indexes.keys)

    existing_indexes.each do |index_name|
      current_index = current_table.indexes[index_name]
      future_index  = future_table.indexes[index_name]

      next if current_index.hash == future_index.hash

      @instructions << [
        :remove_index, current_table.name, index_name]
      @instructions << [
        :add_index, current_table.name,
        future_index.columns, future_index.options]
    end
  end

  def remove_old_indexes(current_table, future_table)
    old_indexes = (current_table.indexes.keys - future_table.indexes.keys)

    old_indexes.each do |index_name|
      @instructions << [
        :remove_index, current_table.name, index_name]
    end
  end

end