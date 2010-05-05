class CommentsSchema < Transitions::Schema

  table :comments do |t|
    t.integer  :post_id, :index => true
    t.text     :body
    t.datetime :published_at, :index => true
  end

end