class Transitions::Patch

  def initialize(fragment, name, options={}, &block)
    @fragment     = fragment
    @name         = name.to_s
    @options      = options.dup
    @block        = block
  end

  attr_reader :fragment, :name, :options, :block, :instructions

  def call(changes)
    @instructions = []
    @block.call(SchemaPatcher.new(self, changes))
  end

  def <<(instruction)
    @instructions << instruction
  end

  class SchemaPatcher

    def initialize(patch, changes)
      @patch, @changes = patch, changes
      @instructions = []
    end

    %w( add? exists? remove? change? ).each do |m|
      define_method(m) { |*args| @changes.__send__(m, *args) }
    end

    def table(name)
      (@tables ||= {})[name.to_s] = TablePatcher.new(@patch, @changes.table(name))
    end

    def apply(name)
      @patch << [:apply, @patch.fragment.method(name)]
    end

  end

  class TablePatcher

    def initialize(patch, changes)
      @patch, @changes = patch, changes
    end

    %w( add? add_index? remove? remove_index? change? change_index? exists? index_exists? ).each do |m|
      define_method(m) { |*args| @changes.__send__(m, *args) }
    end

    def apply(name)
      @patch << [:apply, @patch.fragment.method(name)]
    end

    def rename(old_name, new_name)
      @changes.old_columns.delete(old_name.to_s)
      @changes.new_columns.delete(new_name.to_s)
      # @changes.future.indexes.each do |(k, index)|
      #   if idx = index.columns.index(old_name.to_s)
      #     @changes.future.indexes.delete(index.name)
      #     index.columns[idx] = new_name.to_s
      #     index.options[:name] = nil
      #     @changes.future.indexes[index.name] = index
      #   end
      # end
      @patch << [:rename_column, @changes.current.name, old_name.to_sym, new_name.to_sym]
    end

  end

end