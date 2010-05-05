class Transitions::SchemaDefinition

  attr_reader :tables, :patches

  def initialize
    @tables  = {}
    @patches = ActiveSupport::OrderedHash.new
  end

end