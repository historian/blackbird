class UsersFragment < Transitions::Fragment

  table :users do
    string :full_name
  end

end
