module Blackbird

  require 'active_record'

  require 'blackbird/version'

  require 'blackbird/transition'
  require 'blackbird/migration'

  require 'blackbird/fragment'
  require 'blackbird/schema'
  require 'blackbird/table'
  require 'blackbird/column'
  require 'blackbird/index'
  require 'blackbird/patch'

  if defined?(::Rails::Railtie)
    require 'blackbird/railtie'
  end

  def self.options
    @options ||= { :verbose => true }
  end

end