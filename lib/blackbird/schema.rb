class Blackbird::Schema

  require 'blackbird/schema/loader'
  require 'blackbird/schema/builder'
  require 'blackbird/schema/changes'

  attr_reader :tables

  def initialize
    @tables  = {}
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