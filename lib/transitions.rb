module Transitions

  require 'active_record'

  require 'transitions/version'

  require 'transitions/transition'
  require 'transitions/migration'
  require 'transitions/patch'
  require 'transitions/fragment'

  require 'transitions/schema'
  require 'transitions/table'
  require 'transitions/column'
  require 'transitions/index'

  if defined?(Rails::Railtie)
    require 'transitions/railtie'
  end

  def self.options
    @options ||= { :verbose => true }
  end

end