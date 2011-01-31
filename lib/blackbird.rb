module Blackbird

  require 'active_record'

  require 'blackbird/version'

  require 'blackbird/transition'
  require 'blackbird/migration'
  require 'blackbird/processor_list'

  require 'blackbird/fragment'
  require 'blackbird/schema'
  require 'blackbird/table'
  require 'blackbird/column'
  require 'blackbird/index'
  require 'blackbird/patch'

  module Processors
    require 'blackbird/processors/indexed_columns'
    require 'blackbird/processors/normal_default'
  end

  module Helpers
    require 'blackbird/helpers/typed_columns'
    require 'blackbird/helpers/join_tables'
  end

  if defined? ::Rails::Railtie
    require 'blackbird/railtie'
  end

  def self.options
    @options ||= {
      :verbose => true,
      :processors => Blackbird::ProcessorList.new
    }
  end
  
end