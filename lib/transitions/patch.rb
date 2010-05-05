class Transitions::Patch
  
  def initialize(name, options={}, &block)
    @name    = name.to_s
    @options = options.dup
    @block   = block
  end
  
  attr_reader :name, :options, :block
  
end