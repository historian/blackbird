class Blackbird::Railtie < Rails::Railtie

  config.blackbird = ActiveSupport::OrderedOptions.new
  config.blackbird.verbose  = true
  config.blackbird.auto_run = false
  config.blackbird.fragments  = nil

  config.generators.orm :active_record, :migration => false, :timestamps => true

  rake_tasks do
    load "blackbird/railtie/tasks.rake"
  end

  initializer "blackbird.setup_configuration" do |app|
    Blackbird.options[:verbose] = app.config.blackbird.verbose
  end

  initializer "blackbird.find_fragments" do |app|
    unless config.blackbird.fragments
      config.blackbird.fragments = []
      railties = [app.railties.all, app].flatten
      railties.each do |railtie|
        next unless railtie.respond_to? :paths
        config.blackbird.fragments.concat(
          railtie.paths.app.fragments.to_a)
      end
    end
  end

  initializer "blackbird.run_blackbird" do |app|
    if app.config.blackbird.auto_run
      Blackbird::Transition.run!(
        config.blackbird.fragments)
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