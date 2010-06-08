class Transitions::Railtie < Rails::Railtie

  config.transitions = ActiveSupport::OrderedOptions.new
  config.transitions.verbose  = true
  config.transitions.auto_run = false
  config.transitions.fragments  = nil

  config.generators.orm :active_record, :migration => false, :timestamps => true

  initializer "transitions.setup_configuration" do |app|
    Transitions.options[:verbose] = app.config.transitions.verbose
  end

  initializer "transitions.find_fragments" do |app|
    unless config.transitions.fragments
      config.transitions.schemas = []
      railties = [app.railties.all, app].flatten
      railties.each do |railtie|
        next unless railtie.respond_to? :paths
        config.transitions.fragments.concat(
          railtie.paths.app.fragments.to_a)
      end
    end
  end

  initializer "transitions.run_transitions" do |app|
    if app.config.transitions.auto_run
      Transitions::Transition.run!(
        config.transitions.fragments)
    end
  end

  generators do
    require "rails/generators/active_record/transition/transition_generator"
  end

end

class Rails::Engine::Configuration

  alias_method :paths_without_transitions, :paths

  def paths
    @paths ||= begin
      paths_without_transitions
      @paths.app.fragments "app/schemas", :glob => "**/*_fragment.rb"
      @paths
    end
  end

end