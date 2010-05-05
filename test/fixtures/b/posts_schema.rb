class PostsSchema < Transitions::Schema

  table :posts do |t|
    t.string :title, :unique => true
    t.remove :published_at
  end

end