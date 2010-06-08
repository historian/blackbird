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
      @patch << [:rename_column, @changes.current.name, old_name, new_name]
    end

  end

end