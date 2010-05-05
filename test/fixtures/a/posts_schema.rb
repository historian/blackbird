class PostsSchema < Transitions::Schema

  table :posts do |t|
    t.string   :title, :unique => true
    t.text     :body
    t.datetime :published_at, :index => true
  end

end