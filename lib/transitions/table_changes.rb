class Transitions::TableChanges

  def self.analyze!(current, future)
    new(current, future).analyze!
  end

  attr_reader :new_columns, :old_columns, :all_columns, :changed_columns, :unchanged_columns
  attr_reader :new_indexes, :old_indexes, :all_indexes, :changed_indexes, :unchanged_indexes

  def initialize(current, future)
    @current, @future = current, future
  end

  def analyze!
    current_columns = @current ? @current.columns : {}
    future_columns  = @future  ? @future.columns  : {}

    @new_columns     = (future_columns.keys - current_columns.keys)
    @old_columns     = (current_columns.keys - future_columns.keys)
    @all_columns     = (current_columns.keys | future_columns.keys)
    @changed_columns = []
    (current_columns.keys & future_columns.keys).each do |name|
      if current_columns[name] != future_columns[name]
        @changed_columns << name
      end
    end
    @unchanged_columns = (current_columns.keys & future_columns.keys) - @changed_columns

    current_indexes = @current ? @current.indexes : {}
    future_indexes  = @future  ? @future.indexes  : {}

    @new_indexes     = (future_indexes.keys - current_indexes.keys)
    @old_indexes     = (current_indexes.keys - future_indexes.keys)
    @all_indexes     = (current_indexes.keys | future_indexes.keys)
    @changed_indexes = []
    (current_indexes.keys & future_indexes.keys).each do |name|
      if current_indexes[name] != future_indexes[name]
        @changed_indexes << name
      end
    end
    @unchanged_indexes = (current_indexes.keys & future_indexes.keys) - @changed_indexes

    self
  end

  def has_changes?
    !((@unchanged_columns == @all_columns) and
      (@unchanged_indexes == @all_indexes))
  end

  def add?(name)
    @new_columns.include?(name.to_s)
  end

  def add_index?(name)
    @new_indexes.include?(name.to_s)
  end

  def remove?(name)
    @old_columns.include?(name.to_s)
  end

  def remove_index?(name)
    @old_indexes.include?(name.to_s)
  end

  def change?(name)
    @changed_columns.include?(name.to_s)
  end

  def change_index?(name)
    @changed_indexes.include?(name.to_s)
  end

  def exists?(name)
    @all_columns.include?(name.to_s)
  end

  def index_exists?(name)
    @all_indexes.include?(name.to_s)
  end

end