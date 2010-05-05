class Transitions::TableChanges
  
  def initialize(current, future)
    @current, @future = current, future
  end
  
  attr_reader :current, :future
  
  def add?(name)
    name = name.to_s
    (!@current and @future and @future.columns.key?(name)) or
    ( @current and @future and @future.columns.key?(name) and !@current.columns.key?(name))
  end
  
  def add_index?(name)
    name = name.to_s
    (!@current and @future and @future.indexes.key?(name)) or
    ( @current and @future and @future.indexes.key?(name) and !@current.indexes.key?(name))
  end
  
  def remove?(name)
    name = name.to_s
    (!@future and @current and @current.columns.key?(name)) or
    ( @future and @current and @current.columns.key?(name) and !@future.columns.key?(name))
  end
  
  def remove_index?(name)
    name = name.to_s
    (!@future and @current and @current.indexes.key?(name)) or
    ( @future and @current and @current.indexes.key?(name) and !@future.indexes.key?(name))
  end
  
  def change?(name)
    name = name.to_s
    (@future and @current and c = @current.columns[name] and f = @future.columns[name] and c.hash != f.hash)
  end
  
end