namespace :db do

  desc "Transition to the current schema"
  task :transition => :environment do
    Transitions::Transition.run!(Rails.application.config.transitions.fragments)
  end

end