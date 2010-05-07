class Transitions::SchemaDefinition

  attr_reader :tables, :patches
  attr_writer :patches

  def initialize
    @tables  = {}
    @patches = ActiveSupport::OrderedHash.new
  end

end