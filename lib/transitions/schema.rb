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

  def process(visitor)
    if visitor.respond_to?(:visit_schema)
      visitor.visit_schema(self)
    end

    @tables.values.dup.each do |table|
      table.process(visitor)
    end
  end

end