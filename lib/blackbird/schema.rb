class Blackbird::Schema

  require 'blackbird/schema/loader'
  require 'blackbird/schema/builder'
  require 'blackbird/schema/changes'

  attr_reader :tables, :patches
  attr_writer :patches

  def initialize
    @tables  = {}
    @patches = ActiveSupport::OrderedHash.new
  end

end