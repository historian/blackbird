class CommentsFragment < Blackbird::Fragment

  table :comments do |t|
    t.integer  :post_id, :index => true
    t.integer  :user_id, :index => true
    t.text     :body
    t.datetime :published_at, :index => true
  end

end