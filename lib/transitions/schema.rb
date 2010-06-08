class Transitions::Schema

  require 'transitions/schema/loader'
  require 'transitions/schema/builder'
  require 'transitions/schema/changes'

  attr_reader :tables, :patches
  attr_writer :patches

  def initialize
    @tables  = {}
    @patches = ActiveSupport::OrderedHash.new
  end

end