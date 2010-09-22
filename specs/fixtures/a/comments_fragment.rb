class CommentsFragment < Transitions::Fragment

  table :comments do
    scope :index => true do
      integer  :post_id
      integer  :user_id
      datetime :published_at
    end
    text :body
  end

end
