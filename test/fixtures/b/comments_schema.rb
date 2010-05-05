class CommentsSchema < Transitions::Schema

  table :comments do |t|
    t.remove   :published_at
    t.datetime :posted_at, :index => true
  end

  patch "Rename published_at to posted_at in comments" do |p|
    t = p.table(:comments)
    if t.add?(:posted_at) and t.remove?(:published_at)
      t.rename(:published_at, :posted_at)
    end
  end

end