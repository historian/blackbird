class UsersFragment < Transitions::Fragment

  table :users do |t|
    t.string :full_name
  end

end