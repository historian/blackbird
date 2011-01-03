class PostsFragment < Transitions::Fragment

  table :posts do |t|
    t.string :title, :unique => true
    t.rename :published_at, :posted_at
  end

end