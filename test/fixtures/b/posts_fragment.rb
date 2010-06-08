class PostsFragment < Transitions::Fragment

  table :posts do |t|
    t.string :title, :unique => true
    t.remove :published_at
    t.datetime :posted_at, :index => true
  end

  patch "Rename published_at to posted_at in posts" do |p|
    t = p.table(:posts)

    if t.add?(:posted_at) and t.remove?(:published_at)
      t.rename(:published_at, :posted_at)
    end
  end

end