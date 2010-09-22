class PostsFragment < Transitions::Fragment

  table :posts do
    string   :title, :unique => true
    text     :body
    datetime :published_at, :index => true
  end

end
