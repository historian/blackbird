module Transitions

  require 'active_record'

  require 'transitions/version'

  require 'transitions/transition'
  require 'transitions/schema_loader'
  require 'transitions/migration'
  require 'transitions/patch'

  require 'transitions/schema'
  require 'transitions/schema_builder'
  require 'transitions/schema_changes'
  require 'transitions/schema_definition'

  require 'transitions/table_builder'
  require 'transitions/table_changes'
  require 'transitions/table_definition'

  require 'transitions/column_definition'
  require 'transitions/index_definition'

  if defined?(Rails::Railtie)
    require 'transitions/railtie'
  end

  def self.options
    @options ||= { :verbose => true }
  end

end