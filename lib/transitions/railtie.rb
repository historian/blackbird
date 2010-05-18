class Transitions::Railtie < Rails::Railtie

  config.transitions = ActiveSupport::OrderedOptions.new
  config.transitions.verbose  = true
  config.transitions.auto_run = false
  config.transitions.schemas  = nil

  rake_tasks do
    load "transitions/railtie/tasks.rake"
  end

  initializer "transitions.setup_configuration" do |app|
    Transitions.options[:verbose] = app.config.transitions.verbose
  end

  initializer "transitions.find_schemas" do |app|
    unless config.transitions.schemas
      config.transitions.schemas = []
      railties = [app.railties.all, app].flatten
      railties.each do |railtie|
        next unless railtie.respond_to? :paths
        config.transitions.schemas.concat(
          railtie.paths.app.schemas.to_a)
      end
    end
  end

  initializer "transitions.run_transitions" do |app|
    if app.config.transitions.auto_run
      Transitions::Transition.run!(
        config.transitions.schemas)
    end
  end

end

class Rails::Engine::Configuration

  alias_method :paths_without_transitions, :paths

  def paths
    @paths ||= begin
      paths_without_transitions
      @paths.app.schemas "app/schemas", :glob => "**/*_schema.rb"
      @paths
    end
  end

end