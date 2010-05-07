class UsersSchema < Transitions::Schema

  table :users do |t|
    t.string :full_name
  end

end