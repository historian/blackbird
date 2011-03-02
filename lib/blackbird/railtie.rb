class Blackbird::Railtie < Rails::Railtie

  config.blackbird = ActiveSupport::OrderedOptions.new
  config.blackbird.verbose    = true
  config.blackbird.fragments  = nil
  config.blackbird.processors = Blackbird::ProcessorList.new

  config.generators.orm :active_record, :migration => false, :timestamps => true

  rake_tasks do
    load "blackbird/railtie/tasks.rake"
  end

  initializer "blackbird.setup_configuration" do |app|
    Blackbird.options[:verbose]    = app.config.blackbird.verbose
    Blackbird.options[:processors] = app.config.blackbird.processors
    Blackbird.options[:processors].use 'Blackbird::Processors::IndexedColumns'
    Blackbird.options[:processors].use 'Blackbird::Processors::NormalDefault'
  end

  initializer "blackbird.find_fragments" do |app|
    unless config.blackbird.fragments
      railties = [app.railties.all, app].flatten
      railties.each do |railtie|
        next unless railtie.respond_to? :paths
        Blackbird.options[:fragments].concat(
          railtie.paths.app.fragments.to_a)
      end
    end
  end

  generators do
    require "rails/generators/active_record/transition/transition_generator"
  end

end

class Rails::Engine::Configuration

  alias_method :paths_without_blackbird, :paths

  def paths
    @paths ||= begin
      paths_without_blackbird
      @paths.app.fragments "app/schema", :glob => "**/*_fragment.rb"
      @paths
    end
  end

end