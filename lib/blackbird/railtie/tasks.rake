namespace :db do

  desc "Transition to the current schema"
  task :transition => :environment do
    Blackbird::Transition.run!(Rails.application.config.blackbird.fragments)
  end

end