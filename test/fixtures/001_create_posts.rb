class CreatePostsTransition < Transitions::Transition
  def transition

    create_table :posts do |t|
      t.string   :title, :unique => true
      t.text     :body
      t.datetime :published_at, :index => true
    end

  end
end