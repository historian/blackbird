module Transitions

  require 'active_record'

  require 'transitions/version'

  require 'transitions/transition'
  require 'transitions/migration'
  require 'transitions/processor_list'

  require 'transitions/fragment'
  require 'transitions/schema'
  require 'transitions/table'
  require 'transitions/column'
  require 'transitions/index'
  require 'transitions/patch'

  module Processors
    require 'transitions/processors/indexed_columns'
    require 'transitions/processors/normal_default'
  end

  module Helpers
    require 'transitions/helpers/typed_columns'
    require 'transitions/helpers/join_tables'
  end

  if defined? ::Rails::Railtie
    require 'transitions/railtie'
  end

  def self.options
    @options ||= {
      :verbose => true,
      :processors => Transitions::ProcessorList.new
    }
  end

end
