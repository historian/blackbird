module Transitions

  require 'active_record'

  require 'transitions/version'
  require 'transitions/transition'
  require 'transitions/transition_runner'
  require 'transitions/schema_loader'
  require 'transitions/migration'

  require 'transitions/schema_definition'
  require 'transitions/table_definition'
  require 'transitions/column_definition'
  require 'transitions/index_definition'

  def self.run!
    current_schema = SchemaLoader.load
    new_schema     = TransitionRunner.run
    Migration.run!(current_schema, new_schema)
  end

end