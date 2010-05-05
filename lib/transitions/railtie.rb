class Transitions::Railtie < Rails::Railtie

  config.transitions = ActiveSupport::OrderedOptions.new
  config.transitions.auto_run = false

  initializer "transitions.run_transitions" do |app|
    if app.config.transitions.auto_run
      Transitions::Transition.run!
  end

end