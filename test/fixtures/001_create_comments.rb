class CreateCommentsTransition < Transitions::Transition
  def transition

    create_table :comments do |t|
      t.integer  :post_id, :index => true
      t.text     :body
      t.datetime :published_at, :index => true
    end

  end
end