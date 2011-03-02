namespace :db do

  desc "Transition to the current schema"
  task :transition => :environment do
    Blackbird::Transition.run!(Blackbird.options[:fragments])
  end

end